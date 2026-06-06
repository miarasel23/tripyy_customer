import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class EditProfilePictureEvent extends Equatable {
  EditProfilePictureEvent();

  @override
  List<Object?> get props => [];
}

class EditProfilePicture extends EditProfilePictureEvent {
  final File imageFile;
  final String languageCode;
  final String actionWhen;
  final String email;
  final String password;
  final String platform;

  EditProfilePicture({
    required this.imageFile,
    required this.languageCode,
    required this.actionWhen,
    required this.email,
    required this.password,
    required this.platform,
  });

  @override
  List<Object?> get props => [
    imageFile,
    languageCode,
    actionWhen,
    email,
    password,
    platform,
  ];
}

class UpdateProfileInfo extends EditProfilePictureEvent {
  final String languageCode;
  final String phoneNumber;
  final String fullName;
  final String email;
  final String password;

  UpdateProfileInfo({
    required this.languageCode,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.fullName,
  });

  @override
  List<Object?> get props => [
    languageCode,
    email,
    password,
    phoneNumber,
    fullName,
  ];
}
