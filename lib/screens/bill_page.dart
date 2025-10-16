import 'dart:async';
import 'package:flutter/material.dart';
import '../api_calls/bill_apis.dart';
import '../constants/strings.dart';
import '../constants/permissions.dart';
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
      if (!_isLoadingMore && !_isLoading && !_hasReachedEnd && bills.isNotEmpty) {
        _loadMoreBills();
      }
    }
  }

  Future<void> _fetchBills({String? query}) async {
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
      final response = await AuthAPI.getBills(
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _loadMoreBills() async {
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
      final response = await AuthAPI.getBills(
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more bills: $e')),
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
        appBar: AppBar(
          title: const Text('Bills'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
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
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search bills by customer name or mobile...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  bills.clear();
                  skip = 0;
                });
                await _fetchBills(query: _searchQuery.isNotEmpty ? _searchQuery : null);
              },
              child: _isLoading && bills.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : bills.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 80,
                                color: Colors.green,
                              ),
                              SizedBox(height: 20),
                              Text(
                                'No bills found',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              Text(
                                'Pull down to refresh',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: bills.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == bills.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final bill = bills[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BillDetailsPage(bill: bill),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: Text(
                              bill.customer.name.isNotEmpty ? bill.customer.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                          title: Text(
                            bill.customer.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Items: ${bill.items.length}'),
                              const SizedBox(height: 4),
                              Text('Customer Mob: ${bill.customer.mobileNumber}'),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${bill.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                'ID: ${bill.id.substring(0, 8)}...',
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
    ),
    );
  }
}

