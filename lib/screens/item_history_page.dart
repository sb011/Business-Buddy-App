import 'package:business_buddy_app/api_calls/inventory_apis.dart';
import 'package:business_buddy_app/models/item/item_response.dart';
import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../utils/shared_preferences.dart';

class ItemHistoryPage extends StatefulWidget {
  final String itemId;

  const ItemHistoryPage({super.key, required this.itemId});

  @override
  State<ItemHistoryPage> createState() => _ItemHistoryPageState();
}

class _ItemHistoryPageState extends State<ItemHistoryPage> {
  bool _isLoading = false;
  List<ItemHistoryResponse> _history = [];
  int limit = 20;
  int skip = 0;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
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
        Navigator.of(context).pop();
        return;
      }

      final items = await InventoryAPI.getItemHistory(
        token: token,
        itemId: widget.itemId,
        limit: limit,
        skip: skip,
      );
      if (!mounted) return;
      setState(() {
        _history.addAll(items);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item History'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading && _history.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? const Center(child: Text('No history found'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final h = _history[index];
                final int change = h.quantity; // delta from response
                final bool increased = change >= 0;
                final Color chipColor = increased ? Colors.green.shade100 : Colors.red.shade100;
                final Color chipText = increased ? Colors.green.shade700 : Colors.red.shade700;
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: chipColor,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${increased ? '+' : ''}${change}',
                                    style: TextStyle(
                                      color: chipText,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${h.oldQuantity} → ${h.newQuantity}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Text(
                              h.createdAt.toLocal().toString(),
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                h.changeType,
                                style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          runSpacing: 4,
                          spacing: 8,
                          children: [
                            Text('Old: ${h.oldQuantity}', style: const TextStyle(color: Colors.grey)),
                            Text('Change: ${increased ? '+' : ''}${change}', style: TextStyle(color: chipText)),
                            Text('New: ${h.newQuantity}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (h.reason != null && h.reason!.isNotEmpty)
                          Text('Reason: ${h.reason!}')
                        else
                          const SizedBox.shrink(),
                        const SizedBox(height: 4),
                        Text('By ${h.updatedBy}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: _history.length,
            ),
    );
  }
}
