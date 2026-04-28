import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../student_services/digital_id_pdf_service.dart';

class DigitalIdScreen extends StatelessWidget {
  final String studentId;
  const DigitalIdScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Official Digital ID")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(studentId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var data = snapshot.data!.data() as Map<String, dynamic>;
          
          String name = data['fullName'] ?? 'N/A';
          String dept = data['department'] ?? 'CSE';
          String dId = data['digitalId'] ?? 'N/A';

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // আইডি কার্ডের ভিজ্যুয়াল ডিজাইন
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.indigo[900],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.qr_code_2, size: 150, color: Colors.white),
                      const SizedBox(height: 15),
                      Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(dept, style: const TextStyle(color: Colors.white70)),
                      Text("ID: $dId", style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // আপনার বানানো PDF সার্ভিসটি এখানে কল করা হচ্ছে
                ElevatedButton.icon(
                  onPressed: () => DigitalIdPdfService.generateAndDownload(
                    name: name,
                    department: dept,
                    digitalId: dId,
                  ),
                  icon: const Icon(Icons.download),
                  label: const Text("Download PDF ID Card"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}