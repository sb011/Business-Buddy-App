class User {
  final String id;
  final String mobileNumber;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String role;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.mobileNumber,
    this.firstName,
    this.lastName,
    this.email,
    required this.role,
    this.profilePicture,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      mobileNumber: json['mobile_number'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String,
      profilePicture: json['profile_picture'] as String?,
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
      'role': role,
      'profile_picture': profilePicture,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
