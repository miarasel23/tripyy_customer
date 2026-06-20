import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../../../../utils/app_urls.dart';

class MapHelper {
  /// Fallback Google Maps Geocoding API if native fails
  static Future<String?> getGoogleGeocode(LatLng position) async {
    try {
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${AppUrls.googleApiKey}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
    } catch (_) {}
    return null;
  }

  /// Get polyline points between two locations
  static Future<Set<Polyline>> getRouteBetweenCoordinates(
      LatLng from, LatLng to) async {
    final polylinePoints = PolylinePoints();
    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: AppUrls.googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(from.latitude, from.longitude),
        destination: PointLatLng(to.latitude, to.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      final coords =
          result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
      return {
        Polyline(
          polylineId: const PolylineId('route'),
          points: coords,
          color: Colors.blue,
          width: 5,
        ),
      };
    }
    return {};
  }
}
