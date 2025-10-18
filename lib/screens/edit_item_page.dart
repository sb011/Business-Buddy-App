import 'package:business_buddy_app/api_calls/inventory_apis.dart';
import 'package:business_buddy_app/models/item/item.dart';
import 'package:business_buddy_app/models/item/item_request.dart';
import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../constants/permissions.dart';
import '../constants/colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/shared_preferences.dart';
import '../widgets/permission_wrapper.dart';

class EditItemPage extends StatefulWidget {
  final Item item;

  const EditItemPage({super.key, required this.item});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _descriptionController = TextEditingController(text: widget.item.description);
    _categoryController = TextEditingController(text: widget.item.category);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
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
      final UpdateItemRequest request = UpdateItemRequest(
        id: widget.item.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
      );

      await InventoryAPI.updateItem(
        context: context,
        token: token,
        updateItemRequest: request,
      );

      final Item updated = Item(
        id: widget.item.id,
        name: request.name,
        description: request.description,
        category: request.category,
        inventoryId: widget.item.inventoryId,
        itemVariants: widget.item.itemVariants, // Keep existing variants
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
      permission: AppPermissions.updateItem,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Edit Item',
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
                        'Edit Item',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Update details for "${widget.item.name}"',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                  
                  // Form Fields
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'Item Name',
                            prefixIcon: Icons.inventory_2_outlined,
                            validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter name' : null,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),
                          
                          CustomTextField(
                            controller: _descriptionController,
                            hintText: 'Description',
                            prefixIcon: Icons.description,
                            validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter description' : null,
                            textInputAction: TextInputAction.next,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 20),
                          
                          CustomTextField(
                            controller: _categoryController,
                            hintText: 'Category',
                            prefixIcon: Icons.category,
                            validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter category' : null,
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
                    text: 'Save Changes',
                    onPressed: _isSubmitting ? null : _submit,
                    isLoading: _isSubmitting,
                    loadingText: 'Saving...',
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


