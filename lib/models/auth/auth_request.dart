import '../inventory/inventory_request.dart';

class RegisterRequest {
  final UserRegisterRequest user;
  final CreateInventoryRequest inventory;

  RegisterRequest({required this.user, required this.inventory});

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      user: UserRegisterRequest.fromJson(json['user'] as Map<String, dynamic>),
      inventory: CreateInventoryRequest.fromJson(
        json['inventory'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'inventory': inventory.toJson()};
  }
}

class UserRegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String mobileNumber;
  final String profilePicture;

  UserRegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNumber,
    required this.profilePicture,
  });

  factory UserRegisterRequest.fromJson(Map<String, dynamic> json) {
    return UserRegisterRequest(
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      mobileNumber: json['mobile_number'] as String,
      profilePicture: json['profile_picture'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile_number': mobileNumber,
      'profile_picture': profilePicture,
    };
  }
}

class LoginRequest {
  final String mobileNumber;

  LoginRequest({required this.mobileNumber});

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(mobileNumber: json['mobile_number'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'mobile_number': mobileNumber};
  }
}

class OtpRequest {
  final String mobileNumber;
  final String otp;

  OtpRequest({required this.mobileNumber, required this.otp});

  factory OtpRequest.fromJson(Map<String, dynamic> json) {
    return OtpRequest(
      mobileNumber: json['mobile_number'] as String,
      otp: json['otp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'mobile_number': mobileNumber, 'otp': otp};
  }
}

class UpdateUserRequest {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String mobileNumber;
  final String profilePicture;

  UpdateUserRequest({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNumber,
    required this.profilePicture,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) {
    return UpdateUserRequest(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      mobileNumber: json['mobile_number'] as String,
      profilePicture: json['profile_picture'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile_number': mobileNumber,
      'profile_picture': profilePicture,
    };
  }
}

class UserToInventoryRequest {
  final String mobileNumber;
  final String role;

  UserToInventoryRequest({required this.mobileNumber, required this.role});

  factory UserToInventoryRequest.fromJson(Map<String, dynamic> json) {
    return UserToInventoryRequest(
      mobileNumber: json['mobile_number'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'mobile_number': mobileNumber, 'role': role};
  }
}

class AddUsersToInventoryRequest {
  final List<UserToInventoryRequest> users;

  AddUsersToInventoryRequest({
    required this.users
  });

  factory AddUsersToInventoryRequest.fromJson(Map<String, dynamic> json) {
    return AddUsersToInventoryRequest(
      users: (json['users'] as List<dynamic>)
          .map((item) => UserToInventoryRequest.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'users': users.map((user) => user.toJson()).toList()};
  }
}
