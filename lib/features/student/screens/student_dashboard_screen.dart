// D:\projects\nubtk_pilot\lib\features\student\screens\student_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// আপনার প্রজেক্ট স্ট্রাকচার অনুযায়ী সঠিক ইমপোর্ট পাথ
import 'digital_id_screen.dart';
import '../../payment/student_payment_list_screen.dart';
import '../../ai_bot/ai_bot_screen.dart';
// নতুন রিসোর্স স্ক্রিনের ইমপোর্ট যুক্ত করা হলো
import 'student_resource_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // বর্তমান ইউজারের UID সংগ্রহ
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          "Student Portal",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((_) {
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        // ডাটাবেজ লজিক: 'students' কালেকশন থেকে ডাটা রিড করা হচ্ছে
        stream: FirebaseFirestore.instance
            .collection('students')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // প্রোফাইল ডাটা না থাকলে বা অ্যাডমিন অ্যাপ্রুভ না করলে এই ভিউ দেখাবে
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 60, color: Colors.orange[300]),
                  const SizedBox(height: 10),
                  const Text(
                    "Profile data not found.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const Text(
                    "Please wait for Admin Approval.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ১. স্টুডেন্ট প্রোফাইল কার্ড
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data['fullName'] ?? 'Student Name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "ID: ${data['studentId'] ?? data['digitalId'] ?? 'Generating...'}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: data['status'] == 'approved'
                              ? Colors.green.withOpacity(0.4)
                              : Colors.orange.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data['status'] == 'approved'
                              ? "Status: Active"
                              : "Status: Pending",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: Colors.white24),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.school,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            data['department'] ?? 'Dept: N/A',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                const Text(
                  "Quick Services",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // ২. গ্রিড মেনু (এখানে আমরা Necessary Resources কার্ডটি যোগ করেছি)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _buildFeatureCard(
                      Icons.badge_rounded,
                      "Digital ID",
                      Colors.blueAccent,
                      () {
                        if (uid != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DigitalIdScreen(studentId: uid),
                            ),
                          );
                        }
                      },
                    ),
                    _buildFeatureCard(
                      Icons.account_balance_wallet_rounded,
                      "Payments",
                      Colors.green,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const StudentPaymentListScreen(),
                          ),
                        );
                      },
                    ),
                    // Necessary Resources বাটনটি এখানে যুক্ত করা হলো
                    _buildFeatureCard(
                      Icons.library_books_rounded,
                      "Resources",
                      Colors.teal,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StudentResourceScreen(),
                          ),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      Icons.auto_awesome_rounded,
                      "AI Assistant",
                      Colors.purple,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AiBotScreen(),
                          ),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      Icons.quiz_rounded,
                      "CT & Quiz",
                      Colors.orange,
                      () {
                        _showComingSoon(context);
                      },
                    ),
                    _buildFeatureCard(
                      Icons.event_note_rounded,
                      "Routine",
                      Colors.indigo,
                      () {
                        _showComingSoon(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("This feature is coming soon!")),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
