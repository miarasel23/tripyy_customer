import '../model/create_rental_trip_model.dart';

abstract class ActiveTripState {}

class ActiveTripInitial extends ActiveTripState {}

class ActiveTripLoading extends ActiveTripState {}

class ActiveTripSuccess extends ActiveTripState {
  final RentalTrip activeTrip;
  ActiveTripSuccess(this.activeTrip);
}

class ActiveTripFailure extends ActiveTripState {
  final String error;
  ActiveTripFailure(this.error);
}

class NoActiveTrip extends ActiveTripState {
  final String message;
  NoActiveTrip(this.message);
}

class ActiveTripCancelledSuccess extends ActiveTripState {
  final String message;
  ActiveTripCancelledSuccess(this.message);
}
