class CreateItemRequest {
  final String name;
  final String description;
  final String category;
  final double price;
  final int quantity;

  CreateItemRequest({
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.quantity,
  });

  factory CreateItemRequest.fromJson(Map<String, dynamic> json) {
    return CreateItemRequest(
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'quantity': quantity,
    };
  }
}

class UpdateItemRequest {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;

  UpdateItemRequest({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
  });

  factory UpdateItemRequest.fromJson(Map<String, dynamic> json) {
    return UpdateItemRequest(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
    };
  }
}

class UpdateStockRequest {
  final String itemId;
  final int quantity;
  final String? reason;

  UpdateStockRequest({
    required this.itemId,
    required this.quantity,
    this.reason,
  });

  factory UpdateStockRequest.fromJson(Map<String, dynamic> json) {
    return UpdateStockRequest(
      itemId: json['item_id'] as String,
      quantity: json['quantity'] as int,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {'item_id': itemId, 'quantity': quantity, 'reason': reason};
    return map;
  }
}

class ItemArchiveRequest {
  final String itemId;
  final bool isArchive;

  ItemArchiveRequest({
    required this.itemId,
    required this.isArchive
  });

  factory ItemArchiveRequest.fromJson(Map<String, dynamic> json) {
    return ItemArchiveRequest(
      itemId: json['item_id'] as String,
      isArchive: json['is_archive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {'item_id': itemId, 'is_archive': isArchive};
    return map;
  }
}
