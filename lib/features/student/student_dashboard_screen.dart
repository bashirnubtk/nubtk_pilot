import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'student_widgets/student_status_banner.dart';
import 'student_widgets/digital_id_card_preview.dart';
import 'student_widgets/student_menu_tile.dart';
import 'student_widgets/payment_tile.dart'; 
import '../payment/payment_model.dart';
import '../payment/payment_service.dart';
import '../../features/auth/login_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  // পেমেন্ট হ্যান্ডলার লজিক
  void _handlePayment(Installment inst) async {
    try {
      await PaymentService.markInstallmentPaid(inst.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Installment ${inst.semester} paid successfully ✅'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text("Student Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('students').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Student record not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String status = data['status'] ?? 'pending';

          // Firestore থেকে পেমেন্ট প্ল্যান ডাটা নিয়ে আসা
          List<dynamic> paymentListRaw = data['installments'] ?? [];
          List<Installment> installments = paymentListRaw
              .map((item) => Installment.fromMap(item as Map<String, dynamic>))
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // আপনার সেই সুন্দর স্ট্যাটাস ব্যানার
                StudentStatusBanner(status: status),
                const SizedBox(height: 16),

                // আইডি কার্ড প্রিভিউ
                DigitalIdCardPreview(
                  name: data['fullName'] ?? 'N/A',
                  department: data['department'] ?? 'N/A',
                  digitalId: data['digitalId'] ?? 'N/A',
                  status: status,
                ),
                const SizedBox(height: 24),

                const Text("Quick Menu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                StudentMenuTile(
                  icon: Icons.badge,
                  title: "Digital ID",
                  locked: status != 'approved',
                  onTap: () {},
                ),

                const SizedBox(height: 24),
                // পেমেন্ট সেকশন - যা এখন পেমেন্ট কার্ড আকারে দেখাবে
                const Text("Payment Installments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                installments.isEmpty 
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(child: Text("No payment plan assigned yet.", style: TextStyle(color: Colors.grey))),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: installments.length,
                      itemBuilder: (context, index) {
                        return PaymentTile(
                          installment: installments[index],
                          onPay: installments[index].isPaid ? null : () => _handlePayment(installments[index]),
                        );
                      },
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}