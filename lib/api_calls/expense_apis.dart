import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api.dart';
import '../models/expense/expense.dart';
import '../models/expense/expense_request.dart';

class ExpenseAPI {
  static const String _baseUrl = 'http://${ApiEndpoints.baseUrl}';

  static Future<Expense> createExpense({
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

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final Map<String, dynamic> resp = json.decode(response.body);
        final message =
            resp['errorMessage']?.toString() ?? 'Failed to create expense';
        throw Exception(message);
      } catch (_) {
        throw Exception(
          'Failed to create expense. Status: ${response.statusCode}',
        );
      }
    } else {
      final Map<String, dynamic> data = json.decode(response.body);
      return Expense.fromJson(data);
    }
  }

  static Future<List<Expense>> getExpenses({
    required String token,
    required int limit,
    required int skip,
    required bool archive,
  }) async {
    final Map<String, String> qp = {
      'limit': limit.toString(),
      'skip': skip.toString(),
      'archive': archive.toString(),
    };

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

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final Map<String, dynamic> resp = json.decode(response.body);
        final message =
            resp['errorMessage']?.toString() ?? 'Failed to get expense';
        throw Exception(message);
      } catch (_) {
        throw Exception(
          'Failed to get expense. Status: ${response.statusCode}',
        );
      }
    } else {
      final List<dynamic> expensesJson = json.decode(response.body);
      return expensesJson.map((json) => Expense.fromJson(json)).toList();
    }
  }

  static Future<void> updateExpense({
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

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final Map<String, dynamic> resp = json.decode(response.body);
        final message =
            resp['errorMessage']?.toString() ?? 'Failed to update expense';
        throw Exception(message);
      } catch (_) {
        throw Exception(
          'Failed to update expense. Status: ${response.statusCode}',
        );
      }
    }
  }

  static Future<void> archivedExpense({
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

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final Map<String, dynamic> resp = json.decode(response.body);
        final message =
            resp['errorMessage']?.toString() ?? 'Failed to archive expense';
        throw Exception(message);
      } catch (_) {
        throw Exception(
          'Failed to  archive expense. Status: ${response.statusCode}',
        );
      }
    }
  }
}
