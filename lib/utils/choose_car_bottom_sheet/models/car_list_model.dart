class CarListModel {
  bool? status;
  String? message;
  List<Data>? data;

  CarListModel({this.status, this.message, this.data});

  CarListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? serviceName;
  String? avatar;
  List<Cars>? cars;

  Data({this.serviceName, this.avatar, this.cars});

  Data.fromJson(Map<String, dynamic> json) {
    serviceName = json['service_name'];
    avatar = json['avatar'];
    if (json['cars'] != null) {
      cars = <Cars>[];
      json['cars'].forEach((v) {
        cars!.add(Cars.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['service_name'] = serviceName;
    data['avatar'] = avatar;
    if (cars != null) {
      data['cars'] = cars!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cars {
  String? uuid;
  String? carType;
  int? setCapacity;
  String? carAvatar;
  List<PriceSets>? priceSets;

  Cars(
      {this.uuid,
      this.carType,
      this.setCapacity,
      this.carAvatar,
      this.priceSets});

  Cars.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    carType = json['car_type'];
    setCapacity = json['set_capacity'];
    carAvatar = json['car_avatar'];
    if (json['price_sets'] != null) {
      priceSets = <PriceSets>[];
      json['price_sets'].forEach((v) {
        priceSets!.add(PriceSets.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uuid'] = uuid;
    data['car_type'] = carType;
    data['set_capacity'] = setCapacity;
    data['car_avatar'] = carAvatar;
    if (priceSets != null) {
      data['price_sets'] = priceSets!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PriceSets {
  String? uuid;
  int? pricePerKm;
  int? minimumBookingPrice;
  int? waitingTime;
  int? waitingPrice;
  int? cancellationFee;
  String? busyStartTime;
  String? busyEndTime;
  int? busyTimePricePercentage;
  String? countryCode;

  PriceSets(
      {this.uuid,
      this.pricePerKm,
      this.minimumBookingPrice,
      this.waitingTime,
      this.waitingPrice,
      this.cancellationFee,
      this.busyStartTime,
      this.busyEndTime,
      this.busyTimePricePercentage,
      this.countryCode});

  PriceSets.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    pricePerKm = json['price_per_km'];
    minimumBookingPrice = json['minimum_booking_price'];
    waitingTime = json['waiting_time'];
    waitingPrice = json['waiting_price'];
    cancellationFee = json['cancellation_fee'];
    busyStartTime = json['busy_start_time'];
    busyEndTime = json['busy_end_time'];
    busyTimePricePercentage = json['busy_time_price_percentage'];
    countryCode = json['country_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uuid'] = uuid;
    data['price_per_km'] = pricePerKm;
    data['minimum_booking_price'] = minimumBookingPrice;
    data['waiting_time'] = waitingTime;
    data['waiting_price'] = waitingPrice;
    data['cancellation_fee'] = cancellationFee;
    data['busy_start_time'] = busyStartTime;
    data['busy_end_time'] = busyEndTime;
    data['busy_time_price_percentage'] = busyTimePricePercentage;
    data['country_code'] = countryCode;
    return data;
  }
}
