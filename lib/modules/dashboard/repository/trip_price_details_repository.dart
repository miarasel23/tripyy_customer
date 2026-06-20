import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../utils/app_urls.dart';
import '../models/trip_price_details_model.dart';

import '../../../../store/user_data_store.dart';

class TripPriceDetailsRepository {
  Future<TripPriceDetailsResponse> getTripPriceDetails(TripPriceDetailsRequest request) async {
    try {
      final token = await UserDataStore.getAccessToken();
      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      print("Request: ${request.toJson()}");

      final response = await http.post(
        Uri.parse(AppUrls.tripPriceDetailsCustomer),
        headers: headers,
        body: request.toJson(),
      );
     print(response.body);
      if (response.statusCode == 200) {
        return TripPriceDetailsResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to load trip price details: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
