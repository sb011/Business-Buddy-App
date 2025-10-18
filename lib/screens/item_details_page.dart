import 'package:business_buddy_app/models/item/item.dart';
import 'package:business_buddy_app/api_calls/inventory_apis.dart';
import 'package:business_buddy_app/models/item/item_request.dart';
import 'package:business_buddy_app/utils/shared_preferences.dart';
import 'package:business_buddy_app/constants/strings.dart';
import 'package:business_buddy_app/constants/permissions.dart';
import 'package:business_buddy_app/widgets/permission_wrapper.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dialog.dart';
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
    final bool? confirm = await CustomDialogs.showArchiveConfirmation(
      context: context,
      itemName: _currentItem.name,
      itemType: 'Item',
      extraMessage: "This action will result in all item variants having 0 stock."
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
      if (!mounted) return;
      await InventoryAPI.archiveItem(context: context, token: token, itemArchiveRequest: request);

      if (!mounted) return;
      CustomDialogs.showSuccess(
        context: context,
        title: 'Success',
        message: 'Item archived successfully',
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
    final bool? confirm = await CustomDialogs.showConfirmation(
      context: context,
      title: 'Unarchive Item?',
      message: 'Are you sure you want to unarchive this item?',
      confirmText: 'Confirm',
      cancelText: 'Cancel',
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
      if (!mounted) return;
      await InventoryAPI.archiveItem(context: context, token: token, itemArchiveRequest: request);

      if (!mounted) return;
      CustomDialogs.showSuccess(
        context: context,
        title: 'Success',
        message: 'Item unarchived successfully',
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
    final bool? confirm = await CustomDialogs.showArchiveConfirmation(
      context: context,
      itemName: variant.name,
      itemType: 'Variant',
      extraMessage: "This action will result in the item variant having 0 stock."
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
      if (!mounted) return;
      await InventoryAPI.archiveItemVariant(context: context, token: token, itemVariantArchiveRequest: request);

      if (!mounted) return;
      CustomDialogs.showSuccess(
        context: context,
        title: 'Success',
        message: 'Variant archived successfully',
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
    return PermissionWrapper(
      permission: AppPermissions.getInventoryItem,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: BackButton(
            color: AppColors.textDarkPrimary,
            onPressed: () => Navigator.of(context).pop(_currentItem),
          ),
          title: const Text(
            'Item Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textDarkPrimary,
            ),
          ),
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textDarkPrimary,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textDarkPrimary),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppColors.textDarkPrimary),
              color: AppColors.background,
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
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: AppColors.textDarkPrimary),
                      const SizedBox(width: 8),
                      Text('Edit', style: TextStyle(color: AppColors.textDarkPrimary)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'history',
                  child: Row(
                    children: [
                      Icon(Icons.history, color: AppColors.textDarkPrimary),
                      const SizedBox(width: 8),
                      Text('History', style: TextStyle(color: AppColors.textDarkPrimary)),
                    ],
                  ),
                ),
                if (!widget.isArchived)
                  PopupMenuItem<String>(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(Icons.archive, color: AppColors.textDarkPrimary),
                        const SizedBox(width: 8),
                        Text('Archive', style: TextStyle(color: AppColors.textDarkPrimary)),
                      ],
                    ),
                  )
                else
                  PopupMenuItem<String>(
                    value: 'unarchive',
                    child: Row(
                      children: [
                        Icon(Icons.unarchive, color: AppColors.textDarkPrimary),
                        const SizedBox(width: 8),
                        Text('Unarchive', style: TextStyle(color: AppColors.textDarkPrimary)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Header
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.textDarkPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.textDarkPrimary,
                              size: 28,
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
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDarkPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID: ${_currentItem.id}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Item Details Section
                      Text(
                        'Description',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDarkPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentItem.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textDarkPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Category
                      Text(
                        'Category',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDarkPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.textDarkPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _currentItem.category,
                          style: const TextStyle(
                            color: AppColors.textDarkPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Variants section
                      Text(
                        'Item Variants',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDarkPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      if (_currentItem.itemVariants.where((v) => !v.archived).isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.textSecondary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                color: AppColors.textSecondary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'No variants available',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._currentItem.itemVariants.where((v) => !v.archived).map((variant) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              elevation: 2,
                              shadowColor: AppColors.textSecondary.withValues(alpha: 0.1),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.textDarkPrimary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.inventory,
                                    color: AppColors.textDarkPrimary,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  variant.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDarkPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  '₹${variant.price.toStringAsFixed(2)} • Stock: ${variant.quantity}',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!widget.isArchived) ...[
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: AppColors.textDarkPrimary),
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
                                        icon: const Icon(Icons.archive, color: AppColors.danger),
                                        onPressed: () => _archiveVariant(variant),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              
              // Fixed bottom buttons
              if (!widget.isArchived) ...[
                Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textSecondary.withValues(alpha: 0.1),
                        offset: const Offset(0, -3),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButtons.secondary(
                            text: 'Add Variant',
                            icon: const Icon(Icons.add),
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
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButtons.primary(
                            text: 'Add Stock',
                            icon: const Icon(Icons.add_chart),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
    ),
    );
  }
}


