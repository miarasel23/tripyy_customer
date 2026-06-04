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
  List<Object?> get props => [imageFile, languageCode];
}
