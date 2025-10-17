import 'package:business_buddy_app/models/auth/auth_request.dart';
import 'package:flutter/material.dart';

import '../api_calls/auth_apis.dart';
import '../constants/colors.dart';
import '../constants/style.dart';
import '../utils/shared_preferences.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'otp_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    StorageService.checkLoginStatus();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitPhoneNumber() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    String phone = _phoneController.text.trim();
    setState(() => _isLoading = true);

    final loginRequest = LoginRequest(mobileNumber: phone);
    try {
      await AuthAPI.login(
        loginRequest: loginRequest,
        context: context,
      ).timeout(const Duration(seconds: 10));
      setState(() => _isLoading = false);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OTPPage(phoneNumber: phone)),
      );
    } on Exception catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your mobile number to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Phone Number Field
                CustomTextField(
                  controller: _phoneController,
                  hintText: 'Enter Mobile Number',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter mobile number';
                    }
                    if (value.length != 10) {
                      return 'Mobile number should have 10 digits';
                    }
                    return null;
                  },
                ),

                const Spacer(),

                // Login Button
                CustomButtons.primary(
                  text: "Login",
                  onPressed: _isLoading ? null : _submitPhoneNumber,
                  isLoading: _isLoading,
                  loadingText: "Logging in...",
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
