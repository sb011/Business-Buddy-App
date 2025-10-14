class ApiEndpoints {
  static const String baseUrl = "10.0.2.2:8080";
  static const String register = "api/v1/register";
  static const String login = "api/v1/login";
  static const String validateOtp = "api/v1/validate/otp";
  static const String userUpdate = "api/v1/user";
  static const String inventoryItems = "api/v1/inventory/items";
  static const String createItem = "api/v1/inventory/item";
  static const String updateItem = "api/v1/inventory/item";
  static const String updateStock = "api/v1/inventory/item/variant/stock";
  static String itemVariantHistory(String itemVariantId) => "api/v1/inventory/item/variant/$itemVariantId/history";
  static const String archiveItem = "api/v1/inventory/item/archive";
  static const String createExpense = "api/v1/expense";
  static const String getExpenses = "api/v1/expenses";
  static const String updateExpense = "api/v1/expense";
  static const String archiveExpense = "api/v1/expense/archive";
  static const String getBills = "api/v1/bills";
  static const String createBill = "api/v1/bill";
  static const String getCustomers = "api/v1/customers";
  static const String getInventoryUsers = "api/v1/inventory/users";
  static const String addUsersToInventory = "api/v1/add/users/to/inventory";
  static const String removeUserFromInventory = "api/v1/inventory/user";
  static const String addItemVariant = "api/v1/inventory/item/variant";
  static const String updateItemVariant = "api/v1/inventory/item/variant";
  static const String archiveItemVariant = "api/v1/inventory/item/variant/archive";
  static const String getItemVariants = "api/v1/inventory/item/variants";
  static const String imageUpload = "api/v1/upload/image";
}