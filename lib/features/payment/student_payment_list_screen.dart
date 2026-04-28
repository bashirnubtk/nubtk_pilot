import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// সঠিক পাথ: এক ধাপ পেছনে গিয়ে পেমেন্ট সার্ভিস এবং পাশের টাইল ফাইলটি নেওয়া
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
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          var data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null || !data.containsKey('installments')) {
            return const Center(child: Text("No installment plan found."));
          }

          var installments = data['installments'] as List;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: installments.length,
            itemBuilder: (context, index) {
              var inst = installments[index];
              return PaymentTile(
                paymentData: {
                  'status': inst['isPaid'] ? 'Paid' : 'Due',
                  'percentage': '${inst['amount']} TK',
                  'month': 'Semester ${inst['semester']}',
                  'semester': inst['semester'],
                  'amount': inst['amount'],
                  'name': data['fullName'],
                  'digitalId': data['digitalId'],
                },
                onPay: () async {
                  await PaymentService.markInstallmentPaid(inst['id']);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Payment Successful!")),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}