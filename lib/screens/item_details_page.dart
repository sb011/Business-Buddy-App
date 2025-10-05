import 'package:business_buddy_app/models/item/item.dart';
import 'package:flutter/material.dart';

import 'edit_item_page.dart';
import 'add_stock_page.dart';

class ItemDetailsPage extends StatefulWidget {
  final Item item;

  const ItemDetailsPage({super.key, required this.item});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  late Item _currentItem;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
  }

  Future<void> _editItem() async {
    final updated = await Navigator.of(context).push<Item>(
      MaterialPageRoute(
        builder: (context) => EditItemPage(item: _currentItem),
      ),
    );
    if (updated is Item) {
      setState(() {
        _currentItem = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(_currentItem),
        ),
        title: const Text('Item Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                await _editItem();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    _currentItem.name.isNotEmpty ? _currentItem.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentItem.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${_currentItem.id}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '₹${_currentItem.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Description',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(_currentItem.description),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _currentItem.category,
                    style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Qty: ${_currentItem.quantity}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final updated = await Navigator.of(context).push<Item>(
                    MaterialPageRoute(
                      builder: (context) => AddStockPage(item: _currentItem),
                    ),
                  );
                  if (updated is Item) {
                    if (!mounted) return;
                    setState(() {
                      _currentItem = updated;
                    });
                  }
                },
                icon: const Icon(Icons.add_chart),
                label: const Text('Add Stock'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


