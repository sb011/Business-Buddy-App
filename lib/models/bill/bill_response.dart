import 'package:business_buddy_app/models/bill/bill.dart';

class BillResponse {
  final String id;
  final String inventoryId;
  final Customer customer;
  final List<BillItem> items;
  final double totalAmount;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  BillResponse({
    required this.id,
    required this.inventoryId,
    required this.customer,
    required this.items,
    required this.totalAmount,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BillResponse.fromJson(Map<String, dynamic> json) {
    return BillResponse(
      id: json['id'] as String,
      inventoryId: json['inventory_id'] as String,
      customer: Customer.fromJson(
        json['customer'] as Map<String, dynamic>,
      ),
      items: (json['items'] as List<dynamic>)
          .map((item) => BillItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: json['total_amount'] as double,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventory_id': inventoryId,
      'customer': customer.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}


