import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:http/http.dart';
import 'package:path/path.dart';

import '../../../store/important_consts.dart';
import '../../../utils/app_urls.dart';
import '../../../utils/custom_map_body_builder.dart';
import '../../splash/repository/splash_repository.dart';
import '../../splash/models/current_user_model.dart';

class EditProfileRepository {
  final SplashRepository repository;

  EditProfileRepository({required this.repository});
  Future<String?> uploadProfilePicture({
    required File imageFile,
    required String languageCode,
    required String plaform,
    required String actionWhen,
    required String email,
    required String password,
  }) async {
    await ImportantConsts.getUuid();
    await ImportantConsts.getAccessToken();
    try {
      var request = MultipartRequest(
        'POST',
        Uri.parse(AppUrls.customerProfilePictureUpdate),
      );

      request.fields.addAll(
        CustomMapBodyBuilder.build(
          actionWhen: 'customer_profile_picture_upload',
          languageCode: languageCode,
          data: {'customer_uuid': ImportantConsts.uuid},
        ).map((key, value) => MapEntry(key, value.toString())),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${ImportantConsts.accessToken}',
      });

      final ext = extension(imageFile.path).toLowerCase();

      MediaType mediaType;
      if (ext == '.png') {
        mediaType = MediaType('image', 'png');
      } else if (ext == '.jpg' || ext == '.jpeg') {
        mediaType = MediaType('image', 'jpeg');
      } else {
        return "Unsupported file format";
      }

      request.files.add(
        await MultipartFile.fromPath(
          'avatar',
          imageFile.path,
          contentType: mediaType,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        print('Upload successful');
        final userInfoRespond = await repository.receivingUserData(
          plaform: plaform,
          languageCode: languageCode,
          actionWhen: actionWhen,
          email: email,
          password: password,
          token: ImportantConsts.accessToken!,
        );
        if (userInfoRespond == null) {
          print("Info synced");
          return null;
        } else {
          print("error of splash repo $userInfoRespond");
        }
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

  Future<String?> editingInfo({
    required String languageCode,
    required String phone_number,
    required String fullName,
    required String email,
    String? nidNumber,
  }) async {
    await ImportantConsts.getUuid();
    await ImportantConsts.getAccessToken();
    print("The uuid is : ${ImportantConsts.uuid}");
    final Map<String, dynamic> data = CustomMapBodyBuilder.build(
      actionWhen: "customer_profile_edit",
      languageCode: languageCode,
      data: {
        "phone_number": phone_number,
        "country_code": "BD",
        "uuid": ImportantConsts.uuid,
        "full_name": fullName,
        "email": email,
        "nid_number": nidNumber ?? "23423423422",
        "is_notification_enabled": "false",
        "device_token_for_notification": "234322343",
        "is_active": "true",
      },
    );
    try {
      var request = MultipartRequest(
        'POST',
        Uri.parse(AppUrls.customerProfileUpdate),
      );
      request.fields.addAll(
        data.map((key, value) => MapEntry(key, value.toString())),
      );
      request.headers.addAll({
        'Authorization': 'Bearer ${ImportantConsts.accessToken}',
      });
      final streamedResponse = await request.send();
      final response = await Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        String platform = "web";
        if (Platform.isAndroid) {
          platform = "android";
        } else if (Platform.isIOS) {
          platform = "ios";
        }

        final uri = Uri.parse(AppUrls.getCurrentCustomerUser).replace(
          queryParameters: {
            "platform": platform,
            "language_code": languageCode,
            "action_when": "profile_info",
          },
        );

        final responseCurrentData = await get(
          uri,
          headers: {
            'Authorization': 'Bearer ${ImportantConsts.accessToken}',
          },
        );

        if (responseCurrentData.statusCode == 200) {
          final jsonData = jsonDecode(responseCurrentData.body);
          CurrentUserModel currentUserModel = CurrentUserModel.fromJson(jsonData);
          await ImportantConsts.saveUserData(currentUserModel);
          return null;
        } else {
          return "Failed to sync user info: ${responseCurrentData.statusCode}";
        }
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
