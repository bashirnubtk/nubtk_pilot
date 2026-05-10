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

        // 🔥 ফিক্স: প্রথমে users কালেকশন চেক করো
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // users কালেকশনে না পেলে HomeScreen
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const HomeScreen();
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final String role = userData['role'] ?? 'student';

            // রোল অনুযায়ী রিডাইরেক্ট
            if (role == 'admin') {
              return const AdminDashboard();
            } else if (role == 'student') {
              // স্টুডেন্ট হলে students কালেকশন থেকে status চেক করো
              return FutureBuilder<DocumentSnapshot>(
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

                  if (studentSnapshot.hasData && studentSnapshot.data!.exists) {
                    final data = studentSnapshot.data!.data() as Map<String, dynamic>;
                    final String status = data['status'] ?? 'pending';

                    if (status == 'approved') {
                      return const StudentDashboardScreen();
                    } else {
                      return const WaitingApprovalScreen();
                    }
                  } else {
                    // students কালেকশনে না থাকলে Waiting
                    return const WaitingApprovalScreen();
                  }
                },
              );
            } else {
              return const HomeScreen();
            }
          },
        );
      },
    );
  }
}