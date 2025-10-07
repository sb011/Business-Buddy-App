import 'dart:convert';

import 'package:business_buddy_app/models/bill/bill.dart';
import 'package:business_buddy_app/models/bill/bill_request.dart';
import 'package:business_buddy_app/models/bill/bill_response.dart';
import 'package:http/http.dart' as http;

import '../constants/api.dart';

class AuthAPI {
  static const String _baseUrl = 'http://${ApiEndpoints.baseUrl}';

  static Future<List<BillResponse>> getBills({
    required String token,
    required int limit,
    required int skip,
  }) async {
    final Map<String, String> qp = {
      'limit': limit.toString(),
      'skip': skip.toString(),
    };

    final uri = Uri.parse(
      '$_baseUrl/${ApiEndpoints.getBills}',
    ).replace(queryParameters: qp);
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
            resp['errorMessage']?.toString() ?? 'Failed to get bills.';
        throw Exception(message);
      } catch (_) {
        throw Exception('Failed to get bills. Status: ${response.statusCode}');
      }
    } else {
      final List<dynamic> billJson = json.decode(response.body);
      return billJson.map((json) => BillResponse.fromJson(json)).toList();
    }
  }

  static Future<BillResponse> createBill({
    required String token,
    required CreateBillRequest createBillRequest
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/${ApiEndpoints.createBill}',
    );
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(createBillRequest.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final Map<String, dynamic> resp = json.decode(response.body);
        final message =
            resp['errorMessage']?.toString() ?? 'Failed to get bills.';
        throw Exception(message);
      } catch (_) {
        throw Exception('Failed to get bills. Status: ${response.statusCode}');
      }
    } else {
      final Map<String, dynamic> data = json.decode(response.body);
      return BillResponse.fromJson(data);
    }
  }

  static Future<List<Customer>> getCustomers({
    required String token,
    required String query
  }) async {
    final Map<String, String> qp = {
      'q': query.toString(),
    };

    final uri = Uri.parse(
      '$_baseUrl/${ApiEndpoints.getCustomers}',
    ).replace(queryParameters: qp);
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
            resp['errorMessage']?.toString() ?? 'Failed to get customers.';
        throw Exception(message);
      } catch (_) {
        throw Exception('Failed to get customers. Status: ${response.statusCode}');
      }
    } else {
      final List<dynamic> expensesJson = json.decode(response.body);
      return expensesJson.map((json) => Customer.fromJson(json)).toList();
    }
  }
}
