import 'package:business_buddy_app/constants/constants.dart';
import 'package:business_buddy_app/utils/shared_preferences.dart';

class PermissionHelper {
  static Future<bool> hasPermission(String permission) async {
    final String? role = await StorageService.getString(AppStrings.role);
    if (role == null) {
      // show error message that unauthorized and redirect to login page
      return false;
    }

    return AppPermissions.hasPermission(role, permission);
  }
}