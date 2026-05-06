// D:\projects\nubtk_pilot\lib\features\payment\student_payment_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../student/screens/payment_tile.dart';
import 'payment_service.dart';

class StudentPaymentListScreen extends StatelessWidget {
  const StudentPaymentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Installments"),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text("No installment plan found."));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          var installments = data['installments'] as List? ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: installments.length,
            itemBuilder: (context, index) {
              var inst = installments[index];
              // ডাটাবেজ থেকে সরাসরি boolean চেক
              bool isPaid = inst['isPaid'] == true;

              return PaymentTile(
                studentData: {
                  'fullName': data['fullName'] ?? 'Student',
                  'studentId': data['studentId'] ?? data['digitalId'] ?? 'N/A',
                },
                paymentData: {
                  'status': isPaid ? 'Paid' : 'Due',
                  'amount': '${inst['amount']} TK',
                  'title': 'Semester ${inst['semester']}',
                  'id': inst['id'],
                },
                // যদি পেইড হয়, তবে ক্লিক করলে কিছু হবে না
                onPay: isPaid
                    ? () {}
                    : () => _showPaymentConfirmDialog(
                        context,
                        inst['id'],
                        inst['amount'].toString(),
                      ),
              );
            },
          );
        },
      ),
    );
  }

  void _showPaymentConfirmDialog(
    BuildContext context,
    String installmentId,
    String amount,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Payment"),
        content: Text("Do you want to pay $amount TK?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handlePayment(context, installmentId);
            },
            child: const Text("Pay Now"),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment(
    BuildContext context,
    String installmentId,
  ) async {
    try {
      await PaymentService.markInstallmentPaid(installmentId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment Successful!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}
