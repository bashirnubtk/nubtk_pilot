import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("NUBTK Admin Panel"),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Admission"),
              Tab(text: "Payments"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAdmissionList(),
            const Center(child: Text("Payment Control Feature Coming Soon")),
          ],
        ),
      ),
    );
  }

  Widget _buildAdmissionList() {
    return StreamBuilder<QuerySnapshot>(
      // কালেকশন নাম 'students' এবং status 'pending' নিশ্চিত করা হয়েছে
      stream: FirebaseFirestore.instance
          .collection('students')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_search, size: 70, color: Colors.grey),
              Text("No Pending Applications Found", style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            var docId = snapshot.data!.docs[index].id;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              elevation: 3,
              child: ListTile(
                title: Text(data['fullName'] ?? "Unknown Student", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Dept: ${data['department']}\nGPA: SSC ${data['sscGpa']} | HSC ${data['hscGpa']}"),
                isThreeLine: true,
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => _approveStudent(context, docId),
                  child: const Text("Approve", style: TextStyle(color: Colors.white)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _approveStudent(BuildContext context, String id) async {
    await FirebaseFirestore.instance.collection('students').doc(id).update({
      'status': 'approved',
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Student Approved ✅")));
  }
}