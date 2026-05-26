import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';
import 'package:trippy_customer/utils/app_urls.dart';

class OtpReceiveRepository {
  OtpReceiveRepository();

  Future<String?> receivingOtp({
    required String otp,
    required String languageCode,
    required String number,
  }) async {
    final Map<String, dynamic> data = {
      "platform": "web",
      "language_code": languageCode,
      "action_when": "customer_login",
      "phone_number": number,
      "country_code": "BD",
      "otp": otp,
    };

    try {
      final response = await post(
        Uri.parse(AppUrls.verifyOtpCustomer),
        body: data,
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        return "Server error: ${response.statusCode}";
      }
    } on SocketException {
      return "No Internet connection";
    } on TimeoutException {
      return "Request timeout";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }
}
