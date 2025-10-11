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

class UserWithRole {
  final String id;
  final String mobileNumber;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profilePicture;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserWithRole({
    required this.id,
    required this.mobileNumber,
    this.firstName,
    this.lastName,
    this.email,
    this.profilePicture,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserWithRole.fromJson(Map<String, dynamic> json) {
    return UserWithRole(
      id: json['id'] as String,
      mobileNumber: json['mobile_number'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      profilePicture: json['profile_picture'] as String?,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobile_number': mobileNumber,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'profile_picture': profilePicture,
      'role': role,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

