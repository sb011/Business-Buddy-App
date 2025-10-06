import 'package:business_buddy_app/models/item/item.dart';
import 'package:business_buddy_app/api_calls/inventory_apis.dart';
import 'package:business_buddy_app/models/item/item_request.dart';
import 'package:business_buddy_app/utils/shared_preferences.dart';
import 'package:business_buddy_app/constants/strings.dart';
import 'package:flutter/material.dart';

import 'edit_item_page.dart';
import 'add_stock_page.dart';
import 'item_history_page.dart';

class ItemDetailsPage extends StatefulWidget {
  final Item item;
  final bool isArchived;

  const ItemDetailsPage({super.key, required this.item, this.isArchived = false});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  late Item _currentItem;
  bool _isArchiving = false;
  bool _isUnarchiving = false;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
  }

  Future<void> _editItem() async {
    final updated = await Navigator.of(context).push<Item>(
      MaterialPageRoute(
        builder: (context) => EditItemPage(item: _currentItem),
      ),
    );
    if (updated is Item) {
      setState(() {
        _currentItem = updated;
      });
    }
  }

  Future<void> _archiveItem() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Archive Item?'),
          content: const Text(
              'Are you sure you want to archive this item? This will set the stock to 0 for the item.'),
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
      setState(() {
        _isArchiving = true;
      });

      final String? token = await StorageService.getString(AppStrings.authToken);
      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please login again.')),
        );
        return;
      }

      final request = ItemArchiveRequest(itemId: _currentItem.id, isArchive: true).toJson();
      await InventoryAPI.archiveItem(token: token, itemArchiveRequest: request);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item archived successfully')),
      );

      // Return to inventory page with instruction to remove this item locally
      Navigator.of(context).pop({
        'archivedId': _currentItem.id,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to archive item: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isArchiving = false;
        });
      }
    }
  }

  Future<void> _unarchiveItem() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unarchive Item?'),
          content: const Text('Are you sure you want to unarchive this item?'),
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
      setState(() {
        _isUnarchiving = true;
      });

      final String? token = await StorageService.getString(AppStrings.authToken);
      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please login again.')),
        );
        return;
      }

      final request = ItemArchiveRequest(itemId: _currentItem.id, isArchive: false).toJson();
      await InventoryAPI.archiveItem(token: token, itemArchiveRequest: request);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item unarchived successfully')),
      );

      Navigator.of(context).pop({
        'unarchivedId': _currentItem.id,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unarchive item: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUnarchiving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(_currentItem),
        ),
        title: const Text('Item Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                await _editItem();
              } else if (value == 'history') {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ItemHistoryPage(itemId: _currentItem.id),
                  ),
                );
              } else if (value == 'archive' && !widget.isArchived) {
                if (_isArchiving) return;
                await _archiveItem();
              } else if (value == 'unarchive' && widget.isArchived) {
                if (_isUnarchiving) return;
                await _unarchiveItem();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem<String>(
                value: 'history',
                child: Text('History'),
              ),
              if (!widget.isArchived)
                const PopupMenuItem<String>(
                  value: 'archive',
                  child: Text('Archive'),
                )
              else
                const PopupMenuItem<String>(
                  value: 'unarchive',
                  child: Text('Unarchive'),
                ),
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
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    _currentItem.name.isNotEmpty ? _currentItem.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
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
                        _currentItem.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${_currentItem.id}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '₹${_currentItem.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Description',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(_currentItem.description),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _currentItem.category,
                    style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Qty: ${_currentItem.quantity}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            if (!widget.isArchived) ...[
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.of(context).push<Item>(
                      MaterialPageRoute(
                        builder: (context) => AddStockPage(item: _currentItem),
                      ),
                    );
                    if (updated is Item) {
                      if (!mounted) return;
                      setState(() {
                        _currentItem = updated;
                      });
                    }
                  },
                  icon: const Icon(Icons.add_chart),
                  label: const Text('Add Stock'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


