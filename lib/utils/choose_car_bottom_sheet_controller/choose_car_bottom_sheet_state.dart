import 'package:equatable/equatable.dart';

class ChooseCarBottomSheetState extends Equatable {
  final String? currentCarIndex;
  final bool? clicked;

  ChooseCarBottomSheetState({this.currentCarIndex, required this.clicked});

  ChooseCarBottomSheetState copyWith({String? selectedCarIndex, bool? clicked}) {
    return ChooseCarBottomSheetState(
      currentCarIndex: selectedCarIndex ?? currentCarIndex,
      clicked: clicked ?? this.clicked,
    );
  }

  @override
  List<Object?> get props => [currentCarIndex, clicked];
}
