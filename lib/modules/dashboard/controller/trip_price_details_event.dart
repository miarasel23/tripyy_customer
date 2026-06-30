import 'package:equatable/equatable.dart';
import '../models/trip_price_details_model.dart';
import '../../choose_car_bottom_sheet/models/choose_car_model.dart';

abstract class TripPriceDetailsEvent extends Equatable {
  const TripPriceDetailsEvent();

  @override
  List<Object?> get props => [];
}

class FetchTripPriceDetails extends TripPriceDetailsEvent {
  final TripPriceDetailsRequest request;
  final List<Car> defaultCars;
  final String serviceKey;
  final List<String> pickupAddresses;
  final List<String> dropoffAddresses;
  final String? hoursBooked;

  const FetchTripPriceDetails({
    required this.request,
    required this.defaultCars,
    required this.serviceKey,
    required this.pickupAddresses,
    required this.dropoffAddresses,
    this.hoursBooked,
  });

  @override
  List<Object?> get props => [request, defaultCars, serviceKey, pickupAddresses, dropoffAddresses, hoursBooked];
}
