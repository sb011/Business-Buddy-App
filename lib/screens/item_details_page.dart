import 'package:business_buddy_app/models/item/item.dart';
import 'package:business_buddy_app/api_calls/inventory_apis.dart';
import 'package:business_buddy_app/models/item/item_request.dart';
import 'package:business_buddy_app/utils/shared_preferences.dart';
import 'package:business_buddy_app/constants/strings.dart';
import 'package:flutter/material.dart';

import 'edit_item_page.dart';
import 'add_stock_page.dart';
import 'item_history_page.dart';
import 'update_variant_page.dart';
import 'add_variant_page.dart';

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

      final request = ItemArchiveRequest(itemId: _currentItem.id, isArchive: true);
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

      final request = ItemArchiveRequest(itemId: _currentItem.id, isArchive: false);
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

  Future<void> _archiveVariant(ItemVariant variant) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Archive Variant?'),
          content: const Text(
              'Are you sure you want to archive this variant? This will set the stock to 0 for the variant.'),
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
      final String? token = await StorageService.getString(AppStrings.authToken);
      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please login again.')),
        );
        return;
      }

      final request = ItemVariantArchiveRequest(
        itemId: _currentItem.id,
        itemVariantId: variant.id,
        isArchive: true,
      );
      await InventoryAPI.archiveItemVariant(token: token, itemVariantArchiveRequest: request);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Variant archived successfully')),
      );

      // Update local state immediately without additional API calls
      setState(() {
        // Remove the archived variant from the list completely
        final updatedVariants = _currentItem.itemVariants.where((v) => v.id != variant.id).toList();
        
        _currentItem = Item(
          id: _currentItem.id,
          name: _currentItem.name,
          description: _currentItem.description,
          category: _currentItem.category,
          inventoryId: _currentItem.inventoryId,
          itemVariants: updatedVariants,
          archived: _currentItem.archived,
          createdBy: _currentItem.createdBy,
          createdAt: _currentItem.createdAt,
          updatedAt: _currentItem.updatedAt,
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to archive variant: $e')),
      );
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
                    builder: (context) => ItemHistoryPage(item: _currentItem),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Header
            Row(
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
              ],
            ),
            const SizedBox(height: 20),
            
            // Item Details Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item Details',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Description
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Description: ', style: TextStyle(fontWeight: FontWeight.w500)),
                        Expanded(child: Text(_currentItem.description)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Category and Variants Count
                    Row(
                      children: [
                        const Text('Category: ', style: TextStyle(fontWeight: FontWeight.w500)),
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
                        const SizedBox(width: 16),
                        const Text('Variants: ', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('${_currentItem.itemVariants.where((v) => !v.archived).length}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Variants section
            Text(
              'Item Variants',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            
            if (_currentItem.itemVariants.where((v) => !v.archived).isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No variants available', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ..._currentItem.itemVariants.where((v) => !v.archived).map((variant) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Icon(
                        Icons.inventory,
                        color: Colors.green.shade700,
                      ),
                    ),
                    title: Text(variant.name),
                    subtitle: Text('₹${variant.price.toStringAsFixed(2)} • Stock: ${variant.quantity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!widget.isArchived) ...[
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () async {
                              final updated = await Navigator.of(context).push<Item>(
                                MaterialPageRoute(
                                  builder: (context) => UpdateVariantPage(
                                    item: _currentItem,
                                    variant: variant,
                                  ),
                                ),
                              );
                              if (updated is Item) {
                                if (!mounted) return;
                                setState(() {
                                  _currentItem = updated;
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.archive, color: Colors.red),
                            onPressed: () => _archiveVariant(variant),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
              
              // Add Variant Button
              if (!widget.isArchived) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final updated = await Navigator.of(context).push<Item>(
                        MaterialPageRoute(
                          builder: (context) => AddVariantPage(item: _currentItem),
                        ),
                      );
                      if (updated is Item) {
                        if (!mounted) return;
                        setState(() {
                          _currentItem = updated;
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Variant'),
                  ),
                ),
              ],
              
              // Add Stock Button
              if (!widget.isArchived) ...[
                const SizedBox(height: 20),
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


