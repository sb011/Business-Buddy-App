import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import '../constants/api.dart';
import '../models/expense/expense.dart';
import '../models/expense/expense_request.dart';
import 'api_helper.dart';

class ExpenseAPI {
  static const String _baseUrl = ApiEndpoints.baseUrl;

  static Future<Expense> createExpense({
    required BuildContext context,
    required String token,
    required CreateExpenseRequest createExpenseRequest,
  }) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.createExpense}');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(createExpenseRequest.toJson()),
    );

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to create expense.', context);
    if (!isValid) {
      throw Exception('Failed to create expense.');
    } else {
      final Map<String, dynamic> data = json.decode(response.body);
      return Expense.fromJson(data);
    }
  }

  static Future<List<Expense>> getExpenses({
    required BuildContext context,
    required String token,
    required int limit,
    required int skip,
    required bool archive,
    String? query,
  }) async {
    final Map<String, String> qp = {
      'limit': limit.toString(),
      'skip': skip.toString(),
      'archive': archive.toString(),
    };
    if (query != null && query.trim().isNotEmpty) {
      qp['q'] = query.trim();
    }

    final uri = Uri.parse(
      '$_baseUrl/${ApiEndpoints.getExpenses}',
    ).replace(queryParameters: qp);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to get expense.', context);
    if (!isValid) {
      throw Exception('Failed to get expense.');
    } else {
      final List<dynamic> expensesJson = json.decode(response.body);
      return expensesJson.map((json) => Expense.fromJson(json)).toList();
    }
  }

  static Future<void> updateExpense({
    required BuildContext context,
    required String token,
    required UpdateExpenseRequest updateExpenseRequest,
  }) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.updateExpense}');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updateExpenseRequest.toJson()),
    );

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to update expense.', context);
    if (!isValid) {
      throw Exception('Failed to update expense.');
    }
  }

  static Future<void> archivedExpense({
    required BuildContext context,
    required String token,
    required ExpenseArchiveRequest archiveExpenseRequest,
  }) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.archiveExpense}');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(archiveExpenseRequest.toJson()),
    );

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to archive expense.', context);
    if (!isValid) {
      throw Exception('Failed to archive expense.');
    }
  }
}
