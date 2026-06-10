import 'package:flutter_bloc/flutter_bloc.dart';

import 'choose_car_bottom_sheet_events.dart';
import 'choose_car_bottom_sheet_state.dart';

class ChooseCarBottomSheetBloc
    extends Bloc<ChooseCarBottomSheetEvents, ChooseCarBottomSheetState> {
  ChooseCarBottomSheetBloc() : super(ChooseCarBottomSheetState(clicked: false)) {
    on<ChooseCar>(_choosingCar);
  }

  void _choosingCar(
    ChooseCar event,
    Emitter<ChooseCarBottomSheetState> emit,
  ) async {
    emit(
      state.copyWith(selectedCarIndex: event.selectedCarIndex, clicked: true),
    );
  }
}
