class Expense {
  final String id;
  final String title;
  final String description;
  final String type;
  final double amount;
  final String inventoryId;
  final bool archived;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.amount,
    required this.inventoryId,
    required this.archived,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      inventoryId: json['inventory_id'] as String,
      archived: json['archived'] as bool,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'amount': amount,
      'inventory_id': inventoryId,
      'archived': archived,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
