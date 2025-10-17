import 'package:business_buddy_app/models/auth/auth_request.dart';
import 'package:business_buddy_app/models/inventory/inventory_request.dart';
import 'package:flutter/material.dart';

import '../api_calls/auth_apis.dart';
import '../constants/colors.dart';
import '../constants/style.dart';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fill in your details to get started',
                  style: TextStyle(
                    fontSize: 16,
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
                        TextFormField(
                          controller: _inventoryNameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.business),
                            hintText: 'Enter Inventory Name',
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.textSecondary,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.textDarkPrimary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(color: AppColors.danger, width: 2),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(color: AppColors.danger, width: 2),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter inventory name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // First Name Field
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            hintText: 'Enter First Name',
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.textSecondary,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.textDarkPrimary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(color: AppColors.danger, width: 2),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(color: AppColors.danger, width: 2),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Last Name Field
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline),
                            hintText: 'Enter Last Name',
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.textSecondary,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.textDarkPrimary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(color: AppColors.danger, width: 2),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(color: AppColors.danger, width: 2),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            hintText: 'Enter Email (Optional)',
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.textSecondary,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.textDarkPrimary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Mobile Number Field
                        TextFormField(
                          controller: _mobileNumberController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            hintText: 'Enter Mobile Number',
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.textSecondary,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.textDarkPrimary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(color: AppColors.danger, width: 2),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Style.radius),
                              ),
                              borderSide: BorderSide(color: AppColors.danger, width: 2),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
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
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textDarkPrimary,
                      foregroundColor: AppColors.textLightPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Style.radius),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.textSecondary,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
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
