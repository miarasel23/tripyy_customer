import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/create_trip_repository.dart';
import '../model/create_rental_trip_model.dart';
import '../model/trip_status.dart';
import 'active_trip_event.dart';
import 'active_trip_state.dart';

class ActiveTripBloc extends Bloc<ActiveTripEvent, ActiveTripState> {
  final CreateTripRepository _repo = CreateTripRepository();
  Timer? _pollingTimer;

  ActiveTripBloc() : super(ActiveTripInitial()) {
    on<FetchActiveTrip>((event, emit) async {
      try {
        final response = await _repo.fetchBids(
          customerUuid: event.customerUuid,
          langCode: event.languageCode,
          tripStatus: TripStatus.all,
        );

        if (response.trips.isNotEmpty) {
          final activeStatuses = [
            TripStatus.accepted,
            TripStatus.booked,
            TripStatus.arrivedPickupLocation,
            TripStatus.rideStarted,
            TripStatus.inProgress,
            TripStatus.firstCompleted,
            TripStatus.completed,
          ];
          final found = response.trips.where((t) => activeStatuses.contains(t.tripStatus)).toList();

          if (found.isNotEmpty) {
            final activeTrip = found.first;
            emit(ActiveTripSuccess(activeTrip));

            // Stop polling once terminal state is reached
            final terminalStatuses = [TripStatus.completed, TripStatus.cancelled];
            if (terminalStatuses.contains(activeTrip.tripStatus)) {
              _pollingTimer?.cancel();
            }
          } else {
            emit(NoActiveTrip("No active trip found."));
          }
        } else {
          emit(NoActiveTrip("No active trip found."));
        }
      } catch (e) {
        emit(ActiveTripFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<StartActiveTripPolling>((event, emit) {
      _pollingTimer?.cancel();
      _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        add(FetchActiveTrip(
          customerUuid: event.customerUuid,
          languageCode: event.languageCode,
        ));
      });
    });

    on<StopActiveTripPolling>((event, emit) {
      _pollingTimer?.cancel();
    });

    on<CancelActiveTrip>((event, emit) async {
      try {
        final response = await _repo.cancelTrip(
          tripUuid: event.tripUuid,
          comment: event.comment,
          langCode: event.languageCode,
        );
        _pollingTimer?.cancel();
        emit(ActiveTripCancelledSuccess(response['message'] ?? "Trip cancelled successfully."));
      } catch (e) {
        emit(ActiveTripFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<UpdateActiveTripLocalReview>((event, emit) {
      if (state is ActiveTripSuccess) {
        emit(ActiveTripSuccess(event.updatedTrip));
      }
    });
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
