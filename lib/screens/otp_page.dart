import 'package:business_buddy_app/models/auth/auth_request.dart';
import 'package:business_buddy_app/screens/user_update_details_page.dart';
import 'package:flutter/material.dart';

import '../api_calls/auth_apis.dart';
import '../constants/strings.dart';
import '../models/auth/auth_response.dart';
import '../utils/shared_preferences.dart';
import 'main_navigation.dart';

class OTPPage extends StatefulWidget {
  final String phoneNumber;

  const OTPPage({super.key, required this.phoneNumber});

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _otpController.dispose();
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

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    String phone = widget.phoneNumber;
    String otp = _otpController.text.trim();

    final otpRequest = OtpRequest(mobileNumber: phone.trim(), otp: otp.trim());

    setState(() => _isLoading = true);

    try {
      final ValidateOtpResponse result = await AuthAPI.validateOtp(
        otpRequest: otpRequest,
      ).timeout(const Duration(seconds: 10));

      setState(() => _isLoading = false);

      await StorageService.setString(AppStrings.authToken, result.token);
      await StorageService.setString(AppStrings.userId, result.user.id);
      await StorageService.setString(
        AppStrings.inventoryId,
        result.inventory.id,
      );
      await StorageService.setString(AppStrings.role, result.user.role);

      final user = result.user;
      final firstName = user.firstName;
      final lastName = user.lastName;

      final needsDetails = (firstName != null && firstName.isEmpty) || (lastName != null && lastName.isEmpty);
      if (needsDetails) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => UserUpdateDetailsPage(
                id: user.id,
                phoneNumber: user.mobileNumber,
                firstName: firstName ?? '',
                lastName: lastName ?? '',
                email: user.email ?? '',
                profilePicturePath: user.profilePicture ?? '',
              ),
            ),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
          (Route<dynamic> route) => false,
        );
      }
    } on Exception catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Enter OTP sent to ${widget.phoneNumber}'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Enter otp"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter otp';
                  }
                  if (value.length != 6) {
                    return 'Please enter a valid 6-digit OTP';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _verifyOTP,
                      child: const Text('Verify'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
