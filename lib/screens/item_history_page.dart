import 'package:business_buddy_app/api_calls/inventory_apis.dart';
import 'package:business_buddy_app/models/item/item_response.dart';
import 'package:business_buddy_app/models/item/item.dart';
import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../constants/permissions.dart';
import '../constants/colors.dart';
import '../widgets/custom_dropdown.dart';
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            '${widget.item.name} - History',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDarkPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDarkPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDarkPrimary),
      ),
      body: Column(
          children: [
            // Variant selection
            if (widget.item.itemVariants.length > 1) ...[
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Variant',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDarkPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomDropdowns.custom<ItemVariant>(
                      value: _selectedVariant,
                      options: widget.item.itemVariants,
                      displayText: (variant) => '${variant.name} - ₹${variant.price.toStringAsFixed(2)} (Stock: ${variant.quantity})',
                      itemIcon: (variant) => Icons.inventory,
                      onChanged: _onVariantChanged,
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                color: AppColors.textSecondary.withValues(alpha: 0.2),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ],
            
            // History content
            Expanded(
              child: _selectedVariant == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Please select a variant to view history',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _isLoading && _history.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: AppColors.textDarkPrimary),
                              const SizedBox(height: 16),
                              Text(
                                'Loading history...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _history.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 64,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No history found for this variant',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(20),
                              itemBuilder: (context, index) {
                                final h = _history[index];
                                final int change = h.quantity; // delta from response
                                final bool increased = change >= 0;
                                final Color chipColor = increased ? AppColors.success.withValues(alpha: 0.1) : AppColors.danger.withValues(alpha: 0.1);
                                final Color chipText = increased ? AppColors.success : AppColors.danger;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.textSecondary.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: chipColor,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Text(
                                                    '${increased ? '+' : ''}$change',
                                                    style: TextStyle(
                                                      color: chipText,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  '${h.oldQuantity} → ${h.newQuantity}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textDarkPrimary,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              h.createdAt.toLocal().toString().split('.')[0],
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.textDarkPrimary.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                h.changeType,
                                                style: const TextStyle(
                                                  color: AppColors.textDarkPrimary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          runSpacing: 6,
                                          spacing: 12,
                                          children: [
                                            Text(
                                              'Old: ${h.oldQuantity}',
                                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                            ),
                                            Text(
                                              'Change: ${increased ? '+' : ''}$change',
                                              style: TextStyle(color: chipText, fontSize: 14),
                                            ),
                                            Text(
                                              'New: ${h.newQuantity}',
                                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (h.reason != null && h.reason!.isNotEmpty)
                                          Text(
                                            'Reason: ${h.reason!}',
                                            style: const TextStyle(
                                              color: AppColors.textDarkPrimary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'By ${h.updatedBy}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemCount: _history.length,
                            ),
            ),
          ],
        ),
    ),
    );
  }
}
