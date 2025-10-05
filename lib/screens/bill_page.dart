import 'package:flutter/material.dart';

class BillPage extends StatelessWidget {
  const BillPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.green,
          ),
          SizedBox(height: 20),
          Text(
            'Bill Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Create and manage your bills',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

