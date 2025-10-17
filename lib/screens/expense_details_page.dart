import 'package:flutter/material.dart';

import '../api_calls/expense_apis.dart';
import '../constants/strings.dart';
import '../constants/permissions.dart';
import '../models/expense/expense.dart';
import '../models/expense/expense_request.dart';
import '../utils/shared_preferences.dart';
import '../widgets/permission_wrapper.dart';
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
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Archive Expense?'),
          content: const Text('Are you sure you want to archive this expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense archived successfully')),
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
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unarchive Expense?'),
          content: const Text('Are you sure you want to unarchive this expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense unarchived successfully')),
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
        appBar: AppBar(
          leading: BackButton(onPressed: () => Navigator.of(context).pop(_current)),
          title: const Text('Expense Details'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
          PopupMenuButton<String>(
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
              const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
              if (!widget.isArchived)
                const PopupMenuItem<String>(value: 'archive', child: Text('Archive'))
              else
                const PopupMenuItem<String>(value: 'unarchive', child: Text('Unarchive')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.orange.shade100,
                  child: Text(
                    _current.title.isNotEmpty ? _current.title[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _current.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('ID: ${_current.id}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '₹${_current.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Type',
              style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_current.type, style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.w600)),
            ),
            if ((_current.description).trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(_current.description),
            ],
          ],
        ),
      ),
    ),
    );
  }
}


