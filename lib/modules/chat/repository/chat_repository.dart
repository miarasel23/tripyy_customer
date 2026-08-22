import 'dart:convert';
import '../../../core/network/api_service.dart';
import '../../../store/app_globals.dart';
import '../../../utils/app_urls.dart';
import '../../../store/user_data_store.dart';
import '../model/chat_message_model.dart';

class ChatRepository {
  final ApiService _apiService = ApiService();

  Future<List<ChatMessageModel>> fetchConversations({
    required String customerUuid,
    String driverUuid = '',
    String receiverType = 'DRIVER',
  }) async {
    final url = Uri.parse(AppUrls.liveChatConversation);
    final payload = <String, String>{
      'platform': AppGlobals.platform,
      'language_code': AppGlobals.countryCode.toLowerCase() == 'bd' ? 'bn' : 'en',
      'action_when': 'live_chat_message_list',
      'sender_type': 'CUSTOMER',
      'user1_uuid': customerUuid,
      'user1_type': 'CUSTOMER',
      'user2_type': receiverType,
    };

    if (receiverType == 'DRIVER' && driverUuid.isNotEmpty) {
      payload['receiver_type'] = 'DRIVER';
      payload['user2_uuid'] = driverUuid;
    } else if (receiverType == 'ADMIN') {
      payload['receiver_type'] = 'ADMIN';
    }

    final token = await UserDataStore.getAccessToken();

    try {
      final response = await _apiService.multipartPost(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
        fields: payload,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data']['messages'] != null) {
          return (data['data']['messages'] as List)
              .map((e) => ChatMessageModel.fromJson(e))
              .where((m) => m.status.toUpperCase() == 'ACTIVE')
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> sendMessage({
    required String customerUuid,
    String driverUuid = '',
    required String message,
    String receiverType = 'DRIVER',
    String? filePath,
  }) async {
    final url = Uri.parse(AppUrls.liveChatSend);
    final fields = <String, String>{
      'platform': AppGlobals.platform,
      'language_code': AppGlobals.countryCode.toLowerCase() == 'bd' ? 'bn' : 'en',
      'action_when': 'live_chat_message_send',
      'sender_type': 'CUSTOMER',
      'sender_uuid': customerUuid,
      'receiver_type': receiverType,
      'message': message,
    };

    if (receiverType == 'DRIVER' && driverUuid.isNotEmpty) {
      fields['receiver_uuid'] = driverUuid;
    }

    final token = await UserDataStore.getAccessToken();

    try {
      final response = await _apiService.multipartPost(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
        fields: fields,
        fileField: 'file',
        filePath: filePath,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
