import 'package:business_buddy_app/api_calls/inventory_apis.dart';
import 'package:business_buddy_app/constants/constants.dart';
import 'package:business_buddy_app/models/item/item.dart';
import 'package:business_buddy_app/models/item/item_request.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown.dart';
import '../utils/shared_preferences.dart';
import '../widgets/permission_wrapper.dart';

class AddStockPage extends StatefulWidget {
  final Item item;

  const AddStockPage({super.key, required this.item});

  @override
  State<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  ItemVariant? _selectedVariant;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    
    // Auto-select the first variant if there's only one
    if (widget.item.itemVariants.length == 1) {
      _selectedVariant = widget.item.itemVariants.first;
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedVariant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a variant')),
      );
      return;
    }

    final String? token = await StorageService.getString(AppStrings.authToken);
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token not found. Please login again.')),
      );
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final String reason = _reasonController.text.trim();
      final UpdateStockRequest request = UpdateStockRequest(
        itemVariantId: _selectedVariant!.id,
        quantity: int.parse(_qtyController.text.trim()),
        reason: reason.isEmpty ? null : reason,
      );
      
      await InventoryAPI.updateItemVariantStock(
        context: context,
        token: token,
        updateStockRequest: request,
      );

      // Update the variant quantity in the item
      final updatedVariants = widget.item.itemVariants.map((variant) {
        if (variant.id == _selectedVariant!.id) {
          return ItemVariant(
            id: variant.id,
            itemId: variant.itemId,
            name: variant.name,
            price: variant.price,
            quantity: variant.quantity + int.parse(_qtyController.text.trim()),
            archived: variant.archived,
            createdBy: variant.createdBy,
            createdAt: variant.createdAt,
            updatedAt: DateTime.now(),
          );
        }
        return variant;
      }).toList();

      final Item updated = Item(
        id: widget.item.id,
        name: widget.item.name,
        description: widget.item.description,
        category: widget.item.category,
        inventoryId: widget.item.inventoryId,
        itemVariants: updatedVariants,
        archived: widget.item.archived,
        createdBy: widget.item.createdBy,
        createdAt: widget.item.createdAt,
        updatedAt: DateTime.now(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      permission: AppPermissions.updateStock,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Add Stock',
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
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Stock',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Update stock for "${widget.item.name}"',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                  
                  // Item Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textSecondary.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Item Information',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDarkPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.inventory_2_outlined, color: AppColors.textDarkPrimary, size: 20),
                            const SizedBox(width: 8),
                            Text('Item: ${widget.item.name}', style: TextStyle(color: AppColors.textDarkPrimary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.tag, color: AppColors.textDarkPrimary, size: 20),
                            const SizedBox(width: 8),
                            Text('ID: ${widget.item.id}', style: TextStyle(color: AppColors.textDarkPrimary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.inventory, color: AppColors.textDarkPrimary, size: 20),
                            const SizedBox(width: 8),
                            Text('Total Variants: ${widget.item.itemVariants.length}', style: TextStyle(color: AppColors.textDarkPrimary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Form Fields
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Variant selection
                          if (widget.item.itemVariants.length > 1) ...[
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
                              onChanged: (ItemVariant? newValue) {
                                setState(() {
                                  _selectedVariant = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) return 'Please select a variant';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                          
                          // Current stock info
                          if (_selectedVariant != null) ...[
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.textDarkPrimary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.textDarkPrimary.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selected Variant',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDarkPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.label, color: AppColors.textDarkPrimary, size: 20),
                                      const SizedBox(width: 8),
                                      Text('Name: ${_selectedVariant!.name}', style: TextStyle(color: AppColors.textDarkPrimary)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.inventory, color: AppColors.textDarkPrimary, size: 20),
                                      const SizedBox(width: 8),
                                      Text('Current Stock: ${_selectedVariant!.quantity}', style: TextStyle(color: AppColors.textDarkPrimary)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.currency_rupee, color: AppColors.textDarkPrimary, size: 20),
                                      const SizedBox(width: 8),
                                      Text('Price: ₹${_selectedVariant!.price.toStringAsFixed(2)}', style: TextStyle(color: AppColors.textDarkPrimary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          
                          CustomTextField(
                            controller: _qtyController,
                            hintText: 'Add Quantity',
                            prefixIcon: Icons.add_box,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Enter quantity';
                              final parsed = int.tryParse(value.trim());
                              if (parsed == null || parsed <= 0) return 'Enter a positive number';
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 20),
                          
                          CustomTextField(
                            controller: _reasonController,
                            hintText: 'Reason (Optional)',
                            prefixIcon: Icons.note,
                            validator: (_) => null,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Submit Button
                  const SizedBox(height: 20),
                  CustomButtons.primary(
                    text: 'Update Stock',
                    onPressed: _isSubmitting ? null : _submit,
                    isLoading: _isSubmitting,
                    loadingText: 'Updating...',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
    ),
    );
  }
}


