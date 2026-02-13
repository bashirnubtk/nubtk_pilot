import 'package:flutter/material.dart';
import 'admin_data_service.dart';
import '../student/student_model.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text('Admission Requests', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Text('No pending applications', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingStudents.length,
            itemBuilder: (context, index) {
              final student = pendingStudents[index];
              return _buildStudentCard(context, student);
            },
          );
        },
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, StudentModel student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.indigo.shade50,
          backgroundImage: student.photoUrl.isNotEmpty ? NetworkImage(student.photoUrl) : null,
          child: student.photoUrl.isEmpty ? const Icon(Icons.person, color: Colors.indigo) : null,
        ),
        title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text('Dept: ${student.department}\nPhone: ${student.phone}', style: const TextStyle(height: 1.5)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionButton(Icons.check_circle, Colors.green, () => _showApproveDialog(context, student)),
            const SizedBox(width: 8),
            _actionButton(Icons.cancel, Colors.red, () => _handleAction(context, student, 'reject')),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withAlpha(30), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  void _showApproveDialog(BuildContext context, StudentModel student) {
    String selectedGrade = 'A+';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Select Student Grade"),
        content: DropdownButtonFormField<String>(
          value: selectedGrade,
          items: ['A+', 'A', 'A-', 'B', 'C'].map((g) => DropdownMenuItem(value: g, child: Text("Grade $g"))).toList(),
          onChanged: (val) => selectedGrade = val!,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleAction(context, student, 'approve', grade: selectedGrade);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Approve Student", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, StudentModel student, String action, {String? grade}) async {
    if (action == 'approve') {
      await AdminDataService.approveStudent(student.id, grade: grade ?? 'A+');
      if (!context.mounted) return;
      _showSnackBar(context, '${student.fullName} Approved ✅', Colors.green);
    } else {
      await AdminDataService.rejectStudent(student.id);
      if (!context.mounted) return;
      _showSnackBar(context, '${student.fullName} Rejected ❌', Colors.red);
    }
  }

  void _showSnackBar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }
}