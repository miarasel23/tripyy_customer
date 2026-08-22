import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  Timer? _pollingTimer;

  ChatBloc({required this.repository}) : super(ChatInitial()) {
    on<FetchMessages>(_onFetchMessages);
    on<SendMessage>(_onSendMessage);
  }

  void startPolling(String customerUuid, {String driverUuid = '', String receiverType = 'DRIVER'}) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      add(FetchMessages(
        customerUuid: customerUuid,
        driverUuid: driverUuid,
        receiverType: receiverType,
      ));
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  Future<void> _onFetchMessages(FetchMessages event, Emitter<ChatState> emit) async {
    if (state is ChatInitial) {
      emit(ChatLoading());
    }

    try {
      final messages = await repository.fetchConversations(
        customerUuid: event.customerUuid,
        driverUuid: event.driverUuid,
        receiverType: event.receiverType,
      );

      emit(ChatLoaded(messages: messages, isSending: false));
    } catch (e) {
      if (state is! ChatLoaded) {
        emit(const ChatError("Failed to load messages."));
      }
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is ChatLoaded) {
      emit(currentState.copyWith(isSending: true));
    }

    try {
      final success = await repository.sendMessage(
        customerUuid: event.customerUuid,
        driverUuid: event.driverUuid,
        message: event.message,
        receiverType: event.receiverType,
        filePath: event.filePath,
      );

      if (success) {
        final messages = await repository.fetchConversations(
          customerUuid: event.customerUuid,
          driverUuid: event.driverUuid,
          receiverType: event.receiverType,
        );
        emit(ChatLoaded(messages: messages, isSending: false));
      } else {
        if (currentState is ChatLoaded) {
          emit(currentState.copyWith(isSending: false));
        }
      }
    } catch (e) {
      if (currentState is ChatLoaded) {
        emit(currentState.copyWith(isSending: false));
      }
    }
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }
}
