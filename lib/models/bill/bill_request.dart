class CreateBillCustomer {
  final String? id;
  final String name;
  final String mobileNumber;

  CreateBillCustomer({
    required this.id,
    required this.name,
    required this.mobileNumber,
  });

  factory CreateBillCustomer.fromJson(Map<String, dynamic> json) {
    return CreateBillCustomer(
        id: json['id'] as String?,
        name: json['name'] as String,
        mobileNumber: json['mobile_number'] as String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile_number': mobileNumber
    };
  }
}

class CreateBillItem {
  final String itemId;
  final int quantity;

  CreateBillItem({
    required this.itemId,
    required this.quantity,
  });

  factory CreateBillItem.fromJson(Map<String, dynamic> json) {
    return CreateBillItem(
        itemId: json['item_id'] as String,
        quantity: json['quantity'] as int
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'quantity': quantity
    };
  }
}

class CreateBillRequest {
  final CreateBillCustomer customer;
  final List<CreateBillItem> items;

  CreateBillRequest({
    required this.customer,
    required this.items,
  });

  factory CreateBillRequest.fromJson(Map<String, dynamic> json) {
    return CreateBillRequest(
      customer: CreateBillCustomer.fromJson(
        json['customer'] as Map<String, dynamic>,
      ),
      items: (json['items'] as List<dynamic>)
          .map((item) => CreateBillItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer': customer.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}