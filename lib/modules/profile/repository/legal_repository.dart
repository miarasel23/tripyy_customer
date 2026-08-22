import 'dart:convert';
import '../../../core/network/api_service.dart';
import '../../../utils/app_urls.dart';
import '../model/policy_model.dart';

class LegalRepository {
  Future<PolicyModel?> fetchPolicies({
    required String languageCode,
    String? countryCode,
  }) async {
    try {
      final effectiveCountryCode = (languageCode.toLowerCase() == 'bn' || languageCode.toLowerCase().contains('bn'))
          ? 'BD'
          : 'GB';

      final queryParams = {
        "platform": "web",
        "language_code": languageCode,
        "country_code": effectiveCountryCode,
      };

      final uri = Uri.parse(AppUrls.privacyPolicyTermsList)
          .replace(queryParameters: queryParams);

      final response = await ApiService().get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return PolicyModel.fromJson(jsonResponse);
      }
    } catch (e) {
      // Error handled centrally by ApiService
    }
    return null;
  }
}
