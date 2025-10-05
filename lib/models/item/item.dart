class Item {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int quantity;
  final String inventoryId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.quantity,
    required this.inventoryId,
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
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      inventoryId: json['inventory_id'] as String,
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
      'price': price,
      'quantity': quantity,
      'inventory_id': inventoryId,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
