import 'package:flutter/material.dart';
import '../student/student_model.dart';
import '../student/data_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<StudentModel> pendingStudents = [];

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  void _loadPending() {
    setState(() {
      pendingStudents = StudentDataService.getPendingStudents();
    });
  }

  void _approve(StudentModel student) {
    StudentDataService.updateStatus(student.id, 'approved');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${student.fullName} approved ✅'), backgroundColor: Colors.green),
    );
    _loadPending();
  }

  void _reject(StudentModel student) {
    StudentDataService.updateStatus(student.id, 'rejected');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${student.fullName} rejected ❌'), backgroundColor: Colors.red),
    );
    _loadPending();
  }

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
      body: pendingStudents.isEmpty
          ? const Center(child: Text('No pending applications'))
          : ListView.builder(
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
                          onPressed: () => _approve(student),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                          onPressed: () => _reject(student),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}