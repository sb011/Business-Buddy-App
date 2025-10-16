import 'package:flutter/material.dart';

import '../api_calls/expense_apis.dart';
import '../constants/strings.dart';
import '../constants/permissions.dart';
import '../models/expense/expense.dart';
import '../models/expense/expense_request.dart';
import '../utils/shared_preferences.dart';
import '../widgets/permission_wrapper.dart';

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
    _descriptionController = TextEditingController(text: widget.expense.description);
    _amountController = TextEditingController(text: widget.expense.amount.toStringAsFixed(2));
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
        const SnackBar(content: Text('Authentication token not found. Please login again.')),
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

      await ExpenseAPI.updateExpense(token: token, updateExpenseRequest: request);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update expense: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      permission: AppPermissions.updateExpense,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Expense'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _type,
                  items: const [
                    DropdownMenuItem(value: 'GENERAL', child: Text('GENERAL')),
                    DropdownMenuItem(value: 'LABOUR', child: Text('LABOUR')),
                    DropdownMenuItem(value: 'RENT', child: Text('RENT')),
                    DropdownMenuItem(value: 'PURCHASE', child: Text('PURCHASE')),
                    DropdownMenuItem(value: 'OTHER', child: Text('OTHER')),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? _type),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount (₹)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Amount is required';
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}


