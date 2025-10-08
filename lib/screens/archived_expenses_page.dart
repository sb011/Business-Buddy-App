import 'dart:async';
import 'package:flutter/material.dart';

import '../api_calls/expense_apis.dart';
import '../constants/strings.dart';
import '../models/expense/expense.dart';
import '../utils/shared_preferences.dart';
import 'expense_details_page.dart';

class ArchivedExpensesPage extends StatefulWidget {
  const ArchivedExpensesPage({super.key});

  @override
  State<ArchivedExpensesPage> createState() => _ArchivedExpensesPageState();
}

class _ArchivedExpensesPageState extends State<ArchivedExpensesPage> {
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
    _fetchArchivedExpenses();
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
        _loadMoreArchivedExpenses();
      }
    }
  }

  Future<void> _fetchArchivedExpenses({String? query}) async {
    try {
      final String? token = await StorageService.getString(AppStrings.authToken);
      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please login again.')),
        );
        Navigator.of(context).pop();
        return;
      }

      setState(() {
        _isLoading = true;
        _hasReachedEnd = false;
      });
      final response = await ExpenseAPI.getExpenses(
        token: token, 
        limit: limit, 
        skip: skip, 
        archive: true,
        query: query,
      );
      if (!mounted) return;
      setState(() {
        expenses.addAll(response.where((e) => e.archived).toList());
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

  Future<void> _loadMoreArchivedExpenses() async {
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
        token: token,
        limit: limit,
        skip: skip,
        archive: true,
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        expenses.addAll(response.where((e) => e.archived).toList());
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
    _fetchArchivedExpenses(query: query.isNotEmpty ? query : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 16.0), // Added top padding for status bar
            decoration: BoxDecoration(
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Text(
                      'Archived Expenses',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search archived expenses...',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.blue),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
                await _fetchArchivedExpenses();
              },
              child: _isLoading && expenses.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : expenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isNotEmpty
                                ? Icons.search_off
                                : Icons.receipt_long_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No archived expenses found for "$_searchQuery"'
                                : 'No archived expenses',
                            style: const TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          if (_searchQuery.isEmpty)
                            const Text(
                              'Pull down to refresh',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: expenses.length + (_isLoadingMore && !_hasReachedEnd ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == expenses.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                      final expense = expenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ExpenseDetailsPage(expense: expense, isArchived: true),
                              ),
                            );
                            if (result is Map && result['unarchivedId'] is String) {
                              if (!mounted) return;
                              setState(() {
                                expenses.removeWhere((e) => e.id == result['unarchivedId']);
                              });
                            }
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: Text(
                              expense.title.isNotEmpty ? expense.title[0].toUpperCase() : '?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                          title: Text(
                            expense.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (expense.description.trim().isNotEmpty) Text(expense.description),
                              if (expense.description.trim().isNotEmpty) const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      expense.type,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                'ID: ${expense.id.substring(0, 8)}...',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}


