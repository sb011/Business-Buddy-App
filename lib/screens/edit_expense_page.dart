import 'package:flutter/material.dart';

import '../api_calls/expense_apis.dart';
import '../constants/strings.dart';
import '../constants/permissions.dart';
import '../constants/colors.dart';
import '../models/expense/expense.dart';
import '../models/expense/expense_request.dart';
import '../utils/shared_preferences.dart';
import '../widgets/permission_wrapper.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown.dart';

class EditExpensePage extends StatefulWidget {
  final Expense expense;

  const EditExpensePage({super.key, required this.expense});

  @override
  State<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late String _type;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _descriptionController = TextEditingController(
      text: widget.expense.description,
    );
    _amountController = TextEditingController(
      text: widget.expense.amount.toStringAsFixed(2),
    );
    _type = widget.expense.type;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final String? token = await StorageService.getString(AppStrings.authToken);
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication token not found. Please login again.'),
        ),
      );
      return;
    }

    try {
      setState(() => _isSubmitting = true);
      final request = UpdateExpenseRequest(
        id: widget.expense.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _type.trim(),
        amount: double.parse(_amountController.text.trim()),
      );

      await ExpenseAPI.updateExpense(
        context: context,
        token: token,
        updateExpenseRequest: request,
      );

      final updated = Expense(
        id: widget.expense.id,
        title: request.title,
        description: request.description ?? '',
        type: request.type,
        amount: request.amount,
        inventoryId: widget.expense.inventoryId,
        archived: widget.expense.archived,
        createdBy: widget.expense.createdBy,
        createdAt: widget.expense.createdAt,
        updatedAt: DateTime.now(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update expense: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      permission: AppPermissions.updateExpense,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Edit Expense',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textDarkPrimary,
            ),
          ),
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textDarkPrimary,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textDarkPrimary),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Expense',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Update expense details',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),

                  // Form Fields
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _titleController,
                            hintText: 'Expense Title',
                            prefixIcon: Icons.title,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Title is required'
                                : null,
                          ),
                          const SizedBox(height: 20),

                          CustomTextField(
                            controller: _descriptionController,
                            hintText: 'Description (Optional)',
                            prefixIcon: Icons.description,
                            maxLines: 5,
                          ),
                          const SizedBox(height: 20),

                          // Expense Type Dropdown
                          CustomDropdowns.expenseType(
                            value: _type,
                            onChanged: (v) =>
                                setState(() => _type = v ?? _type),
                          ),
                          const SizedBox(height: 20),

                          CustomTextField(
                            controller: _amountController,
                            hintText: 'Amount (₹)',
                            prefixIcon: Icons.currency_rupee,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Amount is required';
                              }
                              final parsed = double.tryParse(v.trim());
                              if (parsed == null || parsed <= 0) {
                                return 'Enter a valid amount';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Submit Button
                  const SizedBox(height: 20),
                  CustomButtons.primary(
                    text: 'Save Changes',
                    onPressed: _isSubmitting ? null : _submit,
                    isLoading: _isSubmitting,
                    loadingText: 'Saving...',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
