import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class ChangeLanguageEvent {
  final String languageCode;
  ChangeLanguageEvent(this.languageCode);
}

class LocalizationState {
  final Locale locale;
  LocalizationState({required this.locale});
}

class LocalizationBloc extends Bloc<ChangeLanguageEvent, LocalizationState> {
  LocalizationBloc() : super(LocalizationState(locale: const Locale('en'))) {
    on<ChangeLanguageEvent>((event, emit) {
      emit(LocalizationState(locale: Locale(event.languageCode)));
    });
  }
}
