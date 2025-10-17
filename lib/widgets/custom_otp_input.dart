import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../constants/style.dart';

class CustomOTPInput extends StatefulWidget {
  final int length;
  final Function(String) onChanged;
  final Function(String)? onCompleted;
  final String? Function(String?)? validator;
  final bool enabled;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double? borderRadius;
  final double? boxSize;
  final double? spacing;

  const CustomOTPInput({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.onCompleted,
    this.validator,
    this.enabled = true,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius,
    this.boxSize,
    this.spacing,
  });

  @override
  State<CustomOTPInput> createState() => _CustomOTPInputState();
}

class _CustomOTPInputState extends State<CustomOTPInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  String _otpValue = '';

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(String value, int index) {
    // Handle paste
    if (value.length > 1) {
      if (value.length == widget.length) {
        // Pasted complete OTP
        for (int i = 0; i < widget.length; i++) {
          _controllers[i].text = value[i];
        }
        _updateOTPValue();
        _focusNodes[widget.length - 1].requestFocus();
        return;
      }
      // Take only the last character
      _controllers[index].text = value[value.length - 1];
    }

    _updateOTPValue();

    // Move to next field if digit entered
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    // Handle backspace - move to previous field if current is empty
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Check if OTP is complete
    if (_otpValue.length == widget.length) {
      widget.onCompleted?.call(_otpValue);
    }
  }

  void _updateOTPValue() {
    _otpValue = _controllers.map((controller) => controller.text).join();
    widget.onChanged(_otpValue);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.length,
        (index) => Container(
          margin: EdgeInsets.symmetric(
            horizontal: (widget.spacing ?? 8.0) / 2,
          ),
          width: widget.boxSize ?? 50,
          height: widget.boxSize ?? 50,
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            enabled: widget.enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkPrimary,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.background,
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  widget.borderRadius ?? Style.radius,
                ),
                borderSide: BorderSide(
                  color: widget.borderColor ?? AppColors.textSecondary,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  widget.borderRadius ?? Style.radius,
                ),
                borderSide: BorderSide(
                  color: widget.focusedBorderColor ?? AppColors.textDarkPrimary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  widget.borderRadius ?? Style.radius,
                ),
                borderSide: BorderSide(
                  color: widget.errorBorderColor ?? AppColors.danger,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  widget.borderRadius ?? Style.radius,
                ),
                borderSide: BorderSide(
                  color: widget.errorBorderColor ?? AppColors.danger,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) => _onTextChanged(value, index),
            validator: widget.validator != null
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return '';
                    }
                    return null;
                  }
                : null,
          ),
        ),
      ),
    );
  }
}

// Convenience widget for OTP validation
class OTPValidator {
  static String? validateOTP(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'Please enter OTP';
    }
    if (value.length != length) {
      return 'Please enter a valid $length-digit OTP';
    }
    return null;
  }
}