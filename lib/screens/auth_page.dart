import 'package:business_buddy_app/constants/colors.dart';
import 'package:business_buddy_app/screens/register_page.dart';
import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../constants/style.dart';
import '../utils/shared_preferences.dart';
import '../widgets/custom_button.dart';
import 'login_page.dart';
import 'main_navigation.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final String? token = await StorageService.getString(AppStrings.authToken);

    if (token != null && token.isNotEmpty) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome Image
              Image.asset(
                'assets/images/welcome_img.png',
                height: 300,
                width: 300,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue[200]!, width: 2),
                    ),
                    child: const Icon(
                      Icons.business,
                      size: 80,
                      color: Colors.blue,
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              
              const Text(
                "Business Buddy",
                style: TextStyle(
                  fontSize: Style.fontSize3,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDarkPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Manage your business easily\nTrack inventory, sales & customers",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: Style.fontSize6, color: Colors.black54),
              ),
              const SizedBox(height: 60),

              // Register Button
              CustomButtons.primary(
                text: "Register",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Login Button
              CustomButtons.secondary(
                text: "Login",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
