import 'dart:convert';
import 'package:flutter/foundation.dart';

String _getPlatformName() {
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
  final String? note;
  final String? offerAmount;

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
    this.note,
    this.offerAmount,
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

    if (note != null && note!.isNotEmpty) {
      data['note'] = note;
    }

    if (offerAmount != null && offerAmount!.isNotEmpty) {
      data['offer_ammount'] = offerAmount;
    }

    return data;
  }
}

class RatingModel {
  final String? uuid;
  final int? rating;
  final String? comments;
  final String? customerName;
  final String? customerPhoto;
  final String? createdAt;

  RatingModel({
    this.uuid,
    this.rating,
    this.comments,
    this.customerName,
    this.customerPhoto,
    this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      uuid: json['uuid'],
      rating: json['rating'],
      comments: json['comments'],
      customerName: json['customer_name'],
      customerPhoto: json['customer_photo'],
      createdAt: json['created_at'],
    );
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
  final int? totalCompletedTrips;
  final double? averageRating;
  final List<RatingModel>? ratingList;
  final String? carRegNumber;

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
    this.totalCompletedTrips,
    this.averageRating,
    this.ratingList,
    this.carRegNumber,
  });

  factory RentalDriverBid.fromJson(Map<String, dynamic> json) {
    return RentalDriverBid(
      rentBidUuid: json['rent_bid_uuid']?.toString() ?? json['bid_uuid']?.toString() ?? json['uuid']?.toString(),
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
      totalCompletedTrips: json['total_completed_trips'] as int?,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      ratingList: (json['rating_list'] as List<dynamic>?)?.map((e) => RatingModel.fromJson(e)).toList(),
      carRegNumber: json['car_reg_number']?.toString(),
    );
  }
}

class LocationModel {
  final String? uuid;
  final String? address;
  final String? latitude;
  final String? longitude;
  final String? placeId;
  
  LocationModel({
    this.uuid, 
    this.address,
    this.latitude,
    this.longitude,
    this.placeId,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      uuid: json['uuid']?.toString(),
      address: json['address']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      placeId: json['place_id']?.toString(),
    );
  }
}

class CarCategoryModel {
  final String? carType;
  final String? carAvatar;
  final String? setCapacity;

  CarCategoryModel({this.carType, this.carAvatar, this.setCapacity});

  factory CarCategoryModel.fromJson(Map<String, dynamic> json) {
    return CarCategoryModel(
      carType: json['car_type'],
      carAvatar: json['car_avatar'],
      setCapacity: json['set_capacity']?.toString() ?? json['seat_capacity']?.toString(),
    );
  }
}

class PriceInfoModel {
  final double? minimumBookingPrice;
  final double? pricePerKm;

  PriceInfoModel({this.minimumBookingPrice, this.pricePerKm});

  factory PriceInfoModel.fromJson(Map<String, dynamic> json) {
    return PriceInfoModel(
      minimumBookingPrice: (json['minimum_booking_price'] as num?)?.toDouble(),
      pricePerKm: (json['price_per_km'] as num?)?.toDouble(),
    );
  }
}

class SeenDriverModel {
  final String? driverUuid;
  final String? name;
  final String? profilePicture;
  final String? createdAt;

  SeenDriverModel({
    this.driverUuid,
    this.name,
    this.profilePicture,
    this.createdAt,
  });

