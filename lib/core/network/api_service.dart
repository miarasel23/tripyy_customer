import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../../routes/app_routes.dart';
import '../../store/user_data_store.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  // Helper method to handle response centrally
  void _handleErrorResponse(http.Response response) {
    if (response.statusCode == 401) {
      // Handle unauthorized / expired token by logging out
      UserDataStore.clearAllData().then((_) {
        if (globalNavigatorKey.currentState != null) {
          globalNavigatorKey.currentState!.pushNamedAndRemoveUntil(
            AppRoutes.numberInput,
            (route) => false,
          );
        }
      });
      return;
    }

    if (response.statusCode >= 400) {
      // Decode error message if available
      String errorMessage = 'An unexpected error occurred';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('message')) {
          errorMessage = body['message'].toString();
        } else {
          errorMessage = 'Server error: ${response.statusCode}';
        }
      } catch (_) {
        errorMessage = 'Server error: ${response.statusCode}';
      }

      // Navigate to error screen using global navigator key
      if (globalNavigatorKey.currentState != null) {
        globalNavigatorKey.currentState!.pushNamed(
          AppRoutes.error,
          arguments: errorMessage,
        );
      } else {
        debugPrint('Error navigation failed: globalNavigatorKey state is null');
      }
    }
  }

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(url, headers: headers);
      _handleErrorResponse(response);
      return response;
    } catch (e) {
      _navigateToError(e.toString());
      rethrow;
    }
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    try {
      final response = await http.post(url, headers: headers, body: body, encoding: encoding);
      _handleErrorResponse(response);
      return response;
    } catch (e) {
      _navigateToError(e.toString());
      rethrow;
    }
  }

  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    try {
      final response = await http.put(url, headers: headers, body: body, encoding: encoding);
      _handleErrorResponse(response);
      return response;
    } catch (e) {
      _navigateToError(e.toString());
      rethrow;
    }
  }

  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    try {
      final response = await http.delete(url, headers: headers, body: body, encoding: encoding);
      _handleErrorResponse(response);
      return response;
    } catch (e) {
      _navigateToError(e.toString());
      rethrow;
    }
  }

  void _navigateToError(String error) {
    if (globalNavigatorKey.currentState != null) {
      globalNavigatorKey.currentState!.pushNamed(
        AppRoutes.error,
        arguments: 'Connection Error: $error',
      );
    }
  }
}
