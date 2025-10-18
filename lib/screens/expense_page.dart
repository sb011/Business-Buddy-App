import 'dart:async';
import 'package:flutter/material.dart';

import '../api_calls/expense_apis.dart';
import '../constants/strings.dart';
import '../constants/permissions.dart';
import '../constants/colors.dart';
import '../constants/style.dart';
import '../models/expense/expense.dart';
import '../utils/shared_preferences.dart';
import '../widgets/permission_wrapper.dart';
import 'create_expense_page.dart';
import 'expense_details_page.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  List<Expense> expenses = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasReachedEnd = false;
  int limit = 10;
  int skip = 0;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    // Only trigger if we're near the bottom and not already loading
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && !_isLoading && !_hasReachedEnd && expenses.isNotEmpty) {
        _loadMoreExpenses();
      }
    }
  }

  Future<void> _fetchExpenses({String? query}) async {
    try {
      final String? token = await StorageService.getString(AppStrings.authToken);
      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please login again.')),
        );
        return;
      }
      setState(() {
        _isLoading = true;
        _hasReachedEnd = false;
      });
      final response = await ExpenseAPI.getExpenses(
        context: context,
        token: token, 
        limit: limit, 
        skip: skip, 
        archive: false,
        query: query,
      );
      if (!mounted) return;
      setState(() {
        expenses.addAll(response);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _loadMoreExpenses() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final String? token = await StorageService.getString(AppStrings.authToken);
      if (token == null) {
        setState(() => _isLoadingMore = false);
        return;
      }

      skip += limit;
      final response = await ExpenseAPI.getExpenses(
        context: context,
        token: token,
        limit: limit,
        skip: skip,
        archive: false,
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        expenses.addAll(response);
        _isLoadingMore = false;
        // If we got fewer items than requested, we've reached the end
        if (response.length < limit) {
          _hasReachedEnd = true;
        }
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more expenses: $e')),
      );
    }
  }

  void _onSearchChanged(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      expenses.clear();
      skip = 0;
      _hasReachedEnd = false;
    });
    _fetchExpenses(query: query.isNotEmpty ? query : null);
  }

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      permission: AppPermissions.getExpense,
      child: Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final created = await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CreateExpensePage()),
            );
            if (created is Expense) {
              if (!mounted) return;
              setState(() {
                expenses = [created, ...expenses];
              });
            }
          },
          backgroundColor: AppColors.textDarkPrimary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Column(
        children: [
          // Header with Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 20.0),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expenses',
                  style: TextStyle(
                    fontSize: Style.fontSize3,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search expenses...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon: Icon(Icons.search, color: AppColors.textDarkPrimary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppColors.textDarkPrimary),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.textDarkPrimary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Expenses List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  expenses.clear();
                  skip = 0;
                  _searchQuery = '';
                  _searchController.clear();
                  _hasReachedEnd = false;
                });
                await _fetchExpenses();
              },
              child: _isLoading && expenses.isEmpty
                  ? Center(child: CircularProgressIndicator(color: AppColors.textDarkPrimary))
                  : expenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isNotEmpty
                                ? Icons.search_off
                                : Icons.monetization_on_outlined,
                            size: 80,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No expenses found for "$_searchQuery"'
                                : 'No expenses found',
                            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                          ),
                          if (_searchQuery.isEmpty)
                            Text(
                              'Pull down to refresh',
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: expenses.length + (_isLoadingMore && !_hasReachedEnd ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == expenses.length) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(color: AppColors.textDarkPrimary),
                            ),
                          );
                        }

                      final expense = expenses[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Material(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 2,
                          shadowColor: AppColors.textSecondary.withOpacity(0.1),
                          child: InkWell(
                            onTap: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ExpenseDetailsPage(expense: expense),
                                ),
                              );
                              if (result is Expense) {
                                if (!mounted) return;
                                setState(() {
                                  final int idx = expenses.indexWhere((e) => e.id == result.id);
                                  if (idx != -1) expenses[idx] = result;
                                });
                              } else if (result is Map && result['archivedId'] is String) {
                                if (!mounted) return;
                                setState(() {
                                  expenses.removeWhere((e) => e.id == result['archivedId']);
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Leading Icon
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.textDarkPrimary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.monetization_on_outlined,
                                      color: AppColors.textDarkPrimary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expense.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textDarkPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.textDarkPrimary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            expense.type,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textDarkPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Amount
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹${expense.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.textDarkPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

