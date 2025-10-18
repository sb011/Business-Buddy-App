import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../api_calls/bill_apis.dart';
import '../constants/strings.dart';
import '../constants/permissions.dart';
import '../constants/colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dialog.dart';
import '../models/bill/bill_response.dart';
import '../utils/shared_preferences.dart';
import '../widgets/permission_wrapper.dart';
import 'create_bill_page.dart';
import 'bill_details_page.dart';

class BillPage extends StatefulWidget {
  const BillPage({super.key});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  List<BillResponse> bills = [];
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
    _fetchBills();
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
      if (!_isLoadingMore &&
          !_isLoading &&
          !_hasReachedEnd &&
          bills.isNotEmpty) {
        _loadMoreBills();
      }
    }
  }

  Future<void> _fetchBills({String? query}) async {
    try {
      final String? token = await StorageService.getString(
        AppStrings.authToken,
      );
      if (token == null) {
        if (!mounted) return;
        CustomDialogs.showError(
          context: context,
          title: 'Authentication Error',
          message: 'Authentication token not found. Please login again.',
        );
        return;
      }
      setState(() {
        _isLoading = true;
        _hasReachedEnd = false;
      });
      final response = await AuthAPI.getBills(
        context: context,
        token: token,
        limit: limit,
        skip: skip,
        searchQuery: query,
      );
      if (!mounted) return;
      setState(() {
        bills.addAll(response);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomDialogs.showError(
        context: context,
        title: 'Error Loading Bills',
        message: 'Error: $e',
      );
    }
  }

  Future<void> _loadMoreBills() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final String? token = await StorageService.getString(
        AppStrings.authToken,
      );
      if (token == null) {
        setState(() => _isLoadingMore = false);
        return;
      }

      skip += limit;
      final response = await AuthAPI.getBills(
        context: context,
        token: token,
        limit: limit,
        skip: skip,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        bills.addAll(response);
        _isLoadingMore = false;
        // If we got fewer items than requested, we've reached the end
        if (response.length < limit) {
          _hasReachedEnd = true;
        }
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      if (!mounted) return;
      CustomDialogs.showError(
        context: context,
        title: 'Error Loading More Bills',
        message: 'Error loading more bills: $e',
      );
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    // Cancel previous timer
    _searchTimer?.cancel();

    // Debounce search
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery == query) {
        setState(() {
          bills.clear();
          skip = 0;
        });
        _fetchBills(query: query);
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      bills.clear();
      skip = 0;
    });
    _fetchBills();
  }

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      permission: AppPermissions.getBill,
      child: Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final created = await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CreateBillPage()),
            );
            if (created is BillResponse) {
              if (!mounted) return;
              setState(() {
                bills = [created, ...bills];
              });
            }
          },
          backgroundColor: AppColors.textDarkPrimary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textSecondary.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bills',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDarkPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Search Bar
                    CustomTextField(
                      controller: _searchController,
                      hintText: 'Search bills by customer name or mobile...',
                      prefixIcon: Icons.search,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: _clearSearch,
                            )
                          : null,
                      onChanged: _onSearchChanged,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      bills.clear();
                      skip = 0;
                    });
                    await _fetchBills(
                      query: _searchQuery.isNotEmpty ? _searchQuery : null,
                    );
                  },
                  child: _isLoading && bills.isEmpty
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.textDarkPrimary,
                          ),
                        )
                      : bills.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 80,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No bills found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pull down to refresh',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(20.0),
                          itemCount: bills.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == bills.length) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(
                                    color: AppColors.textDarkPrimary,
                                  ),
                                ),
                              );
                            }

                            final bill = bills[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                elevation: 2,
                                shadowColor: AppColors.textSecondary.withValues(
                                  alpha: 0.1,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BillDetailsPage(bill: bill),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppColors.textDarkPrimary
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              bill.customer.name.isNotEmpty
                                                  ? bill.customer.name[0]
                                                        .toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color:
                                                    AppColors.textDarkPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                bill.customer.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  color:
                                                      AppColors.textDarkPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Items: ${bill.items.length}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                bill.customer.mobileNumber,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                timeago.format(bill.createdAt),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '₹${bill.totalAmount.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: AppColors.success,
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
      ),
    );
  }
}
