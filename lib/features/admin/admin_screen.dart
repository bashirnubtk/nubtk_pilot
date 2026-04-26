import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_data_service.dart';
import 'admin_student_controller.dart';
import '../home/home_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminDataService _service = AdminDataService();
  final AdminStudentController _controller = AdminStudentController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          backgroundColor: Colors.indigo[900],
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              // এখানে শুধু pushReplacement ব্যবহার করুন যাতে হোমপেজ থেকে আবার ব্যাকে গেলে অ্যাপ বন্ধ না হয়
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          title: const Text("Admin Control Center", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // --- ৩টি স্ট্যাটাস বক্স (Visual Dashboard) ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.indigo[900],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatIcon(Icons.hourglass_empty, "Pending", Colors.orangeAccent),
                  _buildStatIcon(Icons.verified_user, "Approved", Colors.greenAccent),
                  _buildStatIcon(Icons.monetization_on, "Payments", Colors.blueAccent),
                ],
              ),
            ),
            
            const TabBar(
              labelColor: Colors.indigo,
              unselectedLabelColor: Colors.grey,
              indicatorWeight: 3,
              tabs: [
                Tab(text: "Admission"),
                Tab(text: "Students"),
                Tab(text: "Fees"),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [
                  _buildAdmissionTab(),
                  _buildApprovedTab(),
                  _buildPaymentTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // স্ট্যাটাস আইকন উইজেট
  Widget _buildStatIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white.withValues(alpha:0.2),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  // ১. এডমিশন ট্যাব (Approve & Reject বাটনসহ)
  Widget _buildAdmissionTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _service.getPendingStudents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text("No new requests"));

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                title: Text(data['fullName'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Dept: ${data['department']}\nGPA: ${data['sscGpa']} (S) | ${data['hscGpa']} (H)"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _service.deleteOrRejectStudent(docs[index].id),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () => _controller.approveAndSendEmail(
                        studentId: docs[index].id,
                        name: data['fullName'],
                        email: data['email'],
                      ),
                      child: const Text("Approve", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ২. এপ্রুভড স্টুডেন্ট ট্যাব (আইডি-পাসওয়ার্ডসহ সব ডিটেইলস)
  Widget _buildApprovedTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _service.getApprovedStudents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return ExpansionTile(
              leading: const Icon(Icons.account_circle, color: Colors.indigo),
              title: Text(data['fullName'] ?? ''),
              subtitle: Text("ID: ${data['digitalId'] ?? 'Processing'}"),
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  color: Colors.grey[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("System Password: ${data['systemPassword'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      Text("Email: ${data['email']}"),
                      Text("SSC GPA: ${data['sscGpa']} | HSC GPA: ${data['hscGpa']}"),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _service.deleteOrRejectStudent(docs[index].id),
                          icon: const Icon(Icons.person_remove, color: Colors.red, size: 18),
                          label: const Text("Remove Student", style: TextStyle(color: Colors.red)),
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  // ৩. পেমেন্ট ট্যাব (ভবিষ্যতের জন্য রাখা হয়েছে)
  Widget _buildPaymentTab() {
    return const Center(child: Text("Payment History & Records Coming Soon..."));
  }
}