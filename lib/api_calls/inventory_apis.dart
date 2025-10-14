import 'dart:convert';

import 'package:business_buddy_app/models/item/item.dart';
import 'package:business_buddy_app/models/item/item_request.dart';
import 'package:business_buddy_app/models/item/item_response.dart';
import 'package:http/http.dart' as http;

import '../constants/api.dart';

class InventoryAPI {
  static const String _baseUrl = 'http://${ApiEndpoints.baseUrl}';

  static Future<List<Item>> getInventoryItems({
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
      '$_baseUrl/${ApiEndpoints.inventoryItems}',
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
            resp['errorMessage']?.toString() ??
            'Failed to fetch inventory items';
        throw Exception(message);
      } catch (_) {
        throw Exception(
          'Failed to fetch inventory items. Status: ${response.statusCode}',
        );
      }
    } else {
      final List<dynamic> itemsJson = json.decode(response.body);
      return itemsJson.map((json) => Item.fromJson(json)).toList();
    }
  }

  static Future<Item> createItem({
    required String token,
    required CreateItemRequest createItemRequest,
  }) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.createItem}');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(createItemRequest.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final Map<String, dynamic> resp = json.decode(response.body);
        final message =
            resp['errorMessage']?.toString() ??
            'Failed to create inventory items';
        throw Exception(message);
      } catch (_) {
        throw Exception(
          'Failed to create inventory items. Status: ${response.statusCode}',
        );
      }
    } else {
      final Map<String, dynamic> data = json.decode(response.body);
      return Item.fromJson(data);
    }
  }

  static Future<void> updateItem({
    required String token,
    required UpdateItemRequest updateItemRequest,
  }) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.updateItem}');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updateItemRequest.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final Map<String, dynamic> resp = json.decode(response.body);
        final message =
            resp['errorMessage']?.toString() ??
            'Failed to update inventory items';
        throw Exception(message);
      } catch (_) {
        throw Exception(
          'Failed to update inventory items. Status: ${response.statusCode}',
        );
      }
    }
  }

  static Future<void> updateItemVariantStock({
    required String token,
    required UpdateStockRequest updateStockRequest,
  }) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.updateStock}');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updateStockRequest.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final Map<String, dynamic> resp = json.decode(response.body);
        final message =
            resp['errorMessage']?.toString() ?? 'Failed to update item stock';
        throw Exception(message);
      } catch (_) {
        throw Exception(
          'Failed to update item stock. Status: ${response.statusCode}',
        );
      }
    }
  }

  static Future<List<ItemHistoryResponse>> getItemVariantHistory({
    required String token,
    required String itemVariantId,
    required int limit,
    required int skip,
  }) async {
    final Map<String, String> qp = {
      'limit': limit.toString(),
      'skip': skip.toString(),
    };
    final uri = Uri.parse(
      '$_baseUrl/${ApiEndpoints.itemVariantHistory(itemVariantId)}',
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
            resp['errorMessage']?.toString() ??
            'Failed to fetch inventory items';
        throw Exception(message);
      } catch (_) {
        throw Exception(
          'Failed to fetch item history. Status: ${response.statusCode}',
        );
      }
    } else {
      final List<dynamic> itemsJson = json.decode(response.body);
      return itemsJson
          .map((json) => ItemHistoryResponse.fromJson(json))
          .toList();
    }
  }

  static Future<void> archiveItem({
    required String token,
    required ItemArchiveRequest itemArchiveRequest,
  }) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.archiveItem}');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(itemArchiveRequest.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final Map<String, dynamic> resp = json.decode(response.body);
        final message =
            resp['errorMessage']?.toString() ?? 'Failed to archive item';
        throw Exception(message);
      } catch (_) {
        throw Exception(
          'Failed to archive item. Status: ${response.statusCode}',
        );
      }
    }
  }

  static Future<ItemVariant> addItemVariant({
    required String token,
    required AddItemVariant addItemVariant,
  }) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.addItemVariant}');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(addItemVariant.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final Map<String, dynamic> resp = json.decode(response.body);
        final message =
            resp['errorMessage']?.toString() ?? 'Failed to adding item variant';
        throw Exception(message);
      } catch (_) {
        throw Exception(
          'Failed to adding item variant. Status: ${response.statusCode}',
        );
      }
    } else {
      final Map<String, dynamic> data = json.decode(response.body);
      return ItemVariant.fromJson(data);
    }
  }

  static Future<void> updateItemVariant({
    required String token,
    required UpdateItemVariant updateItemVariant,
  }) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.updateItemVariant}');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updateItemVariant.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final Map<String, dynamic> resp = json.decode(response.body);
        final message =
            resp['errorMessage']?.toString() ?? 'Failed to adding item variant';
        throw Exception(message);
      } catch (_) {
        throw Exception(
          'Failed to adding item variant. Status: ${response.statusCode}',
        );
      }
    }
  }
}
