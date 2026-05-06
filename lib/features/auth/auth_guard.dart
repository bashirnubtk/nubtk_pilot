//D:\projects\nubtk_pilot\lib\features\auth\auth_guard.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// আপনার প্রোজেক্টের সঠিক পাথ অনুযায়ী ইম্পোর্ট
import '../admin/admin_screen.dart'; // এখানে AdminDashboard ক্লাসটি আছে
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
        // লোডিং স্টেট
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ইউজার লগইন না থাকলে হোমে নিয়ে যাবে
        if (!snapshot.hasData || snapshot.data == null) {
          return const HomeScreen();
        }

        final user = snapshot.data!;

        // ইউজার আইডি দিয়ে Firestore থেকে চেক করা
        return FutureBuilder<DocumentSnapshot>(
          // প্রথমে 'students' কালেকশন চেক করবে
          future: FirebaseFirestore.instance
              .collection('students')
              .doc(user.uid)
              .get(),
          builder: (context, studentSnapshot) {
            if (studentSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // যদি স্টুডেন্ট হিসেবে পাওয়া যায়
            if (studentSnapshot.hasData && studentSnapshot.data!.exists) {
              final data = studentSnapshot.data!.data() as Map<String, dynamic>;
              final String status = data['status'] ?? 'pending';

              if (status == 'approved') {
                return const StudentDashboardScreen();
              } else {
                return const WaitingApprovalScreen();
              }
            }

            // স্টুডেন্ট না হলে 'admins' কালেকশন চেক করবে
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('admins')
                  .doc(user.uid)
                  .get(),
              builder: (context, adminSnapshot) {
                if (adminSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                // যদি অ্যাডমিন হিসেবে পাওয়া যায়
                if (adminSnapshot.hasData && adminSnapshot.data!.exists) {
                  return const AdminDashboard();
                }

                // কোনো লিস্টেই না থাকলে (নতুন ইউজার)
                return const HomeScreen();
              },
            );
          },
        );
      },
    );
  }
}
