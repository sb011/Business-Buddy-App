import 'package:business_buddy_app/api_calls/inventory_apis.dart';
import 'package:business_buddy_app/models/item/item.dart';
import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../utils/shared_preferences.dart';
import 'login_page.dart';
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
  int limit = 10;
  int skip = 0;

  @override
  void initState() {
    super.initState();
    _fetchInventoryItems();
  }

  Future<void> _fetchInventoryItems() async {
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
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final response = await InventoryAPI.getInventoryItems(
        token: token,
        limit: limit,
        skip: skip,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [],
      ),
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
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            items.clear();
            skip = 0;
          });
          await _fetchInventoryItems();
        },
        child: _isLoading && items.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No items found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    Text(
                      'Pull down to refresh',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == items.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            onTap: () async {
                              final updated = await Navigator.of(context).push<Item>(
                                MaterialPageRoute(
                                  builder: (context) => ItemDetailsPage(item: item),
                                ),
                              );
                              if (updated is Item) {
                                if (!mounted) return;
                                setState(() {
                                  final int idx = items.indexWhere((it) => it.id == updated.id);
                                  if (idx != -1) {
                                    items[idx] = updated;
                                  }
                                });
                              }
                            },
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                item.name[0].toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.description),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        item.category,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade800,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Qty: ${item.quantity}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
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
                                  '₹${item.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  'ID: ${item.id.substring(0, 8)}...',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
