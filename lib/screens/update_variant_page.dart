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
        context: context,
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Update Variant',
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
                        'Update Variant',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Edit details for "${widget.variant.name}"',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                  
                  // Variant Info Card
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
                          'Variant Information',
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
                            Icon(Icons.inventory, color: AppColors.textDarkPrimary, size: 20),
                            const SizedBox(width: 8),
                            Text('Current Stock: ${widget.variant.quantity}', style: TextStyle(color: AppColors.textDarkPrimary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.info, color: AppColors.textDarkPrimary, size: 20),
                            const SizedBox(width: 8),
                            Text('Status: ${widget.variant.archived ? "Archived" : "Active"}', style: TextStyle(color: AppColors.textDarkPrimary)),
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
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'Variant Name',
                            prefixIcon: Icons.label,
                            validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter variant name' : null,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),
                          
                          CustomTextField(
                            controller: _priceController,
                            hintText: 'Price (₹)',
                            prefixIcon: Icons.currency_rupee,
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
                        ],
                      ),
                    ),
                  ),
                  
                  // Submit Button
                  const SizedBox(height: 20),
                  CustomButtons.primary(
                    text: 'Update Variant',
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
