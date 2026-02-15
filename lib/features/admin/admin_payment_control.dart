import 'package:flutter/material.dart';

class AdminPaymentControl extends StatelessWidget {
  final String studentId;
  const AdminPaymentControl({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.calculate),
        onPressed: () {
          // এখানে পেমেন্ট সার্ভিসের মেথড কল হবে
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment Plan Feature Integration Pending")),
          );
        },
        label: const Text("Generate Payment Plan"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      ),
    );
  }
}