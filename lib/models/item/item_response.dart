class ItemHistoryResponse {
  final String id;
  final String itemId;
  final String changeType;
  final int quantity;
  final int oldQuantity;
  final int newQuantity;
  final String? reason;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemHistoryResponse({
    required this.id,
    required this.itemId,
    required this.changeType,
    required this.quantity,
    required this.oldQuantity,
    required this.newQuantity,
    this.reason,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ItemHistoryResponse(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      changeType: json['change_type'] as String,
      quantity: json['quantity'] as int,
      oldQuantity: json['old_quantity'] as int,
      newQuantity: json['new_quantity'] as int,
      reason: json['reason'] as String?,
      updatedBy: json['updated_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'item_id': itemId,
      'change_type': changeType,
      'quantity': quantity,
      'old_quantity': oldQuantity,
      'new_quantity': newQuantity,
      'reason': reason,
      'updated_by': updatedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
    return map;
  }
}
