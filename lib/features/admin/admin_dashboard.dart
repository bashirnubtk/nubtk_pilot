import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_student_controller.dart';
import '../../models/analysis_result_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  final AdminStudentController controller = AdminStudentController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: "Student Approval"),
            Tab(icon: Icon(Icons.analytics), text: "AI Results"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ========== TAB 1: তোমার পুরানো Student Approve সিস্টেম - অক্ষত ==========
          _buildStudentApprovalTab(),

          // ========== TAB 2: নতুন AI Results Tab ==========
          _buildAIResultsTab(),
        ],
      ),
    );
  }

  // তোমার পুরানো কোড - কোনো চেঞ্জ নাই
  Widget _buildStudentApprovalTab() {
    return StreamBuilder<QuerySnapshot>(
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

            final String name = data['fullName']?? 'No Name';
            final String email = data['email']?? 'No Email';
            final bool isApproved = data['approved']?? false;
            final bool emailSent = data['emailSent']?? false;

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
                        _buildChip(isApproved? "Approved" : "Pending", isApproved? Colors.green : Colors.orange),
                        if (emailSent)...[
                          const SizedBox(width: 8),
                          const Icon(Icons.email_outlined, size: 14, color: Colors.blue),
                        ]
                      ],
                    ),
                  ],
                ),
                trailing:!isApproved
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
    );
  }

  // নতুন Tab: AI Analysis রেজাল্ট দেখাবে
  Widget _buildAIResultsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
        .collection('results')
        .orderBy('createdAt', descending: true)
        .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No analysis results yet'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            AnalysisResult result = AnalysisResult.fromJson(
              doc.data() as Map<String, dynamic>
            );

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: result.status == 'completed'
                  ? Colors.green
                    : Colors.orange,
                  child: Icon(
                    result.status == 'completed'? Icons.check : Icons.sync,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  'User: ${result.userId.substring(0, 8)}...',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Status: ${result.status} | Source: ${result.source}\n'
                  'Date: ${result.createdAt.day}/${result.createdAt.month}/${result.createdAt.year}',
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AI Analysis Data:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            result.aiData.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // তোমার পুরানো ফাংশন - কোনো চেঞ্জ নাই
  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}