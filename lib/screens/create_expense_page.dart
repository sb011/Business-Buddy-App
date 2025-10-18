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

class CreateExpensePage extends StatefulWidget {
  const CreateExpensePage({super.key});

  @override
  State<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _type = 'GENERAL';
  bool _isSubmitting = false;

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
        const SnackBar(content: Text('Authentication token not found. Please login again.')),
      );
      return;
    }

    try {
      setState(() => _isSubmitting = true);
      final request = CreateExpenseRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _type.trim(),
        amount: double.parse(_amountController.text.trim()),
      );

      final Expense created = await ExpenseAPI.createExpense(
        context: context,
        token: token,
        createExpenseRequest: request,
      );

      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create expense: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      permission: AppPermissions.addExpense,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
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
                        'Add New Expense',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fill in the details to create a new expense',
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
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
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
                            onChanged: (v) => setState(() => _type = v ?? 'GENERAL'),
                          ),
                          const SizedBox(height: 20),
                          
                          CustomTextField(
                            controller: _amountController,
                            hintText: 'Amount (₹)',
                            prefixIcon: Icons.currency_rupee,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Amount is required';
                              final parsed = double.tryParse(v.trim());
                              if (parsed == null || parsed <= 0) return 'Enter a valid amount';
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
                    text: 'Create Expense',
                    onPressed: _isSubmitting ? null : _submit,
                    isLoading: _isSubmitting,
                    loadingText: 'Creating...',
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


