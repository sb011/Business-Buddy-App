import 'package:business_buddy_app/constants/roles.dart';

class AppPermissions {
  // User Management Permissions
  static const String addUserToInventory = "add_user_to_inventory";
  static const String getInventoryUsers = "get_inventory_users";
  static const String removeInventoryUsers = "remove_inventory_users";

  // Item Management Permissions
  static const String createItem = "create_item";
  static const String addItemVariant = "add_item_variant";
  static const String makeItemVariantArchive = "make_item_variant_archive";
  static const String updateItemVariant = "update_item_variant";
  static const String getItemVariant = "get_item_variant";
  static const String updateItem = "update_item";
  static const String updateStock = "update_stock";
  static const String getItemVariantHistory = "get_item_variant_history";
  static const String getInventoryItem = "get_inventory_item";
  static const String archiveItem = "archive_item";

  // Expense Management Permissions
  static const String addExpense = "add_expense";
  static const String getExpense = "get_expense";
  static const String updateExpense = "update_expense";
  static const String archiveExpense = "archive_expense";

  // Bill Management Permissions
  static const String createBill = "create_bill";
  static const String getBill = "get_bill";

  // Customer Management Permissions
  static const String getCustomer = "get_customer";

  // Role-Permission Mapping
  static const Map<String, Map<String, bool>> rolePermissions = {
    AppRoles.owner: {
      addUserToInventory: true,
      getInventoryUsers: true,
      removeInventoryUsers: true,
      createItem: true,
      addItemVariant: true,
      makeItemVariantArchive: true,
      updateItemVariant: true,
      getItemVariant: true,
      updateItem: true,
      updateStock: true,
      getItemVariantHistory: true,
      getInventoryItem: true,
      archiveItem: true,
      addExpense: true,
      getExpense: true,
      updateExpense: true,
      archiveExpense: true,
      createBill: true,
      getBill: true,
      getCustomer: true,
    },
    AppRoles.manager: {
      createItem: true,
      addItemVariant: true,
      makeItemVariantArchive: true,
      updateItemVariant: true,
      getItemVariant: true,
      updateItem: true,
      updateStock: true,
      getItemVariantHistory: true,
      getInventoryItem: true,
      archiveItem: true,
      addExpense: true,
      getExpense: true,
      updateExpense: true,
      archiveExpense: true,
      createBill: true,
      getBill: true,
      getCustomer: true,
    },
    AppRoles.inventoryHandler: {
      createItem: true,
      addItemVariant: true,
      makeItemVariantArchive: true,
      updateItemVariant: true,
      getItemVariant: true,
      updateItem: true,
      updateStock: true,
      getItemVariantHistory: true,
      getInventoryItem: true,
      archiveItem: true,
      createBill: true,
      getBill: true,
      getCustomer: true,
    },
    AppRoles.cashier: {
      getInventoryItem: true,
      createBill: true,
      getBill: true,
      getCustomer: true,
    },
  };

  // Check if a role has a specific permission
  static bool hasPermission(String role, String permission) {
    final rolePerms = rolePermissions[role];
    if (rolePerms == null) return false;
    return rolePerms[permission] ?? false;
  }

  // Get all permissions for a role
  static List<String> getRolePermissions(String role) {
    final rolePerms = rolePermissions[role];
    if (rolePerms == null) return [];
    
    return rolePerms.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();
  }
}
