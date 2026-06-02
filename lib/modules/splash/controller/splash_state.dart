import 'package:equatable/equatable.dart';

import '../../../utils/enums.dart';
class SplashState extends Equatable {
  final SplashStatus status;

  final String? platform;
  final String? languageCode;
  final String? actionWhen;
  final String? email;
  final String? password;

  final String? errorMessage;

  const SplashState({
    this.status = SplashStatus.initial,
    this.platform,
    this.languageCode,
    this.actionWhen,
    this.email,
    this.password,
    this.errorMessage,
  });

  SplashState copyWith({
    SplashStatus? status,
    String? platform,
    String? languageCode,
    String? actionWhen,
    String? email,
    String? password,
    String? errorMessage,
  }) {
    return SplashState(
      status: status ?? this.status,
      platform: platform ?? this.platform,
      languageCode: languageCode ?? this.languageCode,
      actionWhen: actionWhen ?? this.actionWhen,
      email: email ?? this.email,
      password: password ?? this.password,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        platform,
        languageCode,
        actionWhen,
        email,
        password,
        errorMessage,
      ];
}