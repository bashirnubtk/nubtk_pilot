//D:\projects\nubtk_pilot\lib\features\admin\admin_student_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_student_controller.dart';

class AdminStudentListScreen extends StatefulWidget {
  const AdminStudentListScreen({super.key});

  @override
  State<AdminStudentListScreen> createState() => _AdminStudentListScreenState();
}

class _AdminStudentListScreenState extends State<AdminStudentListScreen> {
  final AdminStudentController controller = AdminStudentController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // দুটি ট্যাব: ১. পেন্ডিং রিকোয়েস্ট, ২. সব স্টুডেন্ট (Approved)
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text("Student Management", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.indigo[900],
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Admission Requests", icon: Icon(Icons.pending_actions)),
              Tab(text: "Approved Students", icon: Icon(Icons.people_alt)),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                _buildStudentList('pending'),   // প্রথম ট্যাব: পেন্ডিং লিস্ট
                _buildStudentList('approved'),  // দ্বিতীয় ট্যাব: এপ্রুভড লিস্ট (পার্মানেন্ট)
              ],
            ),
            if (_isProcessing)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  // লজিক ঠিক রেখে লিস্ট বিল্ডার ফাংশন
  Widget _buildStudentList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(status == 'pending' ? Icons.person_off : Icons.group_off, size: 60, color: Colors.grey),
                const SizedBox(height: 10),
                Text("No $status students found.", style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        var docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            String docId = docs[index].id;

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  data['fullName'] ?? 'No Name',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text("ID: ${data['studentId'] ?? 'N/A'}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    Text("Email: ${data['email'] ?? 'N/A'}"),
                    Text("Phone: ${data['phone'] ?? 'N/A'}"),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status == 'pending') ...[
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                        onPressed: _isProcessing ? null : () => _handleApprove(docId, data),
                      ),
                    ],
                    // রিমুভ বাটন (উভয় লিস্টের জন্যই কাজ করবে)
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red, size: 30),
                      onPressed: _isProcessing ? null : () => _showRemoveDialog(context, docId),
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

  void _handleApprove(String docId, Map<String, dynamic> data) async {
    setState(() => _isProcessing = true);
    try {
      await controller.approveStudent(docId: docId, data: data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Student Approved & Moved to List!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // চিরতরে মুছে ফেলার লজিক (Remove Button)
  void _showRemoveDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Student?"),
        content: const Text("This will permanently delete this student record from everywhere."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isProcessing = true);
              try {
                // স্টুডেন্টস কালেকশন থেকে রিমুভ
                await FirebaseFirestore.instance.collection('students').doc(docId).delete();
                // ইউজার কালেকশন থেকেও রিমুভ (অপ্রুভড হলে)
                await FirebaseFirestore.instance.collection('users').doc(docId).delete().catchError((_){});
              } finally {
                if (mounted) setState(() => _isProcessing = false);
              }
            },
            child: const Text("Remove", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

}