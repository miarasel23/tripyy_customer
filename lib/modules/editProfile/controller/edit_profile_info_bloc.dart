import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/enums.dart';
import '../repository/edit_profile_repository.dart';
import 'edit_profile_info_event.dart';
import 'edit_profile_info_state.dart';

class EditProfileInfoBloc
    extends Bloc<EditProfileEvent, EditProfileUpdateState> {
  final EditProfileRepository repository;

  EditProfileInfoBloc({required this.repository})
    : super(EditProfileUpdateState()) {
    on<EditProfileInfo>(_updatingProfile);
  }

  void _updatingProfile(
    EditProfileInfo event,
    Emitter<EditProfileUpdateState> emit,
  ) async {
    emit(state.copyWith(status: EditProfileUpdateStatus.loading));

    final error = await repository.editingInfo(
      languageCode: event.languageCode,
      number: event.phoneNumber,
      fullName: event.fullName,
      email: event.email,
    );

    if (error == null) {
      emit(state.copyWith(status: EditProfileUpdateStatus.success));
    } else {
      emit(
        state.copyWith(
          status: EditProfileUpdateStatus.failure,
          errorMessage: error,
        ),
      );
    }
  }
}
