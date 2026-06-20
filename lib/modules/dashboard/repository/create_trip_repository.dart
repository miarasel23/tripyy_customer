import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../store/user_data_store.dart';
import '../../../../utils/app_urls.dart';
import '../models/create_rental_trip_model.dart';

class CreateTripRepository {
  Future<Map<String, dynamic>> createRentalTrip(CreateRentalTripRequest request) async {
    try {
      final url = Uri.parse('${AppUrls.baseUrl}/v1/rental-trip/create-rental-trip');
      
      final Map<String, String> formFields = request.toJson().map((key, value) => MapEntry(key, value.toString()));

      debugPrint("Creating rental trip with form payload: $formFields");

      final token = await UserDataStore.getAccessToken();
      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      print("header: $headers");
      print("formFields: $formFields");

      final response = await http.post(
        url,
        headers: headers,
        body: formFields,
      );

      debugPrint("Create trip response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == false) {
          throw Exception(decoded['message'] ?? "Unknown server error");
        }
        return decoded;
      } else {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded['message'] != null) {
            throw Exception(decoded['message']);
          }
        } catch (_) {}
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error creating rental trip: $e");
      rethrow;
    }
  }

  Future<RentalBidListResponse> fetchBids({
    required String customerUuid,
    required String langCode,
    String platform = "web",
    String tripStatus = "REQUESTED",
  }) async {
    try {
      final queryParams = {
        'platform': platform,
        'language_code': langCode,
        'action_when': 'rental_bid_trip_list_for_customer',
        'customer_uuid': customerUuid,
        'trip_status': tripStatus,
      };

      final uri = Uri.parse('${AppUrls.baseUrl}/v1/rental-trip/rental-bid-trip-list_for_customer').replace(queryParameters: queryParams);

      final token = await UserDataStore.getAccessToken();
      final headers = {
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == false) {
          throw Exception(decoded['message'] ?? "Unknown server error");
        }
        return RentalBidListResponse.fromJson(decoded);
      } else {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded['message'] != null) {
            throw Exception(decoded['message']);
          }
        } catch (_) {}
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching bids: $e");
      rethrow;
    }
  }
}
