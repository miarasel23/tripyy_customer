import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/enums.dart';
import '../repository/edit_profile_repository.dart';
import 'edit_profile_event.dart';
import 'edit_profile_state.dart';

class EditProfilePictureBloc
    extends Bloc<EditProfilePictureEvent, EditProfilePictureState> {
  final EditProfilePictureRepository repository;

  EditProfilePictureBloc({required this.repository})
    : super(EditProfilePictureState()) {
    on<EditProfilePicture>(_editingProfilePicture);
    on<UpdateProfileInfo>(_updatingProfile);
  }

  void _editingProfilePicture(
    EditProfilePicture event,
    Emitter<EditProfilePictureState> emit,
  ) async {
    emit(state.copyWith(status: EditProfilePictureStatus.loading));

    final error = await repository.uploadProfilePicture(
      imageFile: event.imageFile,
      languageCode: event.languageCode,
      plaform: event.platform,
      actionWhen: event.actionWhen,
      email: event.email,
      password: event.password,
    );

    if (error == null) {
      emit(
        state.copyWith(
          status: EditProfilePictureStatus.success,
          avatar: event.imageFile,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: EditProfilePictureStatus.failure,
          errorMessage: error,
        ),
      );
    }
  }

  void _updatingProfile(
    UpdateProfileInfo event,
    Emitter<EditProfilePictureState> emit,
  ) async {
    emit(state.copyWith(status: EditProfilePictureStatus.loading));

    final error = await repository.editingInfo(
      languageCode: event.languageCode,
      number: event.phoneNumber,
      fullName: event.fullName,
      email: event.email,
    );

    if (error == null) {
      emit(state.copyWith(status: EditProfilePictureStatus.success));
    } else {
      emit(
        state.copyWith(
          status: EditProfilePictureStatus.failure,
          errorMessage: error,
        ),
      );
    }
  }
}
