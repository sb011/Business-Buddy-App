class CreateItemRequest {
  final String name;
  final String description;
  final String category;
  final List<CreateItemItemVariant> itemVariants;

  CreateItemRequest({
    required this.name,
    required this.description,
    required this.category,
    required this.itemVariants,
  });

  factory CreateItemRequest.fromJson(Map<String, dynamic> json) {
    return CreateItemRequest(
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      itemVariants: (json['item_variants'] as List<dynamic>)
          .map(
            (item) =>
                CreateItemItemVariant.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'item_variants': itemVariants
          .map((itemVariant) => itemVariant.toJson())
          .toList(),
    };
  }
}

class CreateItemItemVariant {
  final String name;
  final double price;
  final int quantity;

  CreateItemItemVariant({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory CreateItemItemVariant.fromJson(Map<String, dynamic> json) {
    return CreateItemItemVariant(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'price': price, 'quantity': quantity};
  }
}

class AddItemVariant {
  final String itemId;
  final String name;
  final double price;
  final int quantity;

  AddItemVariant({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory AddItemVariant.fromJson(Map<String, dynamic> json) {
    return AddItemVariant(
      itemId: json['item_id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'item_id': itemId, 'name': name, 'price': price, 'quantity': quantity};
  }
}

class UpdateItemVariant {
  final String itemVariantId;
  final String name;
  final double price;

  UpdateItemVariant({
    required this.itemVariantId,
    required this.name,
    required this.price,
  });

  factory UpdateItemVariant.fromJson(Map<String, dynamic> json) {
    return UpdateItemVariant(
      itemVariantId: json['item_variant_id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'item_variant_id': itemVariantId, 'name': name, 'price': price};
  }
}

class UpdateItemRequest {
  final String id;
  final String name;
  final String description;
  final String category;

  UpdateItemRequest({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });

  factory UpdateItemRequest.fromJson(Map<String, dynamic> json) {
    return UpdateItemRequest(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
    };
  }
}

class UpdateStockRequest {
  final String itemVariantId;
  final int quantity;
  final String? reason;

  UpdateStockRequest({
    required this.itemVariantId,
    required this.quantity,
    this.reason,
  });

  factory UpdateStockRequest.fromJson(Map<String, dynamic> json) {
    return UpdateStockRequest(
      itemVariantId: json['item_variant_id'] as String,
      quantity: json['quantity'] as int,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {'item_variant_id': itemVariantId, 'quantity': quantity, 'reason': reason};
    return map;
  }
}

class ItemArchiveRequest {
  final String itemId;
  final bool isArchive;

  ItemArchiveRequest({required this.itemId, required this.isArchive});

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

class ItemVariantArchiveRequest {
  final String itemId;
  final String itemVariantId;
  final bool isArchive;

  ItemVariantArchiveRequest({required this.itemId, required this.itemVariantId, required this.isArchive});

  factory ItemVariantArchiveRequest.fromJson(Map<String, dynamic> json) {
    return ItemVariantArchiveRequest(
      itemId: json['item_id'] as String,
      itemVariantId: json['item_variant_id'] as String,
      isArchive: json['is_archive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {'item_id': itemId, 'item_variant_id': itemVariantId, 'is_archive': isArchive};
    return map;
  }
}
