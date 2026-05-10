//D:\projects\nubtk_pilot\lib\features\admin\admin_screen.dart
import 'package:flutter/material.dart';
import 'package:nubtk_pilot/features/ai_bot/ai_bot_screen.dart'; // 🔥 এই লাইন অ্যাড করো
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🔥 ক্যাশ ক্লিয়ার এর জন্য অ্যাড করলাম

// সঠিক পাথ অনুযায়ী ইমপোর্ট নিশ্চিত করা হয়েছে
import 'admin_payment_approval_screen.dart'; // পেমেন্ট এপ্রুভাল স্ক্রিন
import 'admin_student_list_screen.dart'; // স্টুডেন্ট লিস্ট স্ক্রিন
// AI বট স্ক্রিন
import 'admin_add_resource.dart'; // নতুন তৈরি করা অ্যাড রিসোর্স স্ক্রিন

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // লগআউট ফাংশন যা নেভিগেশন স্ট্যাক ক্লিয়ার করবে
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 🔥 ক্যাশ ক্লিয়ার - এটাই গেস্ট-এডমিন গুলানোর সমাধান
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
            // উপরের হেডার অংশ
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
                      fontWeight: FontWeight.bold,
                    ),
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

            // মেনু গ্রিড
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  // ১. স্টুডেন্ট লিস্ট
                  _buildMenuCard(
                    context,
                    Icons.people,
                    "Student List",
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminStudentListScreen(),
                        ),
                      );
                    },
                  ),

                  // ২. পেমেন্ট এপ্রুভাল
                  _buildMenuCard(
                    context,
                    Icons.payment,
                    "Approve Payment",
                    Colors.green,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AdminPaymentApprovalScreen(),
                        ),
                      );
                    },
                  ),

                  // ৩. কুইজ ও সিটি তৈরি
                  _buildMenuCard(
                    context,
                    Icons.quiz,
                    "Create Quiz & CT",
                    Colors.orange,
                    () {
                      // ভবিষ্যতে পেজ যুক্ত করার জন্য
                      _showInfo(context);
                    },
                  ),

                  // ৪. নতুন বাটন: অ্যাড রিসোর্স (এখানেই আমরা লিঙ্ক যুক্ত করার সুযোগ দিচ্ছি)
                  _buildMenuCard(
                    context,
                    Icons.link_rounded,
                    "Add Resources",
                    Colors.red,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminAddResource(),
                        ),
                      );
                    },
                  ),

                  // ৫. AI অ্যাসিস্ট্যান্ট
                  _buildMenuCard(
                    context,
                    Icons.auto_awesome,
                    "AI Assistant",
                    Colors.purple,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AiBotScreen(isGuestMode: false), // 🔥 এডমিন থেকে গেলে isGuestMode: false
                        ),
                      );
                    },
                  ),

                  // ৬. তথ্য আপডেট
                  _buildMenuCard(
                    context,
                    Icons.update,
                    "Update Info",
                    Colors.teal,
                    () {
                      _showInfo(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ইনফো দেখানোর জন্য ছোট ফাংশন
  void _showInfo(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Working on this feature...")));
  }

  // মেনু কার্ড উইজেট
  Widget _buildMenuCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
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