import 'package:business_buddy_app/api_calls/inventory_apis.dart';
import 'package:business_buddy_app/constants/constants.dart';
import 'package:business_buddy_app/models/item/item.dart';
import 'package:business_buddy_app/models/item/item_request.dart';
import 'package:flutter/material.dart';

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
        appBar: AppBar(
          title: const Text('Add Stock'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Item ID: ${widget.item.id}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text('Item Name: ${widget.item.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Total Variants: ${widget.item.itemVariants.length}', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              
              // Variant selection
              if (widget.item.itemVariants.length > 1) ...[
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
                const SizedBox(height: 16),
              ],
              
              // Current stock info
              if (_selectedVariant != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selected Variant: ${_selectedVariant!.name}', 
                           style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Current Stock: ${_selectedVariant!.quantity}'),
                      Text('Price: ₹${_selectedVariant!.price.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              TextFormField(
                controller: _qtyController,
                decoration: const InputDecoration(labelText: 'Add Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter quantity';
                  final parsed = int.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) return 'Enter a positive number';
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(labelText: 'Reason'),
                // optional field
                validator: (_) => null,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update Stock'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}


