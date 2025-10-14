class Item {
  final String id;
  final String name;
  final String description;
  final String category;
  final String inventoryId;
  final List<ItemVariant> itemVariants;
  final bool archived;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.inventoryId,
    required this.itemVariants,
    required this.archived,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      inventoryId: json['inventory_id'] as String,
      itemVariants: (json['item_variants'] as List<dynamic>)
          .map((item) => ItemVariant.fromJson(item as Map<String, dynamic>))
          .toList(),
      archived: json['archived'] as bool,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'inventory_id': inventoryId,
      'item_variants': itemVariants.map((itemVariant) => itemVariant.toJson()).toList(),
      'archived': archived,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ItemVariant {
  final String id;
  final String itemId;
  final String name;
  final double price;
  final int quantity;
  final bool archived;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemVariant({
    required this.id,
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.archived,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemVariant.fromJson(Map<String, dynamic> json) {
    return ItemVariant(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      archived: json['archived'] as bool,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'archived': archived,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
