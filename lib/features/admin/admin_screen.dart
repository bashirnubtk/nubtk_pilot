import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_data_service.dart';
// হোম স্ক্রিন ইমপোর্ট করা হলো যাতে ব্যাক বাটন কাজ করে
import '../home/home_screen.dart'; 

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  static final AdminDataService _service = AdminDataService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          elevation: 2,
          centerTitle: true,
          // ব্যাক বাটন ফিক্স: এখন এটি হোম স্ক্রিনে নিয়ে যাবে
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
          title: const Text(
            "NUBTK Admin Panel",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.person_add), text: "Admission"),
              Tab(icon: Icon(Icons.payments), text: "Payments"),
            ],
          ),
        ),
        body: Container(
          color: const Color(0xFFF4F7FA),
          child: TabBarView(
            children: [
              _buildAdmissionTab(context),
              _buildPaymentTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdmissionTab(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _service.getPendingStudents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No Pending Applications"));

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                title: Text(data['fullName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Dept: ${data['department']}"),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await _service.approveStudent(doc.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Approved ✅")));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Approve", style: TextStyle(color: Colors.white)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _service.getApprovedStudents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No Approved Students"));

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(data['fullName'] ?? 'Unknown'),
                subtitle: Text("ID: ${data['digitalId']}"),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            );
          },
        );
      },
    );
  }
}