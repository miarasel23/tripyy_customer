import 'package:equatable/equatable.dart';

abstract class SplashEvent extends Equatable {
  SplashEvent();

  @override
  List<Object> get props => [];
}

class SplashAuthCheck extends SplashEvent {
  final String platform;
  final String languageCode;
  final String actionWhen;
  final String email;
  final String password;

  SplashAuthCheck({
    required this.platform,
    required this.languageCode,
    required this.actionWhen,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [
    platform,
    languageCode,
    actionWhen,
    email,
    password,
  ];
}
