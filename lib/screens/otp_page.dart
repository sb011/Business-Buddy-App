import 'package:business_buddy_app/models/auth/auth_request.dart';
import 'package:business_buddy_app/screens/user_update_details_page.dart';
import 'package:business_buddy_app/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../api_calls/auth_apis.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../models/auth/auth_response.dart';
import '../utils/shared_preferences.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_otp_input.dart';
import 'main_navigation.dart';

class OTPPage extends StatefulWidget {
  final String phoneNumber;

  const OTPPage({super.key, required this.phoneNumber});

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final _formKey = GlobalKey<FormState>();
  String _otpValue = '';
  bool _isLoading = false;
  bool _isResending = false;
  int _countdownSeconds = 20;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    StorageService.checkLoginStatus();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isResending = true;
    });

    try {
      final loginRequest = LoginRequest(mobileNumber: widget.phoneNumber);

      await AuthAPI.resendOtp(
        context: context,
        loginRequest: loginRequest,
      );
      
      // Reset countdown
      _countdownTimer?.cancel();
      _countdownSeconds = 60;
      _startCountdown();
      
      if (mounted) {
        CustomSnackBar.showSuccess(context, "OTP resent successfully.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    String phone = widget.phoneNumber;
    String otp = _otpValue.trim();

    final otpRequest = OtpRequest(mobileNumber: phone.trim(), otp: otp.trim());

    setState(() => _isLoading = true);

    try {
      final ValidateOtpResponse result = await AuthAPI.validateOtp(
        context: context,
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
                  'Verify OTP',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),
                
                // OTP Input
                CustomOTPInput(
                  length: 6,
                  onChanged: (value) {
                    setState(() {
                      _otpValue = value;
                    });
                  },
                  onCompleted: (value) {
                    // Auto-submit when OTP is complete
                    if (value.length == 6) {
                      _verifyOTP();
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter OTP';
                    }
                    if (value.length != 6) {
                      return 'Please enter a valid 6-digit OTP';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Resend OTP Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (_countdownSeconds > 0)
                      Text(
                        "Resend in ${_countdownSeconds}s",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _isResending ? null : _resendOTP,
                        child: Text(
                          _isResending ? "Resending..." : "Resend OTP",
                          style: TextStyle(
                            fontSize: 14,
                            color: _isResending 
                                ? AppColors.textSecondary 
                                : AppColors.textDarkPrimary,
                            fontWeight: FontWeight.w600,
                            decoration: _isResending 
                                ? TextDecoration.none 
                                : TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const Spacer(),
                
                // Verify Button
                CustomButtons.primary(
                  text: "Verify OTP",
                  onPressed: _isLoading ? null : _verifyOTP,
                  isLoading: _isLoading,
                  loadingText: "Verifying...",
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
