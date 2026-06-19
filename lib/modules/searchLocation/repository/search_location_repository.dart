import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../utils/app_urls.dart';
import '../models/search_location_model.dart';

class SearchLocationRepository {
  Future<SearchLocationResponse> searchLocations(String query, String languageCode) async {
    String platform = "web";
    if (Platform.isAndroid) {
      platform = "android";
    } else if (Platform.isIOS) {
      platform = "ios";
    }

    try {
      final response = await http.post(
        Uri.parse(AppUrls.searchLocation),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          "platform": platform,
          "language_code": languageCode,
          "action_when": "search_locations",
          "search_location": query,
        },
      );

      if (response.statusCode == 200) {
        return SearchLocationResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to load locations");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
