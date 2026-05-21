import 'package:equatable/equatable.dart';

abstract class MyTripEvent extends Equatable {
  const MyTripEvent();
  @override
  List<Object> get props => [];
}

class ChangePackageEvent extends MyTripEvent {
  final int index;

  ChangePackageEvent({required this.index});
}
