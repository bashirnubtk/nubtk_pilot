import 'package:flutter/material.dart';
import '../student/student_model.dart';
import 'admin_data_service.dart'; // নতুন সার্ভিস ইমপোর্ট

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<StudentModel> pendingStudents = [];
  bool isLoading = true; // ডাটা লোড হচ্ছে কি না দেখার জন্য

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  // ডাটাবেজ থেকে রিয়েল ডাটা আনা
  Future<void> _loadPending() async {
    setState(() => isLoading = true);
    final data = await AdminDataService.getPendingStudents();
    setState(() {
      pendingStudents = data;
      isLoading = false;
    });
  }

  // অনুমোদন করা
  Future<void> _approve(StudentModel student) async {
    await AdminDataService.updateStatus(student.id, 'approved');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${student.fullName} approved ✅'), backgroundColor: Colors.green),
    );
    _loadPending(); // লিস্ট রিফ্রেশ করা
  }

  // রিজেক্ট করা
  Future<void> _reject(StudentModel student) async {
    await AdminDataService.updateStatus(student.id, 'rejected');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${student.fullName} rejected ❌'), backgroundColor: Colors.red),
    );
    _loadPending(); // লিস্ট রিফ্রেশ করা
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
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) // লোডিং স্পিনার
          : pendingStudents.isEmpty
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