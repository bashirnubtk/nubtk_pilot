import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'digital_id_screen.dart';
import '../../payment/student_payment_list_screen.dart';
import '../../ai_bot/ai_bot_screen.dart';
import '../../ai_bot/ai_logic_center.dart';
import 'student_resource_screen.dart';
import '../../../models/analysis_result_model.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final AILogicCenter _aiLogic = AILogicCenter(); // ← I বড় হাতের, AILogicCenter
  bool _isUploading = false;

  Future<void> _uploadForAnalysis() async {
    setState(() => _isUploading = true);
    String message = await _aiLogic.pickImageAndAnalyzeWithPython();
    setState(() => _isUploading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.contains("Success")? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          "Student Portal",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((_) {
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('students').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 60, color: Colors.orange[300]),
                  const SizedBox(height: 10),
                  const Text("Profile data not found.", style: TextStyle(fontSize: 16)),
                  const Text("Please wait for Admin Approval.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 50, color: Color(0xFF1A237E)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data['fullName']?? 'Student Name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "ID: ${data['studentId']?? data['digitalId']?? 'Generating...'}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: data['status'] == 'approved'
                            ? Colors.green.withOpacity(0.4)
                              : Colors.orange.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data['status'] == 'approved'? "Status: Active" : "Status: Pending",
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: Colors.white24),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school, color: Colors.white70, size: 16),
                          const SizedBox(width: 5),
                          Text(data['department']?? 'Dept: N/A', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.purple.shade100),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "AI Image Analysis",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Upload image for instant AI analysis",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _isUploading? null : _uploadForAnalysis,
                        icon: _isUploading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.cloud_upload),
                        label: Text(_isUploading? 'Analyzing...' : 'Upload & Analyze'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                const Text("Quick Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _buildFeatureCard(Icons.badge_rounded, "Digital ID", Colors.blueAccent, () {
                      if (uid!= null) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DigitalIdScreen(studentId: uid)));
                      }
                    }),
                    _buildFeatureCard(Icons.account_balance_wallet_rounded, "Payments", Colors.green, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentPaymentListScreen()));
                    }),
                    _buildFeatureCard(Icons.library_books_rounded, "Resources", Colors.teal, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentResourceScreen()));
                    }),
                    _buildFeatureCard(Icons.auto_awesome_rounded, "AI Assistant", Colors.purple, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AiBotScreen()));
                    }),
                    _buildFeatureCard(Icons.quiz_rounded, "CT & Quiz", Colors.orange, () => _showComingSoon(context)),
                    _buildFeatureCard(Icons.event_note_rounded, "Routine", Colors.indigo, () => _showComingSoon(context)),
                  ],
                ),

                const SizedBox(height: 25),

                const Text("My Analysis Results", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildMyResultsList(uid),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyResultsList(String? uid) {
    if (uid == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
        .collection('results')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Text('No analysis yet. Upload an image above.', style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            AnalysisResult result = AnalysisResult.fromJson(doc.data() as Map<String, dynamic>);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: result.status == 'completed'? Colors.green : Colors.orange,
                  child: Icon(result.status == 'completed'? Icons.done : Icons.sync, color: Colors.white, size: 20),
                ),
                title: Text('Analysis #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${result.createdAt.day}/${result.createdAt.month}/${result.createdAt.year} • ${result.status}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Analysis Details'),
                      content: SingleChildScrollView(
                        child: Text(result.aiData.toString()),
                      ),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("This feature is coming soon!")));
  }

  Widget _buildFeatureCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}