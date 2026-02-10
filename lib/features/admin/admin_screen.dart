import 'package:flutter/material.dart';
import 'admin_data_service.dart';
import '../student/student_model.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Admission Requests', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      // StreamBuilder ব্যবহার করা হয়েছে যাতে ডাটাবেজ চেঞ্জ হলে অ্যাপ অটো আপডেট হয়
      body: StreamBuilder<List<StudentModel>>(
        stream: AdminDataService.getPendingStudentsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final pendingStudents = snapshot.data ?? [];

          if (pendingStudents.isEmpty) {
            return const Center(child: Text('No pending applications'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pendingStudents.length,
            itemBuilder: (context, index) {
              final student = pendingStudents[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.indigo.shade50,
                    child: const Icon(Icons.person, color: Colors.indigo),
                  ),
                  title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dept: ${student.department}'),
                      Text('Phone: ${student.phone}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                        onPressed: () => _handleAction(context, student, 'approve'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                        onPressed: () => _handleAction(context, student, 'reject'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // অ্যাকশন হ্যান্ডেল করার জন্য একটি ছোট হেল্পার ফাংশন
  void _handleAction(BuildContext context, StudentModel student, String action) async {
    if (action == 'approve') {
      await AdminDataService.approveStudent(student.id);
      if (!context.mounted) return;
      _showSnackBar(context, '${student.fullName} approved ✅', Colors.green);
    } else {
      await AdminDataService.rejectStudent(student.id);
      if (!context.mounted) return;
      _showSnackBar(context, '${student.fullName} rejected ❌', Colors.red);
    }
  }

  void _showSnackBar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2)),
    );
  }
}