class ApiEndpoints {
  static const String baseUrl = "10.0.2.2:8080";
  static const String register = "api/v1/register";
  static const String login = "api/v1/login";
  static const String validateOtp = "api/v1/validate/otp";
  static const String userUpdate = "api/v1/user";
  static const String inventoryItems = "api/v1/inventory/items";
  static const String createItem = "api/v1/inventory/item";
  static const String updateItem = "api/v1/inventory/item";
  static const String updateStock = "api/v1/inventory/item/stock";
  static String itemHistory(String itemId) => "api/v1/inventory/item/$itemId/history";
  static const String archiveItem = "api/v1/inventory/item/archive";
  static const String imageUpload = "api/v1/upload/image";
}