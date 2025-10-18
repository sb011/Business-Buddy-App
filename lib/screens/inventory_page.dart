import 'dart:async';
import 'package:business_buddy_app/api_calls/inventory_apis.dart';
import 'package:business_buddy_app/models/item/item.dart';
import 'package:business_buddy_app/screens/auth_page.dart';
import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../constants/permissions.dart';
import '../constants/colors.dart';
import '../utils/shared_preferences.dart';
import '../widgets/permission_wrapper.dart';
import 'create_item_page.dart';
import 'item_details_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Item> items = [];
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
    _fetchInventoryItems();
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
      if (!_isLoadingMore && !_isLoading && !_hasReachedEnd && items.isNotEmpty) {
        _loadMoreItems();
      }
    }
  }

  Future<void> _fetchInventoryItems({String? query}) async {
    try {
      final String? token = await StorageService.getString(
        AppStrings.authToken,
      );

      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Authentication token not found. Please login again.',
            ),
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthPage()),
          (Route<dynamic> route) => false,
        );
        return;
      }

      setState(() {
        _isLoading = true;
        _hasReachedEnd = false;
      });

      final response = await InventoryAPI.getInventoryItems(
        context: context,
        token: token,
        limit: limit,
        skip: skip,
        archive: false,
        query: query,
      );

      setState(() {
        items.addAll(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _loadMoreItems() async {
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
      final response = await InventoryAPI.getInventoryItems(
        context: context,
        token: token,
        limit: limit,
        skip: skip,
        archive: false,
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        items.addAll(response);
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
        SnackBar(content: Text('Error loading more items: $e')),
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
      items.clear();
      skip = 0;
      _hasReachedEnd = false;
    });
    _fetchInventoryItems(query: query.isNotEmpty ? query : '');
  }

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      permission: AppPermissions.getInventoryItem,
      child: Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final createdItem = await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CreateItemPage()),
            );
            if (createdItem is Item) {
              if (!mounted) return;
              setState(() {
                items = [createdItem, ...items];
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
                  'Inventory',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
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
          // Items List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  items.clear();
                  skip = 0;
                  _searchQuery = '';
                  _searchController.clear();
                  _hasReachedEnd = false;
                });
                await _fetchInventoryItems();
              },
              child: _isLoading && items.isEmpty
                  ? Center(child: CircularProgressIndicator(color: AppColors.textDarkPrimary))
                  : items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isNotEmpty
                                ? Icons.search_off
                                : Icons.inventory_2_outlined,
                            size: 80,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No items found for "$_searchQuery"'
                                : 'No items found',
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
                      itemCount: items.length + (_isLoadingMore && !_hasReachedEnd ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == items.length) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(color: AppColors.textDarkPrimary),
                            ),
                          );
                        }

                        final item = items[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Material(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            elevation: 2,
                            shadowColor: AppColors.textSecondary.withValues(alpha: 0.1),
                            child: InkWell(
                              onTap: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ItemDetailsPage(item: item),
                                  ),
                                );
                                if (result is Item) {
                                  if (!mounted) return;
                                  setState(() {
                                    final int idx = items.indexWhere((it) => it.id == result.id);
                                    if (idx != -1) {
                                      items[idx] = result;
                                    }
                                  });
                                } else if (result is Map && result['archivedId'] is String) {
                                  if (!mounted) return;
                                  setState(() {
                                    items.removeWhere((it) => it.id == result['archivedId']);
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
                                        color: AppColors.textDarkPrimary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.inventory_2_outlined,
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
                                            item.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textDarkPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppColors.textDarkPrimary.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  item.category,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textDarkPrimary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Variants: ${item.itemVariants.length}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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
