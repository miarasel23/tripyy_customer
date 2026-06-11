import 'package:equatable/equatable.dart';

import '../../enums.dart';
import '../models/car_list_model.dart';

class ChooseCarBottomSheetState extends Equatable {
  final String? currentCarIndex;
  final bool? clicked;
  final ChooseCarBottomSheetStatus? status;
  final CarListModel? cars;
  final String? error;

  ChooseCarBottomSheetState({
    this.error,
    this.currentCarIndex,
    this.clicked,
    this.status = ChooseCarBottomSheetStatus.initial,
    this.cars,
  });

  ChooseCarBottomSheetState copyWith({
    String? selectedCarIndex,
    bool? clicked,
    ChooseCarBottomSheetStatus? status,
    CarListModel? cars,
    final String? error,
  }) {
    return ChooseCarBottomSheetState(
      currentCarIndex: selectedCarIndex ?? currentCarIndex,
      clicked: clicked ?? this.clicked,
      status: status ?? this.status,
      cars: cars ?? this.cars,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [currentCarIndex, clicked, status, cars, error];
}
