import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// সঠিক ইম্পোর্ট নিশ্চিত করা হলো
import '../admin/admin_dashboard.dart'; 
import '../student/screens/student_dashboard_screen.dart';
import '../home/home_screen.dart';
import 'waiting_approval_screen.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // স্ন্যাপশট লোড হওয়ার সময়
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // ইউজার লগইন করা না থাকলে হোম স্ক্রিনে পাঠাবে
        if (!snapshot.hasData) {
          return const HomeScreen();
        }

        final user = snapshot.data!;

        // প্রথমে 'students' কালেকশনে চেক করবে
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('students').doc(user.uid).get(),
          builder: (context, studentSnapshot) {
            if (studentSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            // যদি স্টুডেন্ট হিসেবে ডাটা পাওয়া যায়
            if (studentSnapshot.hasData && studentSnapshot.data!.exists) {
              final data = studentSnapshot.data!.data() as Map<String, dynamic>;
              final String status = data['status'] ?? 'pending';

              if (status == 'approved') {
                return const StudentDashboardScreen();
              } else {
                return const WaitingApprovalScreen();
              }
            }

            // যদি স্টুডেন্ট না হয়, তবে 'admins' কালেকশনে চেক করবে
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('admins').doc(user.uid).get(),
              builder: (context, adminSnapshot) {
                if (adminSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }

                if (adminSnapshot.hasData && adminSnapshot.data!.exists) {
                  // আপনার অ্যাডমিন ড্যাশবোর্ড স্ক্রিনটি এখানে রিটার্ন হবে
                  return const AdminDashboard(); 
                }

                // যদি কোনো কালেকশনেই ডাটা না পাওয়া যায়
                return const HomeScreen();
              },
            );
          },
        );
      },
    );
  }
}