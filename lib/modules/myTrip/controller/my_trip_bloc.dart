import 'package:flutter_bloc/flutter_bloc.dart';

import 'my_trip_event.dart';
import 'my_trip_state.dart';
import '../repository/my_trip_repository.dart';

class MyTripBloc extends Bloc<MyTripEvent, MyTripState> {
  final MyTripRepository _repository = MyTripRepository();

  MyTripBloc() : super(MyTripState(selectedIndex: 0)) {
    on<ChangePackageEvent>(_changingPackage);
    on<FetchTripsEvent>(_fetchTrips);
  }

  void _changingPackage(ChangePackageEvent event, Emitter<MyTripState> emit) {
    emit(state.copyWith(
      selectedIndex: event.index,
      isLoading: true,
      errorMessage: '',
    ));
  }

  Future<void> _fetchTrips(FetchTripsEvent event, Emitter<MyTripState> emit) async {
    if (!event.isSilent) {
      emit(state.copyWith(
        isLoading: true,
        errorMessage: '',
        requestedTrips: const [],
        acceptedTrips: const [],
        historyTrips: const [],
      ));
    }
    try {
      final response = await _repository.fetchTrips(event.tripStatus, event.languageCode);
      final trips = response.trips;

      if (event.tripStatus == "ACCEPTED") {
        emit(state.copyWith(isLoading: false, acceptedTrips: trips));
      } else if (event.tripStatus == "HISTORY") {
        emit(state.copyWith(isLoading: false, historyTrips: trips));
      } else {
        // REQUESTED or ALL — show all returned trips in Requested tab
        emit(state.copyWith(isLoading: false, requestedTrips: trips));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
