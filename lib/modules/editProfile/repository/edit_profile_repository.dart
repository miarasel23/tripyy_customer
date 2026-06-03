import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';

import '../../../store/important_consts.dart';
import '../../../utils/app_urls.dart';
import '../../../utils/custom_map_body_builder.dart';

class EditProfilePictureRepository {
  Future<String?> uploadProfilePicture(
    File imageFile,
    String languageCode,
  ) async {
    ImportantConsts.getUuid();
    ImportantConsts.getAccessToken();
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
        'Accept': 'application/json',
        'Authorization': 'Bearer ${ImportantConsts.accessToken}',
      });

      request.files.add(await MultipartFile.fromPath('avatar', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        print('Upload successful');
        return null;
      } else {
        print('Upload failed: ${response.statusCode}');
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
