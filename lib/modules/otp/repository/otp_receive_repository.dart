import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import '../../../store/important_consts.dart';
import '../../../utils/app_urls.dart';
import '../models/otp_receive_model.dart';

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
        final jsonData = jsonDecode(response.body);
        OtpReceiveModel otpReceiveModel = OtpReceiveModel.fromJson(jsonData);
        await ImportantConsts.saveAccessToken(
          otpReceiveModel.data!.accessToken!,
        );
        final token = await ImportantConsts.getAccessToken();
        print("Access token is $token");
        await ImportantConsts.saveUuid(otpReceiveModel.data!.user!.uuid!);
        final uuid = await ImportantConsts.getUuid();
        print("uuid is : $uuid");
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
