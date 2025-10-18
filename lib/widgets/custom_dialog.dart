import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'custom_button.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color? iconColor;
  final bool isLoading;
  final String? loadingText;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.icon,
    this.iconColor,
    this.isLoading = false,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      backgroundColor: AppColors.background,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.textDarkPrimary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor ?? AppColors.textDarkPrimary,
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDarkPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                // Cancel Button
                if (cancelText != null) ...[
                  Expanded(
                    child: CustomButtons.secondary(
                      text: cancelText!,
                      onPressed: isLoading ? null : onCancel,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                
                // Confirm Button
                Expanded(
                  child: CustomButtons.primary(
                    text: confirmText ?? 'Confirm',
                    onPressed: isLoading ? null : onConfirm,
                    isLoading: isLoading,
                    loadingText: loadingText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Convenience methods for common dialog types
class CustomDialogs {
  // Confirmation Dialog
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        iconColor: iconColor,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  // Archive Confirmation Dialog
  static Future<bool?> showArchiveConfirmation({
    required BuildContext context,
    required String itemName,
    required String itemType,
  }) {
    return showConfirmation(
      context: context,
      title: 'Archive $itemType?',
      message: 'Are you sure you want to archive "$itemName"? This action can be undone later.',
      confirmText: 'Archive',
      cancelText: 'Cancel',
      icon: Icons.archive,
      iconColor: AppColors.warning,
    );
  }

  // Delete Confirmation Dialog
  static Future<bool?> showDeleteConfirmation({
    required BuildContext context,
    required String itemName,
    required String itemType,
  }) {
    return showConfirmation(
      context: context,
      title: 'Delete $itemType?',
      message: 'Are you sure you want to delete "$itemName"? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      icon: Icons.delete,
      iconColor: AppColors.danger,
    );
  }

  // Success Dialog
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    IconData? icon,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        confirmText: buttonText,
        icon: icon ?? Icons.check_circle,
        iconColor: AppColors.success,
        onConfirm: () => Navigator.of(context).pop(),
      ),
    );
  }

  // Error Dialog
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    IconData? icon,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        confirmText: buttonText,
        icon: icon ?? Icons.error,
        iconColor: AppColors.danger,
        onConfirm: () => Navigator.of(context).pop(),
      ),
    );
  }

  // Warning Dialog
  static Future<bool?> showWarning({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Continue',
    String cancelText = 'Cancel',
    IconData? icon,
  }) {
    return showConfirmation(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      icon: icon ?? Icons.warning,
      iconColor: AppColors.warning,
    );
  }

  // Loading Dialog
  static Future<void> showLoading({
    required BuildContext context,
    required String title,
    required String message,
    required Future<void> Function() action,
    String loadingText = 'Loading...',
  }) async {
    bool isCompleted = false;
    
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        confirmText: 'OK',
        isLoading: true,
        loadingText: loadingText,
        onConfirm: () {
          if (isCompleted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );

    try {
      await action();
      isCompleted = true;
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      isCompleted = true;
      if (context.mounted) {
        Navigator.of(context).pop();
        showError(
          context: context,
          title: 'Error',
          message: e.toString(),
        );
      }
    }
  }
}
