import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api.dart';

class UserAPI {
  static const String _baseUrl = 'http://${ApiEndpoints.baseUrl}';

  static Future<void> updateUserDetails({
    required String token,
    required updateUserRequest
  }) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.userUpdate}');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updateUserRequest),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final Map<String, dynamic> resp = json.decode(response.body);
        final message = resp['errorMessage']?.toString() ?? 'Failed to update details';
        throw Exception(message);
      } catch (_) {
        throw Exception('Failed to update details. Status: ${response.statusCode}');
      }
    }
  }
}


