import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bill/bill_response.dart';

class BillDetailsPage extends StatelessWidget {
  final BillResponse bill;
  const BillDetailsPage({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Details'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _HeaderCard(bill: bill),
          const SizedBox(height: 16),
          _ItemsSection(bill: bill),
          const SizedBox(height: 16),
          _SummarySection(bill: bill),
        ],
      ),
    );
  }
}


class _HeaderCard extends StatelessWidget {
  final BillResponse bill;
  const _HeaderCard({required this.bill});

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$d/$m/$y · $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    bill.customer.name.isNotEmpty ? bill.customer.name[0].toUpperCase() : '?',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bill.customer.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(bill.customer.mobileNumber, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.currency_rupee, size: 16, color: Colors.green),
                      Text(
                        bill.totalAmount.toStringAsFixed(2),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.receipt_long, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'ID: ${bill.id}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Copy ID',
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: bill.id));
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bill ID copied')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.event, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(_formatDate(bill.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemsSection extends StatelessWidget {
  final BillResponse bill;
  const _ItemsSection({required this.bill});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
              child: Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bill.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final it = bill.items[index];
                final subtotal = it.quantity * it.pricePerUnit;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.green.shade50,
                    child: const Icon(Icons.inventory_2, size: 18, color: Colors.green),
                  ),
                  title: Text('Item: ${it.itemId}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('Qty: ${it.quantity} × ₹${it.pricePerUnit.toStringAsFixed(2)}'),
                  trailing: Text(
                    '₹${subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final BillResponse bill;
  const _SummarySection({required this.bill});

  double _computedTotal() {
    return bill.items.fold(0.0, (sum, it) => sum + (it.quantity * it.pricePerUnit));
  }

  @override
  Widget build(BuildContext context) {
    final computed = _computedTotal();
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.currency_rupee, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${bill.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                if ((bill.totalAmount - computed).abs() > 0.009)
                  Text('Calc: ₹${computed.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


