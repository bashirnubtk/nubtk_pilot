//C:\projects\Flutter project\nubtk_pilot\lib\features\admin\admin_payment_approval_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_student_controller.dart'; // নিশ্চিত করুন এই পাথটি সঠিক

class AdminPaymentApprovalScreen extends StatelessWidget {
  const AdminPaymentApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // কন্ট্রোলারটি ইনিশিয়ালাইজ করা হলো
    final AdminStudentController controller = AdminStudentController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Approvals"),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // আমরা 'students' কালেকশন থেকে ডাটা নিচ্ছি
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No students found."));
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String docId = docs[index].id;
              
              // চেক করা হচ্ছে স্টুডেন্ট অলরেডি অ্যাপ্রুভড কি না
              bool isApproved = data['approved'] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    data['fullName'] ?? 'Unknown Student',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(isApproved ? "Status: Approved" : "Status: Pending"),
                  trailing: ElevatedButton(
                    // বাটন লজিক: 
                    // যদি isApproved true হয়, তবে onPressed হবে null (যা বাটনকে disable করে দেয়)
                    onPressed: isApproved 
                      ? null 
                      : () async {
                          // এপ্রুভ ফাংশন কল করা
                          await controller.approveStudent(
                            docId: docId,
                            data: data,
                          );
                          
                          // সফল হলে একটি মেসেজ দেখানো
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${data['fullName']} has been approved!")),
                            );
                          }
                        },
                    style: ElevatedButton.styleFrom(
                      // বাটন এপ্রুভড হলে ধূসর (Grey), নাহলে সবুজ (Green)
                      backgroundColor: isApproved ? Colors.grey : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isApproved ? "Approved" : "Approve"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}