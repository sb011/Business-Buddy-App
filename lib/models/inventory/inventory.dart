class Inventory {
  final String id;
  final String name;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Inventory({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'] as String,
      name: json['name'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
