import 'package:flutter/material.dart';

class CustomSnackBar {
  /// Shows a success snackbar with green background
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      icon: Icons.check_circle,
    );
  }

  /// Shows an error snackbar with red background
  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      icon: Icons.error,
    );
  }

  /// Shows a warning snackbar with orange background
  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      icon: Icons.warning,
    );
  }

  /// Shows an info snackbar with blue background
  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      icon: Icons.info,
    );
  }

  /// Shows a custom snackbar with specified parameters
  static void showCustom(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: backgroundColor ?? Colors.grey,
      textColor: textColor ?? Colors.white,
      icon: icon,
      duration: duration,
    );
  }

  /// Internal method to show the snackbar
  static void _showSnackBar({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: textColor,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: textColor.withOpacity(0.8),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Hides the current snackbar
  static void hide(BuildContext context) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }
}
