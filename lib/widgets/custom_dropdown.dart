import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final String? Function(T?)? validator;
  final bool isExpanded;
  final double? menuMaxHeight;
  final double? itemHeight;
  final EdgeInsetsGeometry? margin;
  final List<T>? options;
  final String Function(T)? displayText;
  final IconData Function(T)? itemIcon;

  const CustomDropdown({
    super.key,
    this.items = const [],
    this.value,
    this.onChanged,
    this.hintText,
    this.validator,
    this.isExpanded = true,
    this.menuMaxHeight,
    this.itemHeight,
    this.margin,
    this.options,
    this.displayText,
    this.itemIcon,
  });

  @override
  Widget build(BuildContext context) {
    // Generate items from options if provided, otherwise use provided items
    final List<DropdownMenuItem<T>> finalItems = options != null && options!.isNotEmpty
        ? options!.map((T option) {
            return DropdownMenuItem<T>(
              value: option,
              child: Row(
                children: [
                  if (itemIcon != null) ...[
                    Icon(itemIcon!(option), color: AppColors.textDarkPrimary, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    displayText != null ? displayText!(option) : option.toString(),
                    style: const TextStyle(color: AppColors.textDarkPrimary),
                  ),
                ],
              ),
            );
          }).toList()
        : items.isNotEmpty ? items : [];

    return Container(
      margin: margin,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        items: finalItems,
        onChanged: onChanged,
        validator: validator,
        isExpanded: isExpanded,
        menuMaxHeight: menuMaxHeight,
        itemHeight: itemHeight,
        borderRadius: BorderRadius.circular(12),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.textDarkPrimary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.danger, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.3)),
          ),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textDarkPrimary,
        ),
        dropdownColor: AppColors.background,
        icon: Icon(Icons.arrow_drop_down, color: AppColors.textDarkPrimary),
      ),
    );
  }
}

// Convenience constructors for common dropdown types
class CustomDropdowns {
  // Generic String Dropdown with Options
  static Widget string({
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    String? hintText,
    IconData? itemIcon,
    String? Function(String?)? validator,
    EdgeInsetsGeometry? margin,
  }) {
    return CustomDropdown<String>(
      value: value,
      options: options,
      onChanged: onChanged,
      validator: validator,
      hintText: hintText,
      itemIcon: itemIcon != null ? (String option) => itemIcon : null,
      margin: margin,
    );
  }

  // Generic Dropdown with Custom Display Text
  static Widget custom<T>({
    required T? value,
    required List<T> options,
    required ValueChanged<T?> onChanged,
    String? hintText,
    String Function(T)? displayText,
    IconData Function(T)? itemIcon,
    String? Function(T?)? validator,
    EdgeInsetsGeometry? margin,
  }) {
    return CustomDropdown<T>(
      value: value,
      options: options,
      onChanged: onChanged,
      validator: validator,
      hintText: hintText,
      displayText: displayText,
      itemIcon: itemIcon,
      margin: margin,
    );
  }

  // Expense Type Dropdown (Pre-configured)
  static Widget expenseType({
    required String? value,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
    EdgeInsetsGeometry? margin,
  }) {
    const List<String> expenseTypes = ['GENERAL', 'LABOUR', 'RENT', 'PURCHASE', 'OTHER'];
    const Map<String, IconData> expenseIcons = {
      'GENERAL': Icons.category,
      'LABOUR': Icons.handyman,
      'RENT': Icons.home_work,
      'PURCHASE': Icons.shopping_cart,
      'OTHER': Icons.more_horiz,
    };

    return CustomDropdown<String>(
      value: value,
      options: expenseTypes,
      onChanged: onChanged,
      validator: validator,
      hintText: 'Expense Type',
      itemIcon: (String type) => expenseIcons[type] ?? Icons.category,
      margin: margin,
    );
  }
}
