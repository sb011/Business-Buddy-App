import 'package:business_buddy_app/models/inventory/inventory.dart';

import 'auth.dart';

class ValidateOtpResponse {
  final String token;
  final User user;
  final Inventory inventory;

  ValidateOtpResponse({
    required this.token,
    required this.user,
    required this.inventory,
  });

  factory ValidateOtpResponse.fromJson(Map<String, dynamic> json) {
    return ValidateOtpResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      inventory: Inventory.fromJson(json['inventory'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'inventory': inventory.toJson(),
    };
  }
}
