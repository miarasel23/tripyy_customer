import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:trippy_customer/modules/splash/repository/splash_repository.dart';

import '../../../store/important_consts.dart';
import '../../../utils/app_urls.dart';
import '../../../utils/custom_map_body_builder.dart';

class EditProfilePictureRepository {
  final SplashRepository repository;

  EditProfilePictureRepository({required this.repository});
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
      final responseBody = await response.stream.bytesToString();

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
