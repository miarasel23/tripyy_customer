class Car {
  final String uuid;
  final String carType;
  final int setCapacity;
  final String? carAvatar;
  final num? minimumBookingPrice;
  final String? distance;
  final String? priceSetUuid;

  Car({
    required this.uuid,
    required this.carType,
    required this.setCapacity,
    this.carAvatar,
    this.minimumBookingPrice,
    this.distance,
    this.priceSetUuid,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    num? minPrice;
    if (json['rent_calculation'] != null && json['rent_calculation'] is Map) {
      minPrice = json['rent_calculation']['minimum_booking_price'];
    } else if (json['minimum_booking_price'] != null) {
      minPrice = json['minimum_booking_price'];
    } else if (json['price_sets'] != null && json['price_sets'] is List && (json['price_sets'] as List).isNotEmpty) {
      minPrice = json['price_sets'][0]?['minimum_booking_price'];
    }

    String? parsedDistance;
    if (json['distance'] is Map) {
      parsedDistance = json['distance']['total_km']?.toString();
    } else {
      parsedDistance = json['distance']?.toString();
    }

    String? priceSetUuid;
    if (json['price_sets'] != null && json['price_sets'] is List && (json['price_sets'] as List).isNotEmpty) {
      priceSetUuid = json['price_sets'][0]?['uuid']?.toString();
    }

    return Car(
      uuid: json['uuid']?.toString() ?? '',
      carType: json['car_type']?.toString() ?? '',
      setCapacity: json['set_capacity'] is int
          ? json['set_capacity'] as int
          : int.tryParse('${json['set_capacity']}') ?? 0,
      carAvatar: json['car_avatar']?.toString(),
      minimumBookingPrice: minPrice,
      distance: parsedDistance,
      priceSetUuid: priceSetUuid,
    );
  }
}

class ServiceGroup {
  final String serviceName;
  final String? avatar;
  final List<Car> cars;

  ServiceGroup({
    required this.serviceName,
    this.avatar,
    required this.cars,
  });

  factory ServiceGroup.fromJson(Map<String, dynamic> json) {
    return ServiceGroup(
      serviceName: json['service_name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      cars: json['cars'] is List
          ? (json['cars'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => Car.fromJson(e))
              .toList()
          : [],
    );
  }
}

class ServiceResponse {
  final Map<String, ServiceGroup> groups;

  ServiceResponse({required this.groups});

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, ServiceGroup> services = {};

    if (json['data'] is Map<String, dynamic>) {
      (json['data'] as Map<String, dynamic>).forEach((key, value) {
        if (value is Map<String, dynamic>) {
          services[key] = ServiceGroup.fromJson(value);
        }
      });
    }

    return ServiceResponse(groups: services);
  }
}



// children: [
//         GestureDetector(
//           onTap: () {
//             showModalBottomSheet(
//               context: context,
//               isScrollControlled: true,
//               builder: (BuildContext context) {
//                 return FractionallySizedBox(
//                   heightFactor: 0.845,
//                   child: const ChooseCarBottomSheet(),
//                 );
//               },
//             );
//           },
//           child: serviceWidget(
//             icon: Icon(
//               Icons.car_crash,
//               size: 70,
//               color: Theme.of(context).colorScheme.onSurface,
//             ),
//             label: loc.translate('intercity'),
//             context: context,
//           ),
//         ),
//         GestureDetector(
//           onTap: () {},
//           child: serviceWidget(
//             icon: Icon(
//               Icons.car_crash,
//               size: 70,
//               color: Theme.of(context).colorScheme.onSurface,
//             ),
//             label: loc.translate('hourly'),
//             context: context,
//           ),
//         ),
//         GestureDetector(
//           onTap: () {},
//           child: serviceWidget(
//             icon: Icon(
//               Icons.car_crash,
//               size: 70,
//               color: Theme.of(context).colorScheme.onSurface,
//             ),
//             label: loc.translate('airport_rental'),
//             context: context,
//           ),
//         ),
//         GestureDetector(
//           onTap: () {},
//           child: serviceWidget(
//             icon: Icon(
//               Icons.car_crash,
//               size: 70,
//               color: Theme.of(context).colorScheme.onSurface,
//             ),
//             label: loc.translate('return_trip'),
//             context: context,
//           ),
//         ),
//         GestureDetector(
//           onTap: () {},
//           child: serviceWidget(
//             icon: Icon(
//               Icons.car_crash,
//               size: 70,
//               color: Theme.of(context).colorScheme.onSurface,
//             ),
//             label: loc.translate('ride_share'),
//             context: context,
//           ),
//         ),
//       ],