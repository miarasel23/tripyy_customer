import 'dart:convert';
import '../../../../core/network/api_service.dart';
import '../../../../utils/app_urls.dart';
import '../../../../store/user_data_store.dart';
import '../../../../utils/custom_map_body_builder.dart';
import '../../dashboard/models/create_rental_trip_model.dart';

class MyTripRepository {
  final ApiService _apiService = ApiService();

  Future<RentalBidListResponse> fetchTrips(String tripStatus, String languageCode) async {
    String? customerUuid = await UserDataStore.getUuid();
    if (customerUuid == null || customerUuid.isEmpty) {
      customerUuid = UserDataStore.userData?.data?.user?.uuid ?? "";
    }
    
    final platform = CustomMapBodyBuilder.getPlatform();
    
    final uri = Uri.parse("${AppUrls.rentalBidTripListForCustomer}?platform=$platform&language_code=$languageCode&action_when=rental_bid_trip_list_for_customer&customer_uuid=$customerUuid&trip_status=$tripStatus");

    final response = await _apiService.get(uri, headers: {
      "Authorization": "Bearer ${UserDataStore.accessToken ?? ""}"
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return RentalBidListResponse.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load trips');
    }
  }
}
