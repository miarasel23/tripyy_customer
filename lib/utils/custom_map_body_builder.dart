import 'dart:io';

class CustomMapBodyBuilder {
  static Map<String, dynamic> build({
    required String actionWhen,
    required String languageCode,
    Map<String, dynamic>? data,
  }) {
    String platform = "web";
    if (Platform.isAndroid) {
      platform = "android";
    } else if (Platform.isIOS) {
      platform = "ios";
    }
    return {
      "platform": platform,
      "language_code": languageCode,
      "action_when": actionWhen,
      ...?data,
    };
  }
}
