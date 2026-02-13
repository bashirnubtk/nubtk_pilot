import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin/admin_screen.dart'; // আপনার আগের ফাইলের নাম AdminScreen ছিল
import '../student/student_dashboard_screen.dart';
import '../home/home_screen.dart';
import 'waiting_approval_screen.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // লগইন না থাকলে হোম স্ক্রিন
        if (!snapshot.hasData) {
          return const HomeScreen();
        }

        final user = snapshot.data!;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('students').doc(user.uid).get(),
          builder: (context, studentSnapshot) {
            if (studentSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (studentSnapshot.hasData && studentSnapshot.data!.exists) {
              final data = studentSnapshot.data!.data() as Map<String, dynamic>;
              
              // চ্যাটজিপিটির কনফিউশন ফিক্স: 
              // আপনার ডাটাবেসে 'status' ফিল্ড আছে, তাই আমরা status ই চেক করবো।
              final String status = data['status'] ?? 'pending';

              if (status == 'approved') {
                return const StudentDashboardScreen();
              } else {
                return const WaitingApprovalScreen();
              }
            }

            // যদি স্টুডেন্ট না হয়, তবে এডমিন কি না চেক
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('admins').doc(user.uid).get(),
              builder: (context, adminSnapshot) {
                if (adminSnapshot.hasData && adminSnapshot.data!.exists) {
                  return const AdminScreen(); // আপনার এডমিন প্যানেল
                }
                return const HomeScreen();
              },
            );
          },
        );
      },
    );
  }
}