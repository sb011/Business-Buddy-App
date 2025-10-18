import 'package:business_buddy_app/models/auth/auth_request.dart';
import 'package:business_buddy_app/models/inventory/inventory_request.dart';
import 'package:flutter/material.dart';

import '../api_calls/auth_apis.dart';
import '../constants/colors.dart';
import '../constants/style.dart';
import '../constants/strings.dart';
import '../utils/shared_preferences.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
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
    StorageService.checkLoginStatus();
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final email = _emailController.text.trim().isEmpty
        ? ""
        : _emailController.text.trim();

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
        context: context,
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
                  'Create Account',
                  style: TextStyle(
                    fontSize: Style.fontSize3,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fill in your details to get started',
                  style: TextStyle(
                    fontSize: Style.fontSize6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Inventory Name Field
                        CustomTextField(
                          controller: _inventoryNameController,
                          hintText: 'Enter Inventory Name',
                          prefixIcon: Icons.business,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter inventory name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // First Name Field
                        CustomTextField(
                          controller: _firstNameController,
                          hintText: 'Enter First Name',
                          prefixIcon: Icons.person,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Last Name Field
                        CustomTextField(
                          controller: _lastNameController,
                          hintText: 'Enter Last Name',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Email Field
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Enter Email (Optional)',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        
                        // Mobile Number Field
                        CustomTextField(
                          controller: _mobileNumberController,
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
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Register Button
                CustomButtons.primary(
                  text: "Register",
                  onPressed: _isLoading ? null : _submitForm,
                  isLoading: _isLoading,
                  loadingText: "Creating account...",
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
