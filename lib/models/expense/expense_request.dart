class CreateExpenseRequest {
  final String title;
  final String? description;
  final String type;
  final double amount;

  CreateExpenseRequest({
    required this.title,
    this.description,
    required this.type,
    required this.amount,
  });

  factory CreateExpenseRequest.fromJson(Map<String, dynamic> json) {
    return CreateExpenseRequest(
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      amount: json['amount'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'amount': amount,
    };
  }
}

class UpdateExpenseRequest {
  final String id;
  final String title;
  final String? description;
  final String type;
  final double amount;

  UpdateExpenseRequest({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.amount,
  });

  factory UpdateExpenseRequest.fromJson(Map<String, dynamic> json) {
    return UpdateExpenseRequest(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      amount: json['amount'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'amount': amount,
    };
  }
}

class ExpenseArchiveRequest {
  final String expenseId;
  final bool isArchive;

  ExpenseArchiveRequest({
    required this.expenseId,
    required this.isArchive,
  });

  factory ExpenseArchiveRequest.fromJson(Map<String, dynamic> json) {
    return ExpenseArchiveRequest(
      expenseId: json['expense_id'] as String,
      isArchive: json['is_archive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expense_id': expenseId,
      'is_archive': isArchive,
    };
  }
}