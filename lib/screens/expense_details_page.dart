import 'package:flutter/material.dart';

import '../api_calls/expense_apis.dart';
import '../constants/strings.dart';
import '../constants/permissions.dart';
import '../constants/colors.dart';
import '../models/expense/expense.dart';
import '../models/expense/expense_request.dart';
import '../utils/shared_preferences.dart';
import '../widgets/permission_wrapper.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dialog.dart';
import 'edit_expense_page.dart';

class ExpenseDetailsPage extends StatefulWidget {
  final Expense expense;
  final bool isArchived;

  const ExpenseDetailsPage({super.key, required this.expense, this.isArchived = false});

  @override
  State<ExpenseDetailsPage> createState() => _ExpenseDetailsPageState();
}

class _ExpenseDetailsPageState extends State<ExpenseDetailsPage> {
  late Expense _current;
  bool _isArchiving = false;
  bool _isUnarchiving = false;

  @override
  void initState() {
    super.initState();
    _current = widget.expense;
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(context).push<Expense>(
      MaterialPageRoute(builder: (context) => EditExpensePage(expense: _current)),
    );
    if (updated is Expense) {
      setState(() => _current = updated);
    }
  }

  Future<void> _archive() async {
    final bool? confirm = await CustomDialogs.showArchiveConfirmation(
      context: context,
      itemName: _current.title,
      itemType: 'Expense',
    );

    if (confirm != true) return;

    try {
      setState(() => _isArchiving = true);
      final String? token = await StorageService.getString(AppStrings.authToken);
      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please login again.')),
        );
        return;
      }

      final req = ExpenseArchiveRequest(expenseId: _current.id, isArchive: true);
      await ExpenseAPI.archivedExpense(context: context, token: token, archiveExpenseRequest: req);

      if (!mounted) return;
      await CustomDialogs.showSuccess(
        context: context,
        title: 'Success',
        message: 'Expense archived successfully',
      );
      Navigator.of(context).pop({'archivedId': _current.id});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to archive expense: $e')),
      );
    } finally {
      if (mounted) setState(() => _isArchiving = false);
    }
  }

  Future<void> _unarchive() async {
    final bool? confirm = await CustomDialogs.showConfirmation(
      context: context,
      title: 'Unarchive Expense?',
      message: 'Are you sure you want to unarchive "${_current.title}"?',
      confirmText: 'Unarchive',
      cancelText: 'Cancel',
      icon: Icons.unarchive,
      iconColor: AppColors.success,
    );

    if (confirm != true) return;

    try {
      setState(() => _isUnarchiving = true);
      final String? token = await StorageService.getString(AppStrings.authToken);
      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please login again.')),
        );
        return;
      }

      final req = ExpenseArchiveRequest(expenseId: _current.id, isArchive: false);
      await ExpenseAPI.archivedExpense(context: context, token: token, archiveExpenseRequest: req);

      if (!mounted) return;
      await CustomDialogs.showSuccess(
        context: context,
        title: 'Success',
        message: 'Expense unarchived successfully',
      );
      Navigator.of(context).pop({'unarchivedId': _current.id});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unarchive expense: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUnarchiving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      permission: AppPermissions.getExpense,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => Navigator.of(context).pop(_current),
            color: AppColors.textDarkPrimary,
          ),
          title: const Text(
            'Expense Details',
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
          actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textDarkPrimary),
            color: AppColors.background,
            onSelected: (value) async {
              if (value == 'edit') {
                await _edit();
              } else if (value == 'archive' && !widget.isArchived) {
                if (_isArchiving) return;
                await _archive();
              } else if (value == 'unarchive' && widget.isArchived) {
                if (_isUnarchiving) return;
                await _unarchive();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.textDarkPrimary, size: 20),
                    const SizedBox(width: 12),
                    Text('Edit', style: TextStyle(color: AppColors.textDarkPrimary)),
                  ],
                ),
              ),
              if (!widget.isArchived)
                PopupMenuItem<String>(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(Icons.archive, color: AppColors.textDarkPrimary, size: 20),
                      const SizedBox(width: 12),
                      Text('Archive', style: TextStyle(color: AppColors.textDarkPrimary)),
                    ],
                  ),
                )
              else
                PopupMenuItem<String>(
                  value: 'unarchive',
                  child: Row(
                    children: [
                      Icon(Icons.unarchive, color: AppColors.textDarkPrimary, size: 20),
                      const SizedBox(width: 12),
                      Text('Unarchive', style: TextStyle(color: AppColors.textDarkPrimary)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expense Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Section
                      Row(
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.textDarkPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.monetization_on_outlined,
                              color: AppColors.textDarkPrimary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Title and ID
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _current.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDarkPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID: ${_current.id}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Amount
                      Text(
                        '₹${_current.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: AppColors.textDarkPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Type Section
                      Text(
                        'Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.textDarkPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _current.type,
                          style: const TextStyle(
                            color: AppColors.textDarkPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      
                      // Description Section
                      if ((_current.description).trim().isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _current.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textDarkPrimary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}


