import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin/admin_screen.dart';
import '../student/student_dashboard_screen.dart';
import '../home/home_screen.dart'; // লগইন না থাকলে হোম স্ক্রিনে পাঠাবে

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ১. চেক করা হচ্ছে ইউজার লগইন আছে কি না
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData) {
          // লগইন নেই, তাই হোম স্ক্রিনে পাঠান
          return const HomeScreen(); 
        }

        final user = snapshot.data!;

        // ২. ইউজারের রোল এবং স্ট্যাটাস চেক করা
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('students').doc(user.uid).get(),
          builder: (context, studentSnapshot) {
            if (studentSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            // যদি স্টুডেন্ট কালেকশনে পাওয়া যায়
            if (studentSnapshot.hasData && studentSnapshot.data!.exists) {
              final data = studentSnapshot.data!.data() as Map<String, dynamic>;
              final String status = data['status'] ?? 'pending';

              if (status == 'approved') {
                return const StudentDashboardScreen();
              } else {
                return _buildApprovalPendingScreen(context, status);
              }
            }

            // যদি স্টুডেন্ট না হয়, তবে এডমিন কি না চেক
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('admins').doc(user.uid).get(),
              builder: (context, adminSnapshot) {
                if (adminSnapshot.hasData && adminSnapshot.data!.exists) {
                  return const AdminScreen();
                }
                return const HomeScreen(); // কোনো কিছু না মিললে হোম স্ক্রিন
              },
            );
          },
        );
      },
    );
  }

  // পেন্ডিং বা রিজেক্টেড ইউজারদের জন্য স্ক্রিন
  Widget _buildApprovalPendingScreen(BuildContext context, String status) {
    bool isRejected = status == 'rejected';
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isRejected ? Icons.cancel_outlined : Icons.hourglass_empty_rounded,
                size: 80,
                color: isRejected ? Colors.red : Colors.orange,
              ),
              const SizedBox(height: 20),
              Text(
                isRejected ? "Admission Rejected" : "Pending Approval",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                isRejected 
                  ? "Sorry, your request was not accepted. Please contact the registrar office." 
                  : "Thank you for applying! Your request is under review. You will get access once approved.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}