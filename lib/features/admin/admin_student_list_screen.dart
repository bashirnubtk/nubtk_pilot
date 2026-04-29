// C:\projects\Flutter project\nubtk_pilot\lib\features\admin\admin_student_list_screen.dart
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Admission Requests", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            // আপডেট অনুযায়ী: 'students' কালেকশন এবং 'pending' স্ট্যাটাস চেক করা হচ্ছে
            stream: FirebaseFirestore.instance
                .collection('students')
                .where('status', isEqualTo: 'pending') 
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 60, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("No pending requests found.", style: TextStyle(color: Colors.grey)),
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
                          Text("Email: ${data['email'] ?? 'N/A'}"),
                          Text("Phone: ${data['phone'] ?? 'N/A'}"),
                          Text(
                            "HSC GPA: ${data['hscGpa'] ?? '0.0'}", 
                            style: TextStyle(color: Colors.indigo[700], fontWeight: FontWeight.w600)
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green, size: 32),
                            onPressed: _isProcessing ? null : () => _handleApprove(docId, data),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red, size: 32),
                            onPressed: _isProcessing ? null : () => _showRejectDialog(context, docId),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          
          // প্রসেসিং চলার সময় লোডিং ইন্ডিকেটর
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // এপ্রুভাল হ্যান্ডেলার (আপনার কন্ট্রোলারের approveStudent ফাংশনটি ব্যবহার করা হয়েছে)
  void _handleApprove(String docId, Map<String, dynamic> data) async {
    setState(() => _isProcessing = true);
    try {
      await controller.approveStudent(
        docId: docId,
        data: data,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Success: Student Approved & Email Sent!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Process Failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // রিজেক্ট বা ডিলিট করার ডায়ালগ
  void _showRejectDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Reject Request?"),
        content: const Text("This will permanently delete the admission request."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Go Back")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isProcessing = true);
              try {
                // সরাসরি 'students' কালেকশন থেকে ডাটা ডিলিট করা হবে
                await FirebaseFirestore.instance.collection('students').doc(docId).delete();
              } finally {
                if (mounted) setState(() => _isProcessing = false);
              }
            },
            child: const Text("Reject Now", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}