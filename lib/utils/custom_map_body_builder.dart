class CustomMapBodyBuilder {
  static Map<String, dynamic> build({
    required String actionWhen,
    required String languageCode,
    required Map<String, dynamic> data,
  }) {
    return {
      "platform": "web",
      "language_code": languageCode,
      "action_when": actionWhen,
      ...data,
    };
  }
}
