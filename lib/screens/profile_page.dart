import 'package:business_buddy_app/screens/auth_page.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/strings.dart';
import '../constants/permissions.dart';
import '../utils/shared_preferences.dart';
import '../widgets/custom_button.dart';
import 'archived_items_page.dart';
import 'archived_expenses_page.dart';
import 'archived_variants_page.dart';
import 'inventory_users_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    final role = await StorageService.getString(AppStrings.role);
    setState(() {
      _userRole = role;
      _isLoading = false;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await StorageService.remove(AppStrings.authToken);

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => AuthPage(),
      ),
          (Route<dynamic> route) => false,
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: AppColors.textSecondary.withOpacity(0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Left Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.textDarkPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.textDarkPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDarkPrimary,
                    ),
                  ),
                ),
                
                // Right Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.textDarkPrimary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.person,
                size: 80,
                color: AppColors.textDarkPrimary,
              ),
              const SizedBox(height: 20),
              const Text(
                'Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage your account settings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
          
              // Archive Items List Item - All roles can access
              if (_userRole != null && AppPermissions.hasPermission(_userRole!, AppPermissions.archiveItem))
                _buildListItem(
                  icon: Icons.inventory_2_outlined,
                  title: "Archive Items",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ArchivedItemsPage(),
                      ),
                    );
                  },
                ),
              
              // Archive Expenses List Item - Only Owner and Manager
              if (_userRole != null && AppPermissions.hasPermission(_userRole!, AppPermissions.getExpense))
                _buildListItem(
                  icon: Icons.receipt_long_outlined,
                  title: "Archive Expenses",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ArchivedExpensesPage(),
                      ),
                    );
                  },
                ),
              
              // Archive Variants List Item - Owner, Manager, Inventory Handler
              if (_userRole != null && AppPermissions.hasPermission(_userRole!, AppPermissions.getItemVariant))
                _buildListItem(
                  icon: Icons.inventory_outlined,
                  title: "Archive Variants",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ArchivedVariantsPage(),
                      ),
                    );
                  },
                ),
              
              // Inventory Users List Item - Only Owner
              if (_userRole != null && AppPermissions.hasPermission(_userRole!, AppPermissions.getInventoryUsers))
                _buildListItem(
                  icon: Icons.people_outlined,
                  title: "Inventory Users",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const InventoryUsersPage(),
                      ),
                    );
                  },
                ),
              
              const Spacer(),
              
              // Logout Text - Always visible
              Center(
                child: GestureDetector(
                  onTap: () => _logout(context),
                  child: Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDarkPrimary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

