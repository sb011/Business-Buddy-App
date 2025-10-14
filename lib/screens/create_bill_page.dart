import 'package:flutter/material.dart';
import '../api_calls/bill_apis.dart';
import '../api_calls/inventory_apis.dart';
import '../constants/strings.dart';
import '../models/bill/bill_request.dart';
import '../models/bill/bill_response.dart';
import '../models/item/item.dart';
import '../utils/shared_preferences.dart';

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
  List<Item> _searchResults = [];
  Map<String, Item> _billItemDetails = {}; // persist item details for added items
  Map<String, ItemVariant> _billItemVariants = {}; // track variants for each bill item (itemId+variantId)
  bool _isSearchingCustomer = false;
  bool _isSearchingItems = false;
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

  Future<void> _searchCustomersIfNeeded(String v) async {
    if (v.trim().length < 5) return;
    final String? token = await StorageService.getString(AppStrings.authToken);
    if (token == null) return;
    setState(() => _isSearchingCustomer = true);
    try {
      final customers = await AuthAPI.getCustomers(token: token, query: v.trim());
      if (!mounted) return;
      setState(() {
        _isSearchingCustomer = false;
      });
      if (!mounted) return;
      if (customers.isNotEmpty) {
        // Show a bottom sheet list to pick
        final picked = await showModalBottomSheet<CreateBillCustomer>(
          context: context,
          builder: (ctx) {
            return ListView.separated(
              itemCount: customers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final c = customers[idx];
                return ListTile(
                  title: Text(c.name),
                  subtitle: Text(c.mobileNumber),
                  onTap: () => Navigator.of(ctx).pop(CreateBillCustomer(id: c.id, name: c.name, mobileNumber: c.mobileNumber)),
                );
              },
            );
          },
        );
        if (picked != null) {
          setState(() {
            _selectedCustomer = picked;
            _nameController.text = picked.name;
            _mobileController.text = picked.mobileNumber;
          });
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSearchingCustomer = false);
    }
  }

  Future<void> _searchItems() async {
    final String query = _itemSearchController.text.trim();
    final String? token = await StorageService.getString(AppStrings.authToken);
    if (token == null) return;
    setState(() => _isSearchingItems = true);
    try {
      final results = await InventoryAPI.getInventoryItems(
        token: token,
        limit: 5,
        skip: 0,
        archive: false,
        query: query.isEmpty ? null : query,
      );
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearchingItems = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSearchingItems = false);
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
        title: Text('Select Variant for ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: item.itemVariants.map((variant) {
            return ListTile(
              title: Text(variant.name),
              subtitle: Text('₹${variant.price.toStringAsFixed(2)} • Stock: ${variant.quantity}'),
              onTap: () {
                Navigator.of(context).pop();
                _addVariantToBill(item, variant);
              },
            );
          }).toList(),
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
    final existingIndex = _billItems.indexWhere((it) => it.itemId == item.id && it.itemVariantId == variant.id);
    
    setState(() {
      _billItemDetails[item.id] = item; // persist details
      final variantKey = '${item.id}_${variant.id}';
      _billItemVariants[variantKey] = variant; // track variant for this specific combination
      
      if (existingIndex >= 0) {
        // If same item-variant combination exists, increase quantity
        final current = _billItems[existingIndex];
        final qty = current.quantity;
        _billItems[existingIndex] = CreateBillItem(
          itemId: current.itemId, 
          itemVariantId: current.itemVariantId,
          quantity: (qty + 1)
        );
      } else {
        // If different variant of same item or new item, add as new entry
        _billItems = [..._billItems, CreateBillItem(
          itemId: item.id, 
          itemVariantId: variant.id,
          quantity: 1
        )];
      }
    });
  }

  void _updateItemQuantity(String itemId, String itemVariantId, int delta) {
    final idx = _billItems.indexWhere((bi) => bi.itemId == itemId && bi.itemVariantId == itemVariantId);
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
          quantity: qty
        );
      }
    });
  }

  Future<void> _submit() async {
    final String? token = await StorageService.getString(AppStrings.authToken);
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token not found. Please login again.')),
      );
      return;
    }

    if ((_selectedCustomer == null && (_nameController.text.trim().isEmpty || _mobileController.text.trim().isEmpty)) || _billItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter customer details and add at least one item.')),
      );
      return;
    }

    final CreateBillCustomer customer = _selectedCustomer ?? CreateBillCustomer(
      id: null,
      name: _nameController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
    );

    try {
      setState(() => _isSubmitting = true);
      final request = CreateBillRequest(customer: customer, items: _billItems);
      final BillResponse created = await AuthAPI.createBill(token: token, createBillRequest: request);
      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create bill: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Bill'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customer', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Mobile number',
                suffixIcon: _isSearchingCustomer
                    ? const Padding(padding: EdgeInsets.all(8.0), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                    : null,
              ),
              onChanged: _searchCustomersIfNeeded,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Customer name'),
            ),
            if (_selectedCustomer != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 6),
                  Text('Selected: ${_selectedCustomer!.name}'),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedCustomer = null);
                    },
                    child: const Text('Change'),
                  )
                ],
              )
            ],

            const SizedBox(height: 16),
            const Text('Add Items', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemSearchController,
                    decoration: const InputDecoration(labelText: 'Search items by name'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSearchingItems ? null : _searchItems,
                  child: _isSearchingItems
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_searchResults.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final item = _searchResults[index];
                  final totalStock = item.itemVariants.fold<int>(0, (sum, variant) => sum + variant.quantity);
                  final priceRange = item.itemVariants.length == 1 
                    ? '₹${item.itemVariants.first.price.toStringAsFixed(2)}'
                    : '₹${item.itemVariants.map((v) => v.price).reduce((a, b) => a < b ? a : b).toStringAsFixed(2)} - ₹${item.itemVariants.map((v) => v.price).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}';
                  
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('$priceRange • ${item.itemVariants.length} variant(s) • Total Stock: $totalStock'),
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () => _addItemToBill(item),
                  );
                },
              ),

            const Divider(height: 24),
            const Text('Bill Items', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_billItems.isEmpty)
              const Text('No items added yet', style: TextStyle(color: Colors.grey))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _billItems.length,
                itemBuilder: (context, index) {
                  final bi = _billItems[index];
                  final item = _billItemDetails[bi.itemId];
                  final variantKey = '${bi.itemId}_${bi.itemVariantId}';
                  final variant = _billItemVariants[variantKey];
                  
                  if (item == null || variant == null) {
                    return const Card(
                      child: ListTile(
                        title: Text('Item not found'),
                        subtitle: Text('Please refresh and try again'),
                      ),
                    );
                  }
                  
                  return Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text('${variant.name} • ₹${variant.price.toStringAsFixed(2)} • Qty: ${bi.quantity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _updateItemQuantity(bi.itemId, bi.itemVariantId, -1),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => _updateItemQuantity(bi.itemId, bi.itemVariantId, 1),
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
                const Text('Total: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('₹${_totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Create Bill'),
            ),
          ),
        ),
      ),
    );
  }
}