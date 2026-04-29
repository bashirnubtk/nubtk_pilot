import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// সঠিক পাথ অনুযায়ী ইমপোর্ট নিশ্চিত করা হয়েছে
import 'digital_id_screen.dart';
import '../../payment/student_payment_list_screen.dart';
import '../../ai_bot/ai_bot_screen.dart'; // AI বটের নতুন ইমপোর্ট

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text("Student Portal"),
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
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        // অ্যাডমিন প্যানেল অনুযায়ী 'users' কালেকশন থেকেই ডাটা আসবে
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text("No student data found"));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ১. স্টুডেন্ট প্রোফাইল কার্ড (ডিজিটাল আইডি ও স্ট্যাটাসসহ)
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
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 50, color: Color(0xFF1A237E)),
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
                      // ডিজিটাল আইডি প্রদর্শন
                      Text(
                        "ID: ${data['digitalId'] ?? 'ID Generating...'}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      // স্ট্যাটাস প্রদর্শন (Approved কি না)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: data['approved'] == true ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data['approved'] == true ? "Status: Active" : "Status: Pending",
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: Colors.white24),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school, color: Colors.white70, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            data['department'] ?? 'Department N/A',
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),

                // ২. গ্রিড মেনু
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
                              builder: (context) => DigitalIdScreen(studentId: uid),
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
                            builder: (context) => const StudentPaymentListScreen(),
                          ),
                        );
                      },
                    ),
                    _buildFeatureCard(Icons.quiz_rounded, "CT & Quiz", Colors.orange, () {}),
                    _buildFeatureCard(Icons.video_library_rounded, "Class Video", Colors.red, () {}),
                    _buildFeatureCard(Icons.event_note_rounded, "Routine", Colors.indigo, () {}),
                    
                    // AI Assistant বাটন এখন সচল করা হয়েছে
                    _buildFeatureCard(
                      Icons.auto_awesome_rounded, 
                      "AI Assistant", 
                      Colors.purple, 
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AiBotScreen()),
                        );
                      }
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

  // মেনু কার্ড জেনারেটর ফাংশন
  Widget _buildFeatureCard(IconData icon, String title, Color color, VoidCallback onTap) {
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}