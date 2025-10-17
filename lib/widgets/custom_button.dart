import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/style.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Widget? icon;
  final Widget? loadingWidget;
  final double? elevation;
  final Color? shadowColor;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.fontSize,
    this.fontWeight,
    this.icon,
    this.loadingWidget,
    this.elevation,
    this.shadowColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? loadingWidget ??
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize ?? 18,
                  fontWeight: fontWeight ?? FontWeight.w600,
                  color: textColor ?? (isOutlined ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
                ),
              ),
            ],
          );

    if (isOutlined) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? AppColors.textDarkPrimary,
            padding: padding ?? const EdgeInsets.symmetric(vertical: 18),
            side: BorderSide(
              color: borderColor ?? AppColors.textDarkPrimary,
              width: borderWidth ?? 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? Style.radius),
            ),
          ),
          child: buttonChild,
        ),
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.textDarkPrimary,
          foregroundColor: textColor ?? AppColors.textLightPrimary,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? Style.radius),
          ),
          elevation: elevation ?? 4,
          shadowColor: shadowColor ?? AppColors.textSecondary,
        ),
        child: buttonChild,
      ),
    );
  }
}

// Convenience constructors for common button types
class CustomButtons {
  // Primary button (filled, black background)
  static Widget primary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    Widget? icon,
    Widget? loadingWidget,
    String? loadingText,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
      loadingWidget: loadingWidget ??
          (loadingText != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      loadingText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : null),
    );
  }

  // Secondary button (outlined, black border)
  static Widget secondary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    Widget? icon,
    Widget? loadingWidget,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      isOutlined: true,
      icon: icon,
      loadingWidget: loadingWidget,
    );
  }

  // Success button (green)
  static Widget success({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    Widget? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      backgroundColor: Colors.green,
      icon: icon,
    );
  }

  // Danger button (red)
  static Widget danger({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isFullWidth = true,
    Widget? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      backgroundColor: Colors.red,
      icon: icon,
    );
  }

  // Small button
  static Widget small({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isOutlined = false,
    Widget? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isFullWidth: false,
      isOutlined: isOutlined,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      fontSize: 14,
      icon: icon,
    );
  }

  // Icon button
  static Widget icon({
    required IconData iconData,
    required VoidCallback? onPressed,
    bool isLoading = false,
    String? tooltip,
  }) {
    return CustomButton(
      text: '',
      onPressed: onPressed,
      isLoading: isLoading,
      isFullWidth: false,
      padding: const EdgeInsets.all(12),
      icon: Icon(iconData),
      loadingWidget: const SizedBox(
        height: 16,
        width: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
