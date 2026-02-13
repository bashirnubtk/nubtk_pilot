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
                        onPressed: () => _showApproveDialog(context, student),
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

  // অ্যাপ্রুভ করার আগে গ্রেড সিলেক্ট করার ডায়ালগ
  void _showApproveDialog(BuildContext context, StudentModel student) {
    String selectedGrade = 'A+'; // ডিফল্ট গ্রেড
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Student Grade"),
        content: DropdownButtonFormField<String>(
          value: selectedGrade,
          items: ['A+', 'A', 'A-', 'B', 'C'].map((g) => DropdownMenuItem(value: g, child: Text("Grade $g"))).toList(),
          onChanged: (val) => selectedGrade = val!,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleAction(context, student, 'approve', grade: selectedGrade);
            },
            child: const Text("Approve"),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, StudentModel student, String action, {String? grade}) async {
    if (action == 'approve') {
      // এখানে grade প্যারামিটারটি পাঠানো হচ্ছে যা এরর দূর করবে
      await AdminDataService.approveStudent(student.id, grade: grade ?? 'A+');
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