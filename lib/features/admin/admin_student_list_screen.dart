import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_student_controller.dart';

class AdminStudentListScreen extends StatelessWidget {
  const AdminStudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminStudentController controller = AdminStudentController();
    return Scaffold(
      appBar: AppBar(title: const Text("Student Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').where('approved', isEqualTo: false).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['fullName'] ?? 'User'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.check, color: Colors.green), 
                      onPressed: () => controller.approveAndSendEmail(studentId: docs[index].id, name: data['fullName'], email: data['email'])),
                    IconButton(icon: const Icon(Icons.close, color: Colors.red), 
                      onPressed: () => FirebaseFirestore.instance.collection('students').doc(docs[index].id).delete()),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}