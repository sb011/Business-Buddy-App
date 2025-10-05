import 'package:business_buddy_app/models/auth/auth_request.dart';
import 'package:flutter/material.dart';

import '../api_calls/auth_apis.dart';
import '../constants/strings.dart';
import '../utils/shared_preferences.dart';
import 'main_navigation.dart';
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
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
      ).timeout(const Duration(seconds: 10));
      setState(() => _isLoading = false);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OTPPage(phoneNumber: phone)),
      );
    } on Exception catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Enter Mobile Number",
                  border: OutlineInputBorder(),
                ),
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
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitPhoneNumber,
                      child: const Text('Submit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
