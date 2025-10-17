import 'package:business_buddy_app/api_calls/inventory_apis.dart';
import 'package:business_buddy_app/models/item/item_response.dart';
import 'package:business_buddy_app/models/item/item.dart';
import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../constants/permissions.dart';
import '../utils/shared_preferences.dart';
import '../widgets/permission_wrapper.dart';

class ItemHistoryPage extends StatefulWidget {
  final Item item;

  const ItemHistoryPage({super.key, required this.item});

  @override
  State<ItemHistoryPage> createState() => _ItemHistoryPageState();
}

class _ItemHistoryPageState extends State<ItemHistoryPage> {
  bool _isLoading = false;
  List<ItemHistoryResponse> _history = [];
  ItemVariant? _selectedVariant;
  int limit = 20;
  int skip = 0;

  @override
  void initState() {
    super.initState();
    // Auto-select the first variant if there's only one
    if (widget.item.itemVariants.length == 1) {
      _selectedVariant = widget.item.itemVariants.first;
      _fetchHistory();
    }
  }

  Future<void> _fetchHistory() async {
    if (_selectedVariant == null) return;
    
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

      final items = await InventoryAPI.getItemVariantHistory(
        context: context,
        token: token,
        itemVariantId: _selectedVariant!.id,
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

  void _onVariantChanged(ItemVariant? newVariant) {
    setState(() {
      _selectedVariant = newVariant;
      _history.clear(); // Clear previous history
      skip = 0; // Reset pagination
    });
    if (newVariant != null) {
      _fetchHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      permission: AppPermissions.getItemVariantHistory,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.item.name} - History'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Column(
        children: [
          // Variant selection
          if (widget.item.itemVariants.length > 1) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Variant:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ItemVariant>(
                    value: _selectedVariant,
                    decoration: const InputDecoration(labelText: 'Variant'),
                    items: widget.item.itemVariants.map((variant) {
                      return DropdownMenuItem<ItemVariant>(
                        value: variant,
                        child: Text('${variant.name} - ₹${variant.price.toStringAsFixed(2)} (Stock: ${variant.quantity})'),
                      );
                    }).toList(),
                    onChanged: _onVariantChanged,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
          
          // History content
          Expanded(
            child: _selectedVariant == null
                ? const Center(child: Text('Please select a variant to view history'))
                : _isLoading && _history.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _history.isEmpty
                        ? const Center(child: Text('No history found for this variant'))
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
          ),
        ],
      ),
    ),
    );
  }
}
