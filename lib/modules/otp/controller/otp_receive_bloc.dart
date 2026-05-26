import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trippy_customer/modules/otp/controller/otp_receive_event.dart';
import 'package:trippy_customer/modules/otp/controller/otp_receive_state.dart';
import 'package:trippy_customer/modules/otp/repository/otp_receive_repository.dart';
import 'package:trippy_customer/utils/enums.dart';

class OtpReceiveBloc extends Bloc<OtpReceiveEvent, OtpReceiveState> {
  final OtpReceiveRepository repository;

  OtpReceiveBloc({required this.repository})
    : super(OtpReceiveState(status: OtpReceiveStatus.initial)) {
    on<OtpReceive>(_receivingOtp);
  }

  void _receivingOtp(OtpReceive event, Emitter<OtpReceiveState> emit) async {
    emit(OtpReceiveState.loading());

    final error = await repository.receivingOtp(
      otp: event.otp,
      languageCode: event.languageCode,
      number: event.number,
    );

    if (error == null) {
      emit(OtpReceiveState.success());
    } else {
      emit(OtpReceiveState.failure(error));
    }
  }
}
