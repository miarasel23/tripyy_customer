
import 'package:equatable/equatable.dart';

abstract class EditProfileEvent extends Equatable {
  EditProfileEvent();

  @override
  List<Object?> get props => [];
}

class EditProfileInfo extends EditProfileEvent {
  final String languageCode;
  final String phoneNumber;
  final String fullName;
  final String email;
  final String? nidNumber;

  EditProfileInfo({
    required this.languageCode,
    required this.email,
    required this.phoneNumber,
    required this.fullName,
    this.nidNumber,
  });

  @override
  List<Object?> get props => [
    languageCode,
    email,
    phoneNumber,
    fullName,
    nidNumber,
  ];
}
