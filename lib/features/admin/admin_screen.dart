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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          title: const Text("Admin Control Center",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Column(
          children: [
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
                  _buildApprovedTab(), // এখানে পেমেন্ট বাটন যুক্ত করা হয়েছে
                  _buildPaymentTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

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
                subtitle: Text("Dept: ${data['department']}\nGPA: ${data['sscGpa']} | ${data['hscGpa']}"),
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

  // --- ২. এপ্রুভড স্টুডেন্ট ট্যাব (যেখানে পেমেন্ট বাটন যুক্ত করা হয়েছে) ---
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
            String studentUid = docs[index].id;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                leading: const Icon(Icons.account_circle, color: Colors.indigo),
                title: Text(data['fullName'] ?? 'No Name'),
                subtitle: Text("ID: ${data['digitalId'] ?? 'Processing'}"),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () async {
                    // পেমেন্ট কনফার্ম করার লজিক
                    try {
                      await _controller.makePayment(studentUid, 0); // ০ মানে ১ম কিস্তি
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Payment Approved Successfully!")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                  child: const Text("Pay", style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    color: Colors.grey[100],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("System Password: ${data['systemPassword'] ?? 'N/A'}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        Text("Email: ${data['email']}"),
                        Text("Dept: ${data['department']}"),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _service.deleteOrRejectStudent(studentUid),
                            icon: const Icon(Icons.person_remove, color: Colors.red, size: 18),
                            label: const Text("Remove", style: TextStyle(color: Colors.red)),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentTab() {
    return const Center(child: Text("Payment History & Records Coming Soon..."));
  }
}