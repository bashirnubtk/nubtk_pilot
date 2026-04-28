import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_student_controller.dart';

class AdminPaymentApprovalScreen extends StatelessWidget {
  const AdminPaymentApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminStudentController controller = AdminStudentController();
    return Scaffold(
      appBar: AppBar(title: const Text("Approve Payments")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').where('approved', isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['fullName']),
                subtitle: Text("ID: ${data['digitalId']}"),
                trailing: ElevatedButton(
                  onPressed: () => controller.makePayment(docs[index].id, 0),
                  child: const Text("Confirm Pay"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}