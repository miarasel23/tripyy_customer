import 'package:flutter_bloc/flutter_bloc.dart';

import 'my_trip_event.dart';
import 'my_trip_state.dart';

class MyTripBloc extends Bloc<MyTripEvent, MyTripState> {
  MyTripBloc() : super(MyTripState(selectedIndex: 0)) {
    on<ChangePackageEvent>(_changingPackage);
  }

  void _changingPackage(ChangePackageEvent event, Emitter<MyTripState> emit) {
    emit(state.copyWith(selectedIndex: event.index));
  }
}
