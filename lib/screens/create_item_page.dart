import 'package:business_buddy_app/api_calls/inventory_apis.dart';
import 'package:business_buddy_app/models/item/item_request.dart';
import 'package:business_buddy_app/models/item/item.dart';
import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../constants/permissions.dart';
import '../constants/style.dart';
import '../utils/shared_preferences.dart';
import '../widgets/permission_wrapper.dart';

class CreateItemPage extends StatefulWidget {
  const CreateItemPage({super.key});

  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _variantNameController = TextEditingController();
  final TextEditingController _variantPriceController = TextEditingController();
  final TextEditingController _variantQuantityController = TextEditingController();

  List<CreateItemItemVariant> _variants = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _variantNameController.dispose();
    _variantPriceController.dispose();
    _variantQuantityController.dispose();
    super.dispose();
  }

  void _addVariant() {
    if (_variantNameController.text.trim().isEmpty ||
        _variantPriceController.text.trim().isEmpty ||
        _variantQuantityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all variant fields')),
      );
      return;
    }

    final price = double.tryParse(_variantPriceController.text.trim());
    final quantity = int.tryParse(_variantQuantityController.text.trim());

    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    if (quantity == null || quantity < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    setState(() {
      _variants.add(CreateItemItemVariant(
        name: _variantNameController.text.trim(),
        price: price,
        quantity: quantity,
      ));
      _variantNameController.clear();
      _variantPriceController.clear();
      _variantQuantityController.clear();
    });
  }

  void _removeVariant(int index) {
    setState(() {
      _variants.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_variants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one variant')),
      );
      return;
    }

    final String? token = await StorageService.getString(AppStrings.authToken);
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token not found. Please login again.')),
      );
      Navigator.of(context).pop(false);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final CreateItemRequest request = CreateItemRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        itemVariants: _variants,
      );

      final Item createdItem = await InventoryAPI.createItem(
        context: context,
        token: token,
        createItemRequest: request,
      );

      if (!mounted) return;
      Navigator.of(context).pop(createdItem);
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
      permission: AppPermissions.createItem,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Item'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter name' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter description' : null,
                textInputAction: TextInputAction.next,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter category' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              
              // Variant management section
              const Text('Item Variants', style: TextStyle(fontSize: Style.fontSize5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              // Add variant form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add Variant', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _variantNameController,
                        decoration: const InputDecoration(labelText: 'Variant Name'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _variantPriceController,
                              decoration: const InputDecoration(labelText: 'Price'),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _variantQuantityController,
                              decoration: const InputDecoration(labelText: 'Quantity'),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _addVariant(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addVariant,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Variant'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Variants list
              if (_variants.isNotEmpty) ...[
                const Text('Added Variants', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...(_variants.asMap().entries.map((entry) {
                  final index = entry.key;
                  final variant = entry.value;
                  return Card(
                    child: ListTile(
                      title: Text(variant.name),
                      subtitle: Text('₹${variant.price.toStringAsFixed(2)} • Qty: ${variant.quantity}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeVariant(index),
                      ),
                    ),
                  );
                }).toList()),
                const SizedBox(height: 16),
              ],
              
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
                      : const Text('Create Item'),
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


