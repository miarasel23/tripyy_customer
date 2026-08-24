import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../../../store/user_data_store.dart';
import '../../../../utils/app_urls.dart';
import '../../searchLocation/repository/search_location_repository.dart';

class CustomerLocationTracker {
  static final CustomerLocationTracker _instance = CustomerLocationTracker._internal();
  static CustomerLocationTracker get instance => _instance;

  CustomerLocationTracker._internal();

  Position? _lastTrackedPosition;

  Position? get lastTrackedPosition => _lastTrackedPosition;

  void resetLastPosition() {
    _lastTrackedPosition = null;
  }

  Future<void> trackCustomerLocationIfNeeded({
    required String customerUuid,
    required String langCode,
    double minDistanceMeters = 5.0,
  }) async {
    if (customerUuid.isEmpty) return;

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (_lastTrackedPosition != null) {
        final distanceInMeters = Geolocator.distanceBetween(
          _lastTrackedPosition!.latitude,
          _lastTrackedPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        if (distanceInMeters < minDistanceMeters) {
          print("[LOCATION TRACKER] Moved ${distanceInMeters.toStringAsFixed(2)}m (< ${minDistanceMeters}m). Skipping API call.");
          return;
        }
      }

      final repo = SearchLocationRepository();
      final query = "${position.latitude},${position.longitude}";
      final searchResponse = await repo.searchLocations(query, langCode);

      if (searchResponse.data != null && searchResponse.data!.isNotEmpty) {
        final geolocationUuid = searchResponse.data!.first.uuid;
        if (geolocationUuid == null || geolocationUuid.isEmpty) return;

        final url = Uri.parse(AppUrls.saveCustomerDriverTrack);
        final token = await UserDataStore.getAccessToken();
        final headers = {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        };
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }

        final body = {
          "platform": "android",
          "language_code": langCode,
          "action_when": "track_location_insert",
          "customer_uuid": customerUuid,
          "geolocation_uuid": geolocationUuid,
        };

        final response = await http.post(url, headers: headers, body: body).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200 || response.statusCode == 201) {
          _lastTrackedPosition = position;
          print("[LOCATION TRACKER] Location tracked successfully to /v1/customer-driver-track/create");
        }
      }
    } catch (e) {
      print("[LOCATION TRACKER] Error tracking customer location: $e");
    }
  }
}
