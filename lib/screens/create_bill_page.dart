import 'package:flutter/material.dart';
import '../api_calls/bill_apis.dart';
import '../api_calls/inventory_apis.dart';
import '../constants/strings.dart';
import '../constants/permissions.dart';
import '../constants/colors.dart';
import '../widgets/custom_text_field.dart';
import '../models/bill/bill_request.dart';
import '../models/bill/bill_response.dart';
import '../models/bill/bill.dart';
import '../models/item/item.dart';
import '../utils/shared_preferences.dart';
import '../widgets/permission_wrapper.dart';

class CreateBillPage extends StatefulWidget {
  const CreateBillPage({super.key});

  @override
  State<CreateBillPage> createState() => _CreateBillPageState();
}

class _CreateBillPageState extends State<CreateBillPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _itemSearchController = TextEditingController();
  
  CreateBillCustomer? _selectedCustomer; // set when user picks existing
  List<CreateBillItem> _billItems = [];
  Map<String, Item> _billItemDetails =
      {}; // persist item details for added items
  Map<String, ItemVariant> _billItemVariants =
      {}; // track variants for each bill item (itemId+variantId)
  bool _isSubmitting = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _nameController.dispose();
    _itemSearchController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    double total = 0;
    for (final billItem in _billItems) {
      final variantKey = '${billItem.itemId}_${billItem.itemVariantId}';
      final variant = _billItemVariants[variantKey];
      if (variant != null) {
        total += billItem.quantity * variant.price;
      }
    }
    return total;
  }

  // Search customers by mobile number
  Future<void> _searchCustomersIfNeeded(String mobileNumber) async {
    
    if (mobileNumber.trim().length < 5) {
      // Don't clear results immediately, just don't search
      return;
    }
    
    final String? token = await StorageService.getString(AppStrings.authToken);
    if (token == null) {
      return;
    }
    
    // Don't set loading state here to avoid flickering
    try {
      final customers = await AuthAPI.getCustomers(
        context: context,
        token: token,
        query: mobileNumber.trim(),
      );
      if (!mounted) return;
      
      // Show customer selection dialog
      if (customers.isNotEmpty) {
        _showCustomerSelectionDialog(customers);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No customers found with this mobile number')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching customers: $e')),
      );
    }
  }

  // Search items by name
  Future<void> _searchItems() async {
    final String query = _itemSearchController.text.trim();
    if (query.isEmpty) {
      return;
    }
    
    final String? token = await StorageService.getString(AppStrings.authToken);
    if (token == null) return;
    
    try {
      final items = await InventoryAPI.getInventoryItems(
        context: context,
        token: token,
        limit: 20,
        skip: 0,
        archive: false,
        query: query,
      );
      if (!mounted) return;
      
      // Show item selection dialog
      if (items.isNotEmpty) {
        _showItemSelectionDialog(items);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No items found with this name')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching items: $e')),
      );
    }
  }

  void _addItemToBill(Item item) {
    
    if (item.itemVariants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This item has no variants available')),
      );
      return;
    }

    // If item has only one variant, add it directly
    if (item.itemVariants.length == 1) {
      final variant = item.itemVariants.first;
      _addVariantToBill(item, variant);
      return;
    }

    // Show variant selection dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Select Variant for ${item.name}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDarkPrimary,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: item.itemVariants.length,
            itemBuilder: (context, index) {
              final variant = item.itemVariants[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.textDarkPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
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
                  trailing: Icon(
                    Icons.add_circle_outline,
                    color: AppColors.textDarkPrimary,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addVariantToBill(item, variant);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addVariantToBill(Item item, ItemVariant variant) {
    
    // Check if this exact item-variant combination already exists
    final existingIndex = _billItems.indexWhere(
      (it) => it.itemId == item.id && it.itemVariantId == variant.id,
    );

    setState(() {
      _billItemDetails[item.id] = item; // persist details
      final variantKey = '${item.id}_${variant.id}';
      _billItemVariants[variantKey] =
          variant; // track variant for this specific combination

      if (existingIndex >= 0) {
        // If same item-variant combination exists, increase quantity
        final current = _billItems[existingIndex];
        final qty = current.quantity;
        _billItems[existingIndex] = CreateBillItem(
          itemId: current.itemId,
          itemVariantId: current.itemVariantId,
          quantity: (qty + 1),
        );
      } else {
        // If different variant of same item or new item, add as new entry
        _billItems = [
          ..._billItems,
          CreateBillItem(
            itemId: item.id,
            itemVariantId: variant.id,
            quantity: 1,
          ),
        ];
      }
    });
  }

  void _updateItemQuantity(String itemId, String itemVariantId, int delta) {
    final idx = _billItems.indexWhere(
      (bi) => bi.itemId == itemId && bi.itemVariantId == itemVariantId,
    );
    if (idx < 0) return;
    setState(() {
      final current = _billItems[idx];
      final qty = current.quantity + delta;
      if (qty <= 0) {
        _billItems.removeAt(idx);
      } else {
        _billItems[idx] = CreateBillItem(
          itemId: current.itemId,
          itemVariantId: current.itemVariantId,
          quantity: qty,
        );
      }
    });
  }

  Future<void> _submit() async {
    final String? token = await StorageService.getString(AppStrings.authToken);
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication token not found. Please login again.'),
        ),
      );
      return;
    }

    if ((_selectedCustomer == null && 
            (_nameController.text.trim().isEmpty || _mobileController.text.trim().isEmpty)) ||
        _billItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter customer details and add at least one item.'),
        ),
      );
      return;
    }

    final CreateBillCustomer customer = _selectedCustomer ??
        CreateBillCustomer(
          id: null,
          name: _nameController.text.trim(),
          mobileNumber: _mobileController.text.trim(),
        );

    try {
      setState(() => _isSubmitting = true);
      final request = CreateBillRequest(customer: customer, items: _billItems);
      
      // Debug logging
      
      final BillResponse created = await AuthAPI.createBill(
        context: context,
        token: token,
        createBillRequest: request,
      );
      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create bill: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // Show Customer Selection Dialog
  void _showCustomerSelectionDialog(List<Customer> customers) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Select Customer',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDarkPrimary,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.textDarkPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.textDarkPrimary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    customer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDarkPrimary,
                    ),
                  ),
                  subtitle: Text(
                    customer.mobileNumber,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.textDarkPrimary,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedCustomer = CreateBillCustomer(
                        id: customer.id,
                        name: customer.name,
                        mobileNumber: customer.mobileNumber,
                      );
                      _nameController.text = customer.name;
                    });
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Show Item Selection Dialog
  void _showItemSelectionDialog(List<Item> items) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Select Item',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDarkPrimary,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final totalStock = item.itemVariants.fold<int>(0, (sum, variant) => sum + variant.quantity);
              final priceRange = item.itemVariants.length == 1 
                ? '₹${item.itemVariants.first.price.toStringAsFixed(2)}'
                : '₹${item.itemVariants.map((v) => v.price).reduce((a, b) => a < b ? a : b).toStringAsFixed(2)} - ₹${item.itemVariants.map((v) => v.price).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}';
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.textDarkPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.textDarkPrimary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDarkPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '$priceRange • ${item.itemVariants.length} variant(s) • Stock: $totalStock',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Icon(
                    Icons.add_circle_outline,
                    color: AppColors.textDarkPrimary,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addItemToBill(item);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      permission: AppPermissions.createBill,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Create Bill',
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
            TextButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textDarkPrimary,
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        color: AppColors.textDarkPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
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
                      // Header Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create New Bill',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDarkPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add customer details and items to create a bill',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),

                       // Customer Section
                       Text(
                         'Customer Details',
                         style: const TextStyle(
                           fontSize: 20,
                           fontWeight: FontWeight.bold,
                           color: AppColors.textDarkPrimary,
                         ),
                       ),
                       const SizedBox(height: 16),
                       
                       // Mobile Number Search
                       CustomTextField(
                         controller: _mobileController,
                         hintText: 'Mobile Number',
                         prefixIcon: Icons.phone,
                         keyboardType: TextInputType.phone,
                         suffixIcon: null,
                         onChanged: _searchCustomersIfNeeded,
                       ),
                       
                       // Customer Name Input (for new customers)
                       const SizedBox(height: 16),
                       CustomTextField(
                         controller: _nameController,
                         hintText: 'Customer Name',
                         prefixIcon: Icons.person,
                       ),
                       
                       // Selected Customer Display
                       if (_selectedCustomer != null) ...[
                         const SizedBox(height: 16),
                         Container(
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: AppColors.success.withValues(alpha: 0.1),
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(
                               color: AppColors.success.withValues(alpha: 0.3),
                             ),
                           ),
                           child: Row(
                             children: [
                               Icon(Icons.check_circle, color: AppColors.success, size: 20),
                               const SizedBox(width: 12),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       'Selected: ${_selectedCustomer!.name}',
                                       style: const TextStyle(
                                         fontWeight: FontWeight.w600,
                                         color: AppColors.textDarkPrimary,
                                       ),
                                     ),
                                     Text(
                                       _selectedCustomer!.mobileNumber,
                                       style: TextStyle(color: AppColors.textSecondary),
                                     ),
                                   ],
                                 ),
                               ),
                               TextButton(
                                 onPressed: () {
                                   setState(() {
                                     _selectedCustomer = null;
                                     _nameController.clear();
                                     _mobileController.clear();
                                   });
                                 },
                                 child: const Text('Change'),
                               ),
                             ],
                           ),
                         ),
                       ],

                       const SizedBox(height: 32),
                       
                       // Items Section
                       Text(
                         'Add Items',
                         style: const TextStyle(
                           fontSize: 20,
                           fontWeight: FontWeight.bold,
                           color: AppColors.textDarkPrimary,
                         ),
                       ),
                       const SizedBox(height: 16),
                       
                       // Item Search
                       Row(
                         children: [
                           Expanded(
                             child: CustomTextField(
                               controller: _itemSearchController,
                               hintText: 'Search items by name',
                               prefixIcon: Icons.search,
                             ),
                           ),
                           const SizedBox(width: 12),
                           ElevatedButton(
                             onPressed: _searchItems,
                             style: ElevatedButton.styleFrom(
                               backgroundColor: AppColors.textDarkPrimary,
                               foregroundColor: AppColors.background,
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(12),
                               ),
                               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                             ),
                             child: const Text('Search'),
                           ),
                         ],
                       ),
                       
                       const Divider(height: 24),
                      const Text(
                        'Bill Items',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (_billItems.isEmpty)
                        const Text(
                          'No items added yet',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _billItems.length,
                          itemBuilder: (context, index) {
                            final bi = _billItems[index];
                            final item = _billItemDetails[bi.itemId];
                            final variantKey =
                                '${bi.itemId}_${bi.itemVariantId}';
                            final variant = _billItemVariants[variantKey];

                            if (item == null || variant == null) {
                              return const Card(
                                child: ListTile(
                                  title: Text('Item not found'),
                                  subtitle: Text(
                                    'Please refresh and try again',
                                  ),
                                ),
                              );
                            }

                            return Card(
                              child: ListTile(
                                title: Text(item.name),
                                subtitle: Text(
                                  '${variant.name} • ₹${variant.price.toStringAsFixed(2)} • Qty: ${bi.quantity}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () => _updateItemQuantity(
                                        bi.itemId,
                                        bi.itemVariantId,
                                        -1,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed: () => _updateItemQuantity(
                                        bi.itemId,
                                        bi.itemVariantId,
                                        1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Total: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹${_totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Fixed bottom button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
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
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textDarkPrimary,
                    foregroundColor: AppColors.textLightPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textLightPrimary,
                          ),
                        )
                      : const Text(
                          'Create Bill',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