  factory SeenDriverModel.fromJson(Map<String, dynamic> json) {
    return SeenDriverModel(
      driverUuid: json['driver_uuid']?.toString(),
      name: json['name']?.toString(),
      profilePicture: json['profile_picture']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class RentalTrip {
  final int? id;
  final String? uuid;
  final String? serviceName;
  final CarCategoryModel? carCategory;
  final PriceInfoModel? priceInfo;
  final List<LocationModel> pickupLocations;
  final List<LocationModel> dropoffLocations;
  final List<RentalDriverBid> drivers;
  final double? offerAmount;
  final int? totalBids;
  final String? tripStatus;
  final String? paymentMethod;
  final String? startDatetime;
  final String? endDatetime;
  final String? createdAt;
  final String? countryCode;
  final bool? givenReview;
  final BidSummaryModel? bidSummary;
  final int? seenDriverCount;
  final List<SeenDriverModel> seenDrivers;
  final List<String> seenDriverPhotos;
  final int? hoursBooked;

  RentalTrip({
    this.id,
    this.uuid,
    this.serviceName,
    this.carCategory,
    this.priceInfo,
    this.pickupLocations = const [],
    this.dropoffLocations = const [],
    this.drivers = const [],
    this.offerAmount,
    this.totalBids,
    this.tripStatus,
    this.paymentMethod,
    this.startDatetime,
    this.endDatetime,
    this.createdAt,
    this.countryCode,
    this.givenReview,
    this.bidSummary,
    this.seenDriverCount,
    this.seenDrivers = const [],
    this.seenDriverPhotos = const [],
    this.hoursBooked,
  });

  factory RentalTrip.fromJson(Map<String, dynamic> json) {
    return RentalTrip(
      id: json['id'],
      uuid: json['uuid'],
      serviceName: json['service_name'],
      carCategory: json['car_category'] != null ? CarCategoryModel.fromJson(json['car_category']) : null,
      priceInfo: json['price_info'] != null ? PriceInfoModel.fromJson(json['price_info']) : null,
      pickupLocations: (json['pickup_locations'] as List<dynamic>?)?.map((e) => LocationModel.fromJson(e)).toList() ?? [],
      dropoffLocations: (json['dropoff_locations'] as List<dynamic>?)?.map((e) => LocationModel.fromJson(e)).toList() ?? [],
      drivers: (json['drivers'] as List<dynamic>?)?.map((e) => RentalDriverBid.fromJson(e)).toList() ?? [],
      offerAmount: (json['offer_amount'] as num?)?.toDouble() ?? (json['offer_ammount'] as num?)?.toDouble(),
      totalBids: json['total_bids'] as int?,
      tripStatus: json['trip_status']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      startDatetime: json['start_datetime']?.toString(),
      endDatetime: json['end_datetime']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? json['created_time']?.toString() ?? json['start_datetime']?.toString(),
      countryCode: json['country_code']?.toString() ?? json['countryCode']?.toString(),
      givenReview: (json['given_review'] == true || json['given_review'] == 'true' || json['given_review'] == 1)
          ? true
          : ((json['given_review'] == false || json['given_review'] == 'false' || json['given_review'] == 0) ? false : null),
      bidSummary: json['bid_summary'] != null ? BidSummaryModel.fromJson(json['bid_summary']) : null,
      seenDriverCount: json['seen_driver_count'] as int?,
      seenDrivers: (json['seen_drivers'] as List<dynamic>?)?.map((e) => SeenDriverModel.fromJson(e)).toList() ?? [],
      seenDriverPhotos: (json['seen_driver_photos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      hoursBooked: json['hours_booked'] != null
          ? (double.tryParse(json['hours_booked'].toString())?.round() ?? int.tryParse(json['hours_booked'].toString()))
          : (json['hoursBooked'] != null
              ? (double.tryParse(json['hoursBooked'].toString())?.round() ?? int.tryParse(json['hoursBooked'].toString()))
              : (json['hours_package'] != null
                  ? (double.tryParse(json['hours_package'].toString())?.round() ?? int.tryParse(json['hours_package'].toString()))
                  : null)),
    );
  }

  RentalTrip copyWith({
    int? id,
    String? uuid,
    String? serviceName,
    CarCategoryModel? carCategory,
    PriceInfoModel? priceInfo,
    List<LocationModel>? pickupLocations,
    List<LocationModel>? dropoffLocations,
    List<RentalDriverBid>? drivers,
    double? offerAmount,
    int? totalBids,
    String? tripStatus,
    String? paymentMethod,
    String? startDatetime,
    String? endDatetime,
    bool? givenReview,
    BidSummaryModel? bidSummary,
    int? seenDriverCount,
    List<SeenDriverModel>? seenDrivers,
    List<String>? seenDriverPhotos,
    int? hoursBooked,
  }) {
    return RentalTrip(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      serviceName: serviceName ?? this.serviceName,
      carCategory: carCategory ?? this.carCategory,
      priceInfo: priceInfo ?? this.priceInfo,
      pickupLocations: pickupLocations ?? this.pickupLocations,
      dropoffLocations: dropoffLocations ?? this.dropoffLocations,
      drivers: drivers ?? this.drivers,
      offerAmount: offerAmount ?? this.offerAmount,
      totalBids: totalBids ?? this.totalBids,
      tripStatus: tripStatus ?? this.tripStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      startDatetime: startDatetime ?? this.startDatetime,
      endDatetime: endDatetime ?? this.endDatetime,
      givenReview: givenReview ?? this.givenReview,
      bidSummary: bidSummary ?? this.bidSummary,
      seenDriverCount: seenDriverCount ?? this.seenDriverCount,
      seenDrivers: seenDrivers ?? this.seenDrivers,
      seenDriverPhotos: seenDriverPhotos ?? this.seenDriverPhotos,
      hoursBooked: hoursBooked ?? this.hoursBooked,
    );
  }
}

class BidSummaryModel {
  final double? lowestBidAmount;
  final double? highestBidAmount;
  final int? totalBids;

  BidSummaryModel({
    this.lowestBidAmount,
    this.highestBidAmount,
    this.totalBids,
  });

  factory BidSummaryModel.fromJson(Map<String, dynamic> json) {
    return BidSummaryModel(
      lowestBidAmount: (json['lowest_bid_amount'] as num?)?.toDouble(),
      highestBidAmount: (json['highest_bid_amount'] as num?)?.toDouble(),
      totalBids: json['total_bids'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lowest_bid_amount': lowestBidAmount,
      'highest_bid_amount': highestBidAmount,
      'total_bids': totalBids,
    };
  }
}

class RentalBidListResponse {
  final bool? status;
  final String? message;
  final List<RentalTrip> trips;

  RentalBidListResponse({this.status, this.message, this.trips = const []});

  factory RentalBidListResponse.fromJson(Map<String, dynamic> json) {
    List<RentalTrip> parsedTrips = [];
    final data = json['data'];
    
    if (data is List) {
      parsedTrips = data.map((e) => RentalTrip.fromJson(e)).toList();
    } else if (data is Map<String, dynamic>) {
      parsedTrips = [RentalTrip.fromJson(data)];
    }

    return RentalBidListResponse(
      status: json['status'],
      message: json['message'],
      trips: parsedTrips,
    );
  }
}
