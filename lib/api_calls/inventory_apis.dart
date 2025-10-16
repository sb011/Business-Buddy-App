import 'dart:convert';

import 'package:business_buddy_app/models/item/item.dart';
import 'package:business_buddy_app/models/item/item_request.dart';
import 'package:business_buddy_app/models/item/item_response.dart';
import 'package:http/http.dart' as http;

import '../constants/api.dart';
import 'api_helper.dart';

class InventoryAPI {
  static const String _baseUrl = ApiEndpoints.baseUrl;

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

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to get inventory items.');
    if (!isValid) {
      throw Exception('Failed to get inventory items.');
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

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to create inventory items.');
    if (!isValid) {
      throw Exception('Failed to create inventory items.');
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

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to update inventory items.');
    if (!isValid) {
      throw Exception('Failed to update inventory items.');
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

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to update item stock.');
    if (!isValid) {
      throw Exception('Failed to update item stock.');
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

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to get item variant history.');
    if (!isValid) {
      throw Exception('Failed to get item variant history.');
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

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to archive item.');
    if (!isValid) {
      throw Exception('Failed to archive item.');
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

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to add item variant.');
    if (!isValid) {
      throw Exception('Failed to add item variant.');
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

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to update item variant.');
    if (!isValid) {
      throw Exception('Failed to update item variant.');
    }
  }

  static Future<void> archiveItemVariant({
    required String token,
    required ItemVariantArchiveRequest itemVariantArchiveRequest,
  }) async {
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.archiveItemVariant}');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(itemVariantArchiveRequest.toJson()),
    );

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to archive item variant.');
    if (!isValid) {
      throw Exception('Failed to archive item variant.');
    }
  }

  static Future<List<ItemVariant>> getArchivedItemVariants({
    required String token,
  }) async {
    final Map<String, String> qp = {
      'archive': 'true',
    };
    final uri = Uri.parse('$_baseUrl/${ApiEndpoints.getItemVariants}').replace(queryParameters: qp);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      }
    );

    bool isValid = await ApiHelper.validateResponse(response, 'Failed to get archived items.');
    if (!isValid) {
      throw Exception('Failed to get archived items.');
    } else {
      final List<dynamic> variantsJson = json.decode(response.body);
      return variantsJson.map((json) => ItemVariant.fromJson(json)).toList();
    }
  }
}
