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

  EditProfilePicture({required this.imageFile, required this.languageCode});

  @override
  List<Object?> get props => [imageFile, languageCode];
}
