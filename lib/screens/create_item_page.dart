import 'package:business_buddy_app/api_calls/inventory_apis.dart';
import 'package:business_buddy_app/models/item/item_request.dart';
import 'package:business_buddy_app/models/item/item.dart';
import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../constants/permissions.dart';
import '../constants/colors.dart';
import '../utils/shared_preferences.dart';
import '../widgets/permission_wrapper.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

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
  final TextEditingController _variantQuantityController =
      TextEditingController();

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
      _variants.add(
        CreateItemItemVariant(
          name: _variantNameController.text.trim(),
          price: price,
          quantity: quantity,
        ),
      );
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
        const SnackBar(
          content: Text('Authentication token not found. Please login again.'),
        ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      permission: AppPermissions.createItem,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Create Item',
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
                        'Add New Item',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDarkPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fill in the details to create a new inventory item',
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
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? 'Enter name'
                                : null,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),

                          CustomTextField(
                            controller: _descriptionController,
                            hintText: 'Description',
                            prefixIcon: Icons.description,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? 'Enter description'
                                : null,
                            textInputAction: TextInputAction.next,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 20),

                          CustomTextField(
                            controller: _categoryController,
                            hintText: 'Category',
                            prefixIcon: Icons.category,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? 'Enter category'
                                : null,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 32),

                          // Variant management section
                          Text(
                            'Item Variants',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDarkPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Add variant form
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add Variant',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDarkPrimary,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                CustomTextField(
                                  controller: _variantNameController,
                                  hintText: 'Variant Name',
                                  prefixIcon: Icons.label,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        controller: _variantPriceController,
                                        hintText: 'Price (₹)',
                                        prefixIcon: Icons.currency_rupee,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        textInputAction: TextInputAction.next,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: CustomTextField(
                                        controller: _variantQuantityController,
                                        hintText: 'Quantity',
                                        prefixIcon: Icons.numbers,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) => _addVariant(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                CustomButtons.secondary(
                                  text: 'Add Variant',
                                  icon: const Icon(Icons.add),
                                  onPressed: _addVariant,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Variants list
                          if (_variants.isNotEmpty) ...[
                            Text(
                              'Added Variants',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDarkPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...(_variants.asMap().entries.map((entry) {
                              final index = entry.key;
                              final variant = entry.value;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Material(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  elevation: 2,
                                  shadowColor: AppColors.textSecondary
                                      .withValues(alpha: 0.1),
                                  child: ListTile(
                                    title: Text(
                                      variant.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDarkPrimary,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '₹${variant.price.toStringAsFixed(2)} • Qty: ${variant.quantity}',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: AppColors.danger,
                                      ),
                                      onPressed: () => _removeVariant(index),
                                    ),
                                  ),
                                ),
                              );
                            }).toList()),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Submit Button
                  const SizedBox(height: 20),
                  CustomButtons.primary(
                    text: 'Create Item',
                    onPressed: _isSubmitting ? null : _submit,
                    isLoading: _isSubmitting,
                    loadingText: 'Creating...',
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
