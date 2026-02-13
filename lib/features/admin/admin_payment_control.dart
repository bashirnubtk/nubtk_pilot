import 'package:flutter/material.dart';
import '../payment/payment_service.dart';

class AdminPaymentControl extends StatelessWidget {
  final String studentId;
  const AdminPaymentControl({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.calculate),
          onPressed: () async {
            try {
              await PaymentService.createPaymentPlan(
                studentId: studentId,
                grade: "A+", 
                totalCourseFee: 800000,
              );
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment Plan Generated!")),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            }
          },
          label: const Text("Generate Payment Plan"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}