import 'dart:convert';
import 'package:flutter/foundation.dart';

String _getPlatformName() {
  if (kIsWeb) return 'web';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'android';
    case TargetPlatform.iOS:
      return 'ios';
    case TargetPlatform.macOS:
      return 'macos';
    case TargetPlatform.windows:
      return 'windows';
    case TargetPlatform.linux:
      return 'linux';
    case TargetPlatform.fuchsia:
      return 'fuchsia';
  }
}

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
    String? platform,
    required this.languageCode,
    required this.pickupLocationUuid,
    required this.dropoffLocationUuid,
    required this.priceSetUuid,
  }) : platform = platform ?? _getPlatformName();

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

class RentalDriverBid {
  final String? rentBidUuid;
  final double? bidAmount;
  final double? totalAmount;
  final double? insuranceChargeAmount;
  final double? customerDiscountAmount;
  final String? driverUuid;
  final String? name;
  final String? email;
  final String? profilePicture;
  final String? countryCode;
  final String? isActive;
  final String? phone;
  final String? bidStatus;
  final bool? hasBid;
  final List<String>? carPhotos;

  RentalDriverBid({
    this.rentBidUuid,
    this.bidAmount,
    this.totalAmount,
    this.insuranceChargeAmount,
    this.customerDiscountAmount,
    this.driverUuid,
    this.name,
    this.email,
    this.profilePicture,
    this.countryCode,
    this.isActive,
    this.phone,
    this.bidStatus,
    this.hasBid,
    this.carPhotos,
  });

  factory RentalDriverBid.fromJson(Map<String, dynamic> json) {
    return RentalDriverBid(
      rentBidUuid: json['rent_bid_uuid'],
      bidAmount: (json['bid_amount'] as num?)?.toDouble(),
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      insuranceChargeAmount: (json['insurance_charge_amount'] as num?)?.toDouble(),
      customerDiscountAmount: (json['customer_discount_amount'] as num?)?.toDouble(),
      driverUuid: json['driver_uuid'],
      name: json['name'],
      email: json['email'],
      profilePicture: json['profile_picture'],
      countryCode: json['country_code'],
      isActive: json['is_active'],
      phone: json['phone']?.toString(),
      bidStatus: json['bid_status'],
      hasBid: json['has_bid'],
      carPhotos: (json['car_photos'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }
}

class RentalBidListResponse {
  final bool? status;
  final String? message;
  final List<RentalDriverBid> drivers;

  RentalBidListResponse({this.status, this.message, this.drivers = const []});

  factory RentalBidListResponse.fromJson(Map<String, dynamic> json) {
    List<RentalDriverBid> parsedDrivers = [];
    final data = json['data'];
    
    if (data is Map<String, dynamic> && data['drivers'] is List) {
      parsedDrivers = (data['drivers'] as List).map((e) => RentalDriverBid.fromJson(e)).toList();
    } else if (data is List) {
      // If data is the list itself (and the driver object is inside)
      try {
        parsedDrivers = data.map((e) => RentalDriverBid.fromJson(e)).toList();
      } catch (_) {}
    } else if (json['drivers'] is List) {
      parsedDrivers = (json['drivers'] as List).map((e) => RentalDriverBid.fromJson(e)).toList();
    }

    return RentalBidListResponse(
      status: json['status'],
      message: json['message'],
      drivers: parsedDrivers,
    );
  }
}
