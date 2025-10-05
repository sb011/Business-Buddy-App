class CreateInventoryRequest {
  final String name;

  CreateInventoryRequest({required this.name});

  factory CreateInventoryRequest.fromJson(Map<String, dynamic> json) {
    return CreateInventoryRequest(name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}