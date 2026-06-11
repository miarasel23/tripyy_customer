import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:trippy_customer/utils/app_urls.dart';
import 'package:trippy_customer/utils/choose_car_bottom_sheet/models/car_list_model.dart';
import 'package:trippy_customer/utils/custom_map_body_builder.dart';

class ChooseCarBottomSheetRepository {
  ChooseCarBottomSheetRepository();

  Future<CarListModel?> receivingCarList({
    required String languageCode,
  }) async {
    try {
      final response = await get(
        Uri.parse(AppUrls.rentalInfo).replace(
          queryParameters: CustomMapBodyBuilder.build(
            actionWhen: "admin_login",
            languageCode: languageCode,
          ),
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CarListModel.fromJson(jsonData);
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } on SocketException {
      throw Exception("No Internet connection");
    } on TimeoutException {
      throw Exception("Request timeout");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }
}
