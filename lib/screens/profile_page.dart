import 'package:business_buddy_app/screens/auth_page.dart';
import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../constants/permissions.dart';
import '../utils/shared_preferences.dart';
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 60),
          const Icon(
            Icons.person,
            size: 80,
            color: Colors.purple,
          ),
          const SizedBox(height: 20),
          const Text(
            'Profile',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Manage your account settings',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 40),
          
          // Archive Items Button - All roles can access
          if (_userRole != null && AppPermissions.hasPermission(_userRole!, AppPermissions.archiveItem))
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ArchivedItemsPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Archive Items'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          
          // Archive Expenses Button - Only Owner and Manager
          if (_userRole != null && AppPermissions.hasPermission(_userRole!, AppPermissions.getExpense))
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ArchivedExpensesPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('Archive Expenses'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          
          // Archive Variants Button - Owner, Manager, Inventory Handler
          if (_userRole != null && AppPermissions.hasPermission(_userRole!, AppPermissions.getItemVariant))
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ArchivedVariantsPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.inventory_outlined),
                  label: const Text('Archive Variants'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          
          // Inventory Users Button - Only Owner
          if (_userRole != null && AppPermissions.hasPermission(_userRole!, AppPermissions.getInventoryUsers))
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const InventoryUsersPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.people_outlined),
                  label: const Text('Inventory Users'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          
          // Logout Button - Always visible
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

