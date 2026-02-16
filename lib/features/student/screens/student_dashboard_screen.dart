import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ইমপোর্ট পাথগুলো আপনার লোকেশন অনুযায়ী ফিক্সড
import 'digital_id_screen.dart'; 
import '../../ai_bot/ai_bot_screen.dart'; 
import '../../auth/login_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});
  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (uid == null) return const Scaffold(body: Center(child: Text("Login Required")));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('students').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) return const Center(child: Text("Profile not found"));
          
          final bool isApproved = data['approved'] ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTile(
                  "Digital ID", 
                  isApproved ? "Available" : "Pending", 
                  Icons.badge, 
                  Colors.blue, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => DigitalIdScreen(studentId: uid!)))
                ),
                const SizedBox(height: 10),
                _buildTile(
                  "AI Assistant", 
                  "Ready to help", 
                  Icons.android, 
                  Colors.purple, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiBotScreen()))
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTile(String t, String s, IconData i, Color c, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(i, color: c),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(s),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}