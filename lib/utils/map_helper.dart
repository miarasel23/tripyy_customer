import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'app_urls.dart';

class MapHelper {
  /// Fetches a formatted address for a given coordinate using Google Maps Geocoding API
  static Future<String?> getGoogleGeocode(LatLng position) async {
    try {
      final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${AppUrls.googleMapApiKey}';
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

  /// Fetches route coordinates between two points using Google Maps Directions API
  static Future<List<LatLng>> getRouteCoordinates(LatLng from, LatLng to) async {
    final polylinePoints = PolylinePoints();
    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: AppUrls.googleMapApiKey,
      request: PolylineRequest(
        origin: PointLatLng(from.latitude, from.longitude),
        destination: PointLatLng(to.latitude, to.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      return result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    }
    
    return [];
  }
}
