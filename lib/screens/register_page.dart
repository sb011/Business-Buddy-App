import 'package:business_buddy_app/models/auth/auth_request.dart';
import 'package:business_buddy_app/models/inventory/inventory_request.dart';
import 'package:flutter/material.dart';

import '../api_calls/auth_apis.dart';
import '../constants/strings.dart';
import '../utils/shared_preferences.dart';
import 'main_navigation.dart';
import 'otp_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _inventoryNameController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _inventoryNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final email = _emailController.text.trim().isEmpty
        ? ""
        : _emailController.text.trim();

    // TODO: profile picture
    final userRegisterRequest = UserRegisterRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: email,
      mobileNumber: _mobileNumberController.text.trim(),
      profilePicture: "",
    );
    final createInventoryRequest = CreateInventoryRequest(
      name: _inventoryNameController.text.trim(),
    );
    final registerRequest = RegisterRequest(
      user: userRegisterRequest,
      inventory: createInventoryRequest,
    );

    setState(() => _isLoading = true);

    try {
      await AuthAPI.register(
        registerRequest: registerRequest,
      ).timeout(const Duration(seconds: 10));
      setState(() => _isLoading = false);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              OTPPage(phoneNumber: _mobileNumberController.text.trim()),
        ),
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
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _inventoryNameController,
                decoration: const InputDecoration(labelText: "Inventory Name"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter inventory name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: "First Name"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: "Last Name"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email (optional)",
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mobileNumberController,
                decoration: const InputDecoration(labelText: "Mobile Number"),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter mobile number';
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
                      onPressed: _submitForm,
                      child: const Text("Register"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
