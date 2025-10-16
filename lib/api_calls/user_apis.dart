import 'dart:convert';

import 'package:business_buddy_app/models/auth/auth_request.dart';
import 'package:http/http.dart' as http;

import '../constants/api.dart';
import 'api_helper.dart';

class UserAPI {
  static const String _baseUrl = ApiEndpoints.baseUrl;

  static Future<void> updateUserDetails({
    required String token,
    required UpdateUserRequest updateUserRequest
  }) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.userUpdate}');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updateUserRequest.toJson()),
    );

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to update details.');
    if (!isValid) {
      throw Exception('Failed to update details.');
    }
  }
}


