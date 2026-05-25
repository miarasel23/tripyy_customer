import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';

import '../../../utils/app_urls.dart';

class SendOtpRepository {
  SendOtpRepository();

  Future<String?> sendingOtp({
    required String number,
    required String languageCode,
  }) async {
    final Map<String, dynamic> data = {
      "platform": "web",
      "language_code": languageCode,
      "action_when": "customer_login",
      "phone_number": number,
      "country_code": "BD",
    };

    try {
      final response = await post(
        Uri.parse(AppUrls.sendOtpCustomer),
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
