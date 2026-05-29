import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../modules/splash/models/current_user_model.dart';

class ImportantConsts {
  static const String _accessTokenKey = 'access-token';
  static const String _userDataKey = 'user-data';
  static const String _uuid = 'uuid';

  static String? accessToken;
  static String? uuid;
  static CurrentUserModel? userData;

  static Future<void> saveAccessToken(String token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_accessTokenKey, token);
    accessToken = token;
  }

  static Future<void> saveUuid(String uuid) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_uuid, uuid);
    uuid = uuid;
  }
  
  static Future<void> saveUserData(CurrentUserModel currentUserModel) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_userDataKey, jsonEncode(currentUserModel.toJson()));
    userData = currentUserModel;
  }

  static Future<String?> getAccessToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString(_accessTokenKey);
    accessToken = token;
    return token;
  }

  static Future<String?> getUuid() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? user_uuid = sharedPreferences.getString(_uuid);
    uuid = user_uuid;
    return user_uuid;
  }
}
