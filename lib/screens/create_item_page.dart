import 'package:business_buddy_app/api_calls/inventory_apis.dart';
import 'package:business_buddy_app/models/item/item_request.dart';
import 'package:business_buddy_app/models/item/item.dart';
import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../utils/shared_preferences.dart';

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
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
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
      Navigator.of(context).pop(false);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final CreateItemRequest request = CreateItemRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        quantity: int.parse(_quantityController.text.trim()),
      );

      final Item createdItem = await InventoryAPI.createItem(
        token: token,
        createInventoryRequest: request.toJson(),
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
    return Scaffold(
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
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter quantity';
                  final parsed = int.tryParse(value.trim());
                  if (parsed == null || parsed < 0) return 'Enter valid quantity';
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
                      : const Text('Create Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


