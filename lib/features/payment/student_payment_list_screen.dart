import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// আপনার বিদ্যমান ইমপোর্টগুলো
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
        // লজিক আপডেট: অ্যাডমিন যেহেতু 'students' কালেকশনে ডাটা সেভ করছে, তাই এখান থেকেই রিড করতে হবে
        stream: FirebaseFirestore.instance.collection('students').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text("No installment plan found."));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          
          // কিস্তি ডাটা চেক করা
          if (!data.containsKey('installments')) {
            return const Center(child: Text("No installment records."));
          }

          var installments = data['installments'] as List;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: installments.length,
            itemBuilder: (context, index) {
              var inst = installments[index];
              
              return PaymentTile(
                paymentData: {
                  'status': inst['isPaid'] == true ? 'Paid' : 'Due',
                  'percentage': '${inst['amount']} TK',
                  'month': 'Semester ${inst['semester']}',
                  'semester': inst['semester'],
                  'amount': inst['amount'],
                  'name': data['fullName'] ?? 'Student',
                  'digitalId': data['studentId'] ?? data['digitalId'] ?? 'N/A',
                },
                // এরর ফিক্স: ফাংশনটিকে সরাসরি এভাবে লিখলে 'VoidCallback' এর সমস্যা হবে না
                onPay: () {
                  if (inst['isPaid'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Already Paid!")),
                    );
                    return;
                  }
                  
                  // পেমেন্ট প্রসেস শুরু
                  _handlePayment(context, inst['id']);
                },
              );
            },
          );
        },
      ),
    );
  }

  // পেমেন্ট লজিক আলাদা ফাংশন হিসেবে (যাতে এরর না আসে)
  Future<void> _handlePayment(BuildContext context, String installmentId) async {
    try {
      // আপনার বিদ্যমান সার্ভিস কল
      await PaymentService.markInstallmentPaid(installmentId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment Successful!"), backgroundColor: Colors.green),
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