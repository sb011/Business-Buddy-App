import 'package:flutter/material.dart';
import 'inventory_page.dart';
import 'bill_page.dart';
import 'expense_page.dart';
import 'profile_page.dart';
import 'auth_page.dart';
import '../constants/colors.dart';
import '../constants/permissions.dart';
import '../constants/strings.dart';
import '../utils/shared_preferences.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0; // Start with Bill page (index 0)
  List<Widget> _pages = [];
  List<BottomNavigationBarItem> _navigationItems = [];

  @override
  void initState() {
    super.initState();
    _buildNavigationItems();
  }

  Future<void> _buildNavigationItems() async {
    final role = await StorageService.getString(AppStrings.role);
    if (role == null) {
      // Remove token and redirect to auth page
      await StorageService.remove(AppStrings.authToken);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthPage()),
        (Route<dynamic> route) => false,
      );
      return;
    }

    final List<Widget> pages = [];
    final List<BottomNavigationBarItem> items = [];
    int currentIndex = 0;

    // Bill Page - All roles can access
    if (AppPermissions.hasPermission(role, AppPermissions.getBill)) {
      pages.add(const BillPage());
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long_outlined),
        activeIcon: Icon(Icons.receipt_long),
        label: 'Bill',
      ));
      if (_currentIndex == 0) currentIndex = pages.length - 1;
    }

    // Inventory Page
    if (AppPermissions.hasPermission(role, AppPermissions.createItem)) {
      pages.add(const InventoryPage());
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.inventory_2_outlined),
        activeIcon: Icon(Icons.inventory_2),
        label: 'Inventory',
      ));
      if (_currentIndex == 1) currentIndex = pages.length - 1;
    }

    // Expense Page - Only Owner and Manager
    if (AppPermissions.hasPermission(role, AppPermissions.getExpense)) {
      pages.add(const ExpensePage());
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.monetization_on_outlined),
        activeIcon: Icon(Icons.monetization_on),
        label: 'Expense',
      ));
      if (_currentIndex == 2) currentIndex = pages.length - 1;
    }

    // Profile Page - Always visible for all roles
    pages.add(const ProfilePage());
    items.add(const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ));
    if (_currentIndex == 3) currentIndex = pages.length - 1;

    setState(() {
      _pages = pages;
      _navigationItems = items;
      _currentIndex = currentIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) {
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
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.textDarkPrimary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          elevation: 10,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: _navigationItems,
        ),
      ),
    );
  }
}

