import 'dart:convert';

import 'package:business_buddy_app/models/bill/bill.dart';
import 'package:business_buddy_app/models/bill/bill_request.dart';
import 'package:business_buddy_app/models/bill/bill_response.dart';
import 'package:http/http.dart' as http;

import '../constants/api.dart';
import 'api_helper.dart';

class AuthAPI {
  static const String _baseUrl = ApiEndpoints.baseUrl;

  static Future<List<BillResponse>> getBills({
    required String token,
    required int limit,
    required int skip,
    String? searchQuery,
  }) async {
    final Map<String, String> qp = {
      'limit': limit.toString(),
      'skip': skip.toString(),
    };
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      qp['q'] = searchQuery;
    }

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

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to get bills.');
    if (!isValid) {
      throw Exception('Failed to get bills.');
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

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to create bill.');
    if (!isValid) {
      throw Exception('Failed to create bill.');
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

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to get customer details.');
    if (!isValid) {
      throw Exception('Failed to get customer details.');
    } else {
      final List<dynamic> expensesJson = json.decode(response.body);
      return expensesJson.map((json) => Customer.fromJson(json)).toList();
    }
  }
}
