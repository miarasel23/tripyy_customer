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
  }

  void _editingProfilePicture(
    EditProfilePicture event,
    Emitter<EditProfilePictureState> emit,
  ) async {
    emit(state.copyWith(status: EditProfilePictureStatus.loading));

    final error = await repository.uploadProfilePicture(
      event.imageFile,
      event.languageCode,
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
