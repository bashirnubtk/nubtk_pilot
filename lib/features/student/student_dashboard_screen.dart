import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'student_widgets/student_status_banner.dart';
import 'student_widgets/digital_id_card_preview.dart';
import 'student_widgets/student_menu_tile.dart';
import '../../features/auth/login_screen.dart'; 

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // বর্তমানে লগইন করা ইউজারের UID নেওয়া হচ্ছে
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          "Student Dashboard", 
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (_) => const LoginScreen())
              );
            },
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        // Firestore থেকে এই ইউজারের ডাটা রিয়েল-টাইম শোনা হচ্ছে
        stream: FirebaseFirestore.instance
            .collection('students')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Student record not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String status = data['status'] ?? 'pending';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // স্ট্যাটাস ব্যানার (Pending/Approved/Rejected দেখাবে)
                StudentStatusBanner(status: status),
                
                const SizedBox(height: 16),

                // আইডি কার্ড প্রিভিউ (শুধুমাত্র Approved হলে দেখাবে)
                DigitalIdCardPreview(
                  name: data['fullName'] ?? 'N/A',
                  department: data['department'] ?? 'N/A',
                  digitalId: data['digitalId'] ?? 'N/A',
                  status: status,
                ),

                const SizedBox(height: 24),

                // মেনু আইটেমগুলো
                StudentMenuTile(
                  icon: Icons.badge,
                  title: "Digital ID",
                  locked: status != 'approved', 
                  onTap: () {
                    // পরবর্তী ধাপে আমরা এখানে DigitalIdScreen যোগ করব
                  },
                ),

                StudentMenuTile(
                  icon: Icons.smart_toy,
                  title: "AI Assistant",
                  locked: true,
                  onTap: () {},
                ),

                StudentMenuTile(
                  icon: Icons.payment,
                  title: "Payments",
                  locked: true,
                  onTap: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}