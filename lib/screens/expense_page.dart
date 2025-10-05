import 'package:flutter/material.dart';

class ExpensePage extends StatelessWidget {
  const ExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.money_off,
            size: 80,
            color: Colors.orange,
          ),
          SizedBox(height: 20),
          Text(
            'Expense Tracking',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Monitor your business expenses',
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

