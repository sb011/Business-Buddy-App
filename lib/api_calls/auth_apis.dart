import 'dart:convert';

import 'package:business_buddy_app/api_calls/api_helper.dart';
import 'package:business_buddy_app/models/auth/auth_request.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/api.dart';
import '../models/auth/auth_response.dart';

class AuthAPI {
  static const String _baseUrl = ApiEndpoints.baseUrl;

  static Future<void> register({required BuildContext context, required RegisterRequest registerRequest}) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.register}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(registerRequest.toJson()),
    );

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to register.', context);
    if (!isValid) {
      return;
    }
  }

  static Future<void> login({
    required BuildContext context,
    required LoginRequest loginRequest,
  }) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.login}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginRequest.toJson()),
    );

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to login.', context);
    if (!isValid) {
      throw Exception('Failed to login.');
    }
  }

  static Future<ValidateOtpResponse> validateOtp({required BuildContext context, required OtpRequest otpRequest}) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.validateOtp}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(otpRequest.toJson()),
    ).timeout(const Duration(seconds: 15));

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to login.',context);
    if (!isValid) {
      throw Exception('Failed to login.');
    } else {
      final Map<String, dynamic> data = json.decode(response.body);
      return ValidateOtpResponse.fromJson(data);
    }
  }

  static Future<List<UserWithRole>> getInventoryUsers({
    required BuildContext context,
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

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to get inventory users.', context);
    if (!isValid) {
      throw Exception('Failed to get inventory users.');
    } else {
      final List<dynamic> expensesJson = json.decode(response.body);
      return expensesJson.map((json) => UserWithRole.fromJson(json)).toList();
    }
  }

  static Future<void> addUsersToInventory({
    required BuildContext context,
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

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to add users into inventory.', context);
    if (!isValid) {
      throw Exception('Failed to add users into inventory.');
    }
  }

  static Future<void> removeUserFromInventory({
    required BuildContext context,
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

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to remove user from inventory.', context);
    if (!isValid) {
      throw Exception('Failed to remove user from inventory.');
    }
  }
}
