class Customer {
  final String id;
  final String name;
  final String mobileNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      mobileNumber: json['mobile_number'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile_number': mobileNumber,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class BillItem {
  final String id;
  final String itemId;
  final String billId;
  final int quantity;
  final double pricePerUnit;
  final DateTime createdAt;
  final DateTime updatedAt;

  BillItem({
    required this.id,
    required this.itemId,
    required this.billId,
    required this.quantity,
    required this.pricePerUnit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      billId: json['bill_id'] as String,
      quantity: json['quantity'] as int,
      pricePerUnit: json['price_per_unit'] as double,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'bill_id': billId,
      'quantity': quantity,
      'price_per_unit': pricePerUnit,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

