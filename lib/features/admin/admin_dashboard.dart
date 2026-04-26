import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_student_controller.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminStudentController controller = AdminStudentController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final students = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final studentDoc = students[index];
              final data = studentDoc.data() as Map<String, dynamic>;
              
              final String name = data['fullName'] ?? 'No Name';
              final String email = data['email'] ?? 'No Email';
              final bool isApproved = data['approved'] ?? false;
              final bool emailSent = data['emailSent'] ?? false;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildChip(isApproved ? "Approved" : "Pending", isApproved ? Colors.green : Colors.orange),
                          if (emailSent) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.email_outlined, size: 14, color: Colors.blue),
                          ]
                        ],
                      ),
                    ],
                  ),
                  trailing: !isApproved
                      ? IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 30),
                          onPressed: () async {
                            try {
                              await controller.approveAndSendEmail(
                                studentId: studentDoc.id,
                                name: name,
                                email: email,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Success!")));
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                              }
                            }
                          },
                        )
                      : const Icon(Icons.verified, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}