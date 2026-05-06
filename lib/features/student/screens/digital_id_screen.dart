// D:\projects\nubtk_pilot\lib\features\student\screens\digital_id_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../student_services/digital_id_pdf_service.dart';

class DigitalIdScreen extends StatelessWidget {
  final String studentId; // এটি মূলত Firebase User UID
  const DigitalIdScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Official Digital ID"),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        // ফিক্স: 'users' এর বদলে 'students' কালেকশন থেকে ডাটা নিতে হবে
        future: FirebaseFirestore.instance
            .collection('students')
            .doc(studentId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(
              child: Text("No student data found. Contact Admin."),
            );
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          // ডাটা ম্যাপ করা
          String name = data['fullName'] ?? 'N/A';
          String dept = data['department'] ?? 'N/A';
          // অরিজিনাল স্টুডেন্ট আইডি অথবা ডিজিটাল আইডি ব্যাকআপ হিসেবে
          String displayId =
              data['studentId'] ?? data['digitalId'] ?? 'Generating...';

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 320,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.indigo[900],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.qr_code_2_rounded,
                        size: 140,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        dept,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(color: Colors.white24),
                      const SizedBox(height: 10),
                      Text(
                        "STUDENT ID: $displayId",
                        style: const TextStyle(
                          color: Colors.white,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    if (displayId != 'Generating...') {
                      DigitalIdPdfService.generateAndDownload(
                        name: name,
                        department: dept,
                        digitalId: displayId,
                      );
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Download Digital ID Card"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
