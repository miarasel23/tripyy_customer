import 'dart:convert';

class CreateRentalTripRequest {
  final String serviceType;
  final String? hoursBooked;
  final String startDatetime;
  final String? endDatetime;
  final String paymentMethod;
  final String customerUuid;
  final String countryCode;
  final String actionWhen;
  final String platform;
  final String languageCode;
  final List<String> pickupLocationUuid;
  final List<String> dropoffLocationUuid;
  final String priceSetUuid;

  CreateRentalTripRequest({
    required this.serviceType,
    this.hoursBooked,
    required this.startDatetime,
    this.endDatetime,
    this.paymentMethod = "CASH",
    required this.customerUuid,
    this.countryCode = "BD",
    this.actionWhen = "create_rental_trip",
    this.platform = "web",
    required this.languageCode,
    required this.pickupLocationUuid,
    required this.dropoffLocationUuid,
    required this.priceSetUuid,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'service_name': serviceType,
      'start_datetime': startDatetime,
      'payment_method': paymentMethod,
      'customer_uuid': customerUuid,
      'country_code': countryCode,
      'action_when': actionWhen,
      'platform': platform,
      'language_code': languageCode,
      'pickup_location_uuid': jsonEncode(pickupLocationUuid),
      'dropoff_location_uuid': jsonEncode(dropoffLocationUuid),
      'price_set_uuid': priceSetUuid,
    };

    if (hoursBooked != null && serviceType == "HOURLY") {
      data['hours_booked'] = hoursBooked;
    }

    if (endDatetime != null && serviceType == "RETURN") {
      data['end_datetime'] = endDatetime;
    }

    return data;
  }
}

class RentalBidListResponse {
  final bool? status;
  final String? message;
  final dynamic data;

  RentalBidListResponse({this.status, this.message, this.data});

  factory RentalBidListResponse.fromJson(Map<String, dynamic> json) {
    return RentalBidListResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'],
    );
  }
}
