import 'package:equatable/equatable.dart';

class MyTripState extends Equatable {
  final int selectedIndex;

  MyTripState({required this.selectedIndex});

  MyTripState copyWith({int? selectedIndex}) {
    return MyTripState(selectedIndex: selectedIndex ?? this.selectedIndex);
  }

  @override
  List<Object?> get props => [selectedIndex];
}
