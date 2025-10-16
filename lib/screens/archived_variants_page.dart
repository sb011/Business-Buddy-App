import 'package:business_buddy_app/models/item/item.dart';
import 'package:business_buddy_app/api_calls/inventory_apis.dart';
import 'package:business_buddy_app/models/item/item_request.dart';
import 'package:business_buddy_app/utils/shared_preferences.dart';
import 'package:business_buddy_app/constants/strings.dart';
import 'package:business_buddy_app/constants/permissions.dart';
import 'package:business_buddy_app/widgets/permission_wrapper.dart';
import 'package:flutter/material.dart';

class ArchivedVariantsPage extends StatefulWidget {
  const ArchivedVariantsPage({super.key});

  @override
  State<ArchivedVariantsPage> createState() => _ArchivedVariantsPageState();
}

class _ArchivedVariantsPageState extends State<ArchivedVariantsPage> {
  List<ItemVariant> _archivedVariants = [];
  bool _isLoading = true;
  bool _isUnarchiving = false;

  @override
  void initState() {
    super.initState();
    _loadArchivedVariants();
  }

  Future<void> _loadArchivedVariants() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final String? token = await StorageService.getString(AppStrings.authToken);
      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please login again.')),
        );
        return;
      }

      final variants = await InventoryAPI.getArchivedItemVariants(token: token);
      
      if (!mounted) return;
      setState(() {
        _archivedVariants = variants;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load archived variants: $e')),
      );
    }
  }

  Future<void> _unarchiveVariant(ItemVariant variant) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unarchive Variant?'),
          content: const Text('Are you sure you want to unarchive this variant?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      setState(() {
        _isUnarchiving = true;
      });

      final String? token = await StorageService.getString(AppStrings.authToken);
      if (token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please login again.')),
        );
        return;
      }

      final request = ItemVariantArchiveRequest(
        itemId: variant.itemId,
        itemVariantId: variant.id,
        isArchive: false,
      );
      await InventoryAPI.archiveItemVariant(token: token, itemVariantArchiveRequest: request);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Variant unarchived successfully')),
      );

      // Remove the variant from the list immediately without additional API calls
      setState(() {
        _archivedVariants.removeWhere((v) => v.id == variant.id);
        _isUnarchiving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUnarchiving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unarchive variant: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PermissionWrapper(
      permission: AppPermissions.getItemVariant,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Archived Variants'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadArchivedVariants,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _archivedVariants.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.archive_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No archived variants found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadArchivedVariants,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _archivedVariants.length,
                    itemBuilder: (context, index) {
                      final variant = _archivedVariants[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.shade100,
                            child: Icon(
                              Icons.archive,
                              color: Colors.red.shade700,
                            ),
                          ),
                          title: Text(
                            variant.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('₹${variant.price.toStringAsFixed(2)}'),
                              Text('Stock: ${variant.quantity}'),
                              Text(
                                'Archived: ${variant.updatedAt.day}/${variant.updatedAt.month}/${variant.updatedAt.year}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: _isUnarchiving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.unarchive, color: Colors.green),
                                  onPressed: () => _unarchiveVariant(variant),
                                ),
                        ),
                      );
                    },
                  ),
                ),
    ),
    );
  }
}
