//D:\projects\nubtk_pilot\lib\features\payment\student_payment_list_screen.dart
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
              bool isPaid = inst['isPaid'] == true;

              // --- সেমিস্টার এবং সেশন বের করার লজিক ---
              // কিস্তির আইডি থেকে ইন্টিজার মান নেওয়া হচ্ছে
              int instID = int.tryParse(inst['id'].toString()) ?? (index + 1);

              // প্রতি ৩টি কিস্তিতে ১টি সেমিস্টার গণনা: ((ID - 1) / 3) + 1
              int semesterNum = ((instID - 1) / 3).floor() + 1;

              // সেমিস্টারের ভেতর কিস্তির ক্রম (Session): ((ID - 1) % 3) + 1
              int sessionNum = ((instID - 1) % 3) + 1;

              String displayName =
                  "Semester $semesterNum (Session $sessionNum)";
              // ----------------------------------------------

              return PaymentTile(
                studentData: {
                  'fullName': data['fullName'] ?? 'Student',
                  'studentId': data['studentId'] ?? data['digitalId'] ?? 'N/A',
                },
                paymentData: {
                  'status': isPaid ? 'Paid' : 'Due',
                  'amount':
                      '${inst['amount']}', // এখানে শুধু টাকার অংকটি পাঠানো হচ্ছে
                  'month':
                      displayName, // এখানে 'Semester X (Session Y)' পাঠানো হচ্ছে
                  'id': inst['id'],
                },
                onPay: isPaid
                    ? () {} // পেমেন্ট হয়ে গেলে রিসিট ডাউনলোড লজিক PaymentTile এর ভেতরে আছে
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

  // পেমেন্ট কনফার্মেশন ডায়ালগ
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[900],
              foregroundColor: Colors.white,
            ),
            child: const Text("Pay Now"),
          ),
        ],
      ),
    );
  }

  // পেমেন্ট প্রসেসিং হ্যান্ডলার
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
