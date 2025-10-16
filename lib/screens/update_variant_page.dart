import 'package:business_buddy_app/api_calls/inventory_apis.dart';
import 'package:business_buddy_app/models/item/item.dart';
import 'package:business_buddy_app/models/item/item_request.dart';
import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../constants/permissions.dart';
import '../utils/shared_preferences.dart';
import '../widgets/permission_wrapper.dart';

class UpdateVariantPage extends StatefulWidget {
  final Item item;
  final ItemVariant variant;

  const UpdateVariantPage({super.key, required this.item, required this.variant});

  @override
  State<UpdateVariantPage> createState() => _UpdateVariantPageState();
}

class _UpdateVariantPageState extends State<UpdateVariantPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.variant.name);
    _priceController = TextEditingController(text: widget.variant.price.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

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
      final UpdateItemVariant request = UpdateItemVariant(
        itemVariantId: widget.variant.id,
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
      );

      await InventoryAPI.updateItemVariant(
        token: token,
        updateItemVariant: request,
      );

      // Update the variant in the item
      final updatedVariants = widget.item.itemVariants.map((variant) {
        if (variant.id == widget.variant.id) {
          return ItemVariant(
            id: variant.id,
            itemId: variant.itemId,
            name: request.name,
            price: request.price,
            quantity: variant.quantity,
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
      permission: AppPermissions.updateItemVariant,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Update Variant'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Variant info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Variant Information',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Item: ${widget.item.name}'),
                      Text('Current Stock: ${widget.variant.quantity}'),
                      Text('Status: ${widget.variant.archived ? "Archived" : "Active"}'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Variant Name'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter variant name' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter price';
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed < 0) return 'Enter valid price';
                  return null;
                },
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
                      : const Text('Update Variant'),
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
