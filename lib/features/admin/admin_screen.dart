import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// সঠিক পাথ অনুযায়ী ইমপোর্ট নিশ্চিত করুন
import '../home/home_screen.dart';
import '../ai_bot/ai_bot_screen.dart';
import 'admin_student_list_screen.dart'; // স্টুডেন্ট লিস্ট স্ক্রিন
import 'admin_payment_approval_screen.dart'; // পেমেন্ট এপ্রুভাল স্ক্রিন

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  
  // লগআউট ফাংশন যা নেভিগেশন জট ক্লিয়ার করবে
  void _logout() {
    FirebaseAuth.instance.signOut().then((_) {
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
        elevation: 0,
        title: const Text(
          "Admin Control Center",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // উপরের নীল অংশ (Header)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.indigo[900],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, Admin",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Manage your university system effectively",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // মেনু গ্রিড (Grid Menu)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  // ধাপ ১: স্টুডেন্ট লিস্ট নেভিগেশন আপডেট
                  _buildMenuCard(context, Icons.people, "Student List", Colors.blue, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminStudentListScreen()),
                    );
                  }),

                  // ধাপ ২: পেমেন্ট এপ্রুভাল নেভিগেশন আপডেট
                  _buildMenuCard(context, Icons.payment, "Create Payment", Colors.green, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminPaymentApprovalScreen()),
                    );
                  }),

                  _buildMenuCard(context, Icons.quiz, "Create Quiz & CT", Colors.orange, () {
                    // কুইজ পেজের কোড (ভবিষ্যত আপডেটের জন্য)
                  }),
                  
                  _buildMenuCard(context, Icons.video_library, "Gift Class", Colors.red, () {
                    // ক্লাস গিফট করার পেজ
                  }),

                  _buildMenuCard(context, Icons.auto_awesome, "AI Assistant", Colors.purple, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AiBotScreen()),
                    );
                  }),

                  _buildMenuCard(context, Icons.update, "Update Info", Colors.teal, () {
                    // আপডেট পেজ
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // মেনু কার্ড বানানোর উইজেট
  Widget _buildMenuCard(BuildContext context, IconData icon, String title,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}