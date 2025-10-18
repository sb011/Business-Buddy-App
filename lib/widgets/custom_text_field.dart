import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/style.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool filled;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? style;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double? borderWidth;
  final double? focusedBorderWidth;
  final double? errorBorderWidth;
  final double? borderRadius;
  final bool readOnly;
  final String? initialValue;
  final AutovalidateMode? autovalidateMode;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.filled = true,
    this.fillColor,
    this.contentPadding,
    this.hintStyle,
    this.labelStyle,
    this.style,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderWidth,
    this.focusedBorderWidth,
    this.errorBorderWidth,
    this.borderRadius,
    this.readOnly = false,
    this.initialValue,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      readOnly: readOnly,
      autovalidateMode: autovalidateMode,
      style: style,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        hintStyle: hintStyle ?? const TextStyle(color: AppColors.textSecondary),
        labelStyle: labelStyle,
        contentPadding: contentPadding,
        filled: filled,
        fillColor: fillColor ?? AppColors.background,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius ?? Style.radius),
          ),
          borderSide: BorderSide(
            color: borderColor ?? AppColors.textSecondary.withValues(alpha: 0.3),
            width: borderWidth ?? 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius ?? Style.radius),
          ),
          borderSide: BorderSide(
            color: focusedBorderColor ?? AppColors.textSecondary,
            width: focusedBorderWidth ?? 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius ?? Style.radius),
          ),
          borderSide: BorderSide(
            color: errorBorderColor ?? AppColors.danger.withValues(alpha: 0.5),
            width: errorBorderWidth ?? 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius ?? Style.radius),
          ),
          borderSide: BorderSide(
            color: errorBorderColor ?? AppColors.danger,
            width: errorBorderWidth ?? 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius ?? Style.radius),
          ),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.3),
            width: borderWidth ?? 1.5,
          ),
        ),
      ),
    );
  }
}