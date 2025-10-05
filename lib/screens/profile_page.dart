import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../utils/shared_preferences.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _logout(BuildContext context) async {
    await StorageService.remove(AppStrings.authToken);

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person,
            size: 80,
            color: Colors.purple,
          ),
          const SizedBox(height: 20),
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Manage your account settings',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }
}

