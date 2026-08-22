import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class FetchMessages extends ChatEvent {
  final String customerUuid;
  final String driverUuid;
  final String receiverType;

  const FetchMessages({
    required this.customerUuid,
    this.driverUuid = '',
    this.receiverType = 'DRIVER',
  });

  @override
  List<Object?> get props => [customerUuid, driverUuid, receiverType];
}

class SendMessage extends ChatEvent {
  final String customerUuid;
  final String driverUuid;
  final String message;
  final String receiverType;
  final String? filePath;

  const SendMessage({
    required this.customerUuid,
    this.driverUuid = '',
    required this.message,
    this.receiverType = 'DRIVER',
    this.filePath,
  });

  @override
  List<Object?> get props => [customerUuid, driverUuid, message, receiverType, filePath];
}
