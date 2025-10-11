import 'dart:convert';
import 'package:business_buddy_app/models/auth/auth_request.dart';
import 'package:http/http.dart' as http;

import '../constants/api.dart';
import '../models/auth/auth_response.dart';

class AuthAPI {
  static const String _baseUrl = 'http://${ApiEndpoints.baseUrl}';

  static Future<void> register({required RegisterRequest registerRequest}) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.register}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(registerRequest.toJson()),
    );

    if (response.statusCode != 200) {
      try {
        final Map<String, dynamic> resp = json.decode(response.body);
        final message =
            resp['errorMessage']?.toString() ?? 'Failed to Register.';
        throw Exception(message);
      } catch (_) {
        throw Exception('Failed to register. Status: ${response.statusCode}');
      }
    }
  }

  static Future<void> login({required LoginRequest loginRequest}) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.login}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginRequest.toJson()),
    );

    if (response.statusCode != 200) {
      try {
        final Map<String, dynamic> resp = json.decode(response.body);
        final message = resp['errorMessage']?.toString() ?? 'Failed to login.';
        throw Exception(message);
      } catch (_) {
        throw Exception('Failed to login. Status: ${response.statusCode}');
      }
    }
  }

  static Future<ValidateOtpResponse> validateOtp({required OtpRequest otpRequest}) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.validateOtp}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(otpRequest.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return ValidateOtpResponse.fromJson(data);
    }

    try {
      final Map<String, dynamic> resp = json.decode(response.body);
      final message =
          resp['errorMessage']?.toString() ?? 'Failed to validate OTP';
      throw Exception(message);
    } catch (_) {
      throw Exception('Failed to validate OTP. Status: ${response.statusCode}');
    }
  }

  static Future<List<UserWithRole>> getInventoryUsers({
    required String token,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/${ApiEndpoints.getInventoryUsers}',
    );
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      try {
        final Map<String, dynamic> resp = json.decode(response.body);
        final message =
            resp['errorMessage']?.toString() ?? 'Failed to get inventory users.';
        throw Exception(message);
      } catch (_) {
        throw Exception('Failed to get inventory users. Status: ${response.statusCode}');
      }
    } else {
      final List<dynamic> expensesJson = json.decode(response.body);
      return expensesJson.map((json) => UserWithRole.fromJson(json)).toList();
    }
  }

  static Future<void> addUsersToInventory({
    required String token,
    required AddUsersToInventoryRequest addUsersToInventoryRequest
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/${ApiEndpoints.addUsersToInventory}',
    );
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(addUsersToInventoryRequest.toJson())
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final Map<String, dynamic> resp = json.decode(response.body);
        final message =
            resp['errorMessage']?.toString() ?? 'Failed to add users into inventory.';
        throw Exception(message);
      } catch (_) {
        throw Exception('Failed to add users into inventory. Status: ${response.statusCode}');
      }
    }
  }

  static Future<void> removeUserFromInventory({
    required String token,
    required String userId
  }) async {
    final Map<String, String> qp = {
      'id': userId.toString(),
    };

    final uri = Uri.parse(
      '$_baseUrl/${ApiEndpoints.removeUserFromInventory}',
    ).replace(queryParameters: qp);
    final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final Map<String, dynamic> resp = json.decode(response.body);
        final message =
            resp['errorMessage']?.toString() ?? 'Failed to remove user from inventory.';
        throw Exception(message);
      } catch (_) {
        throw Exception('Failed to remove user from inventory. Status: ${response.statusCode}');
      }
    }
  }
}
