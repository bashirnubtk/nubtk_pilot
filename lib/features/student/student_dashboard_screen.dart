import 'package:flutter/material.dart';

import 'student_widgets/student_status_banner.dart';
import 'student_widgets/digital_id_card_preview.dart';
import 'student_widgets/student_menu_tile.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DEMO DATA — পরে Firestore থেকে আসবে
    final String studentName = "Bashir Alam";
    final String department = "CSE";
    final String digitalId = "NUBTK-2025-001";
    final String status = "pending"; // pending | approved

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StudentStatusBanner(status: status),
            const SizedBox(height: 16),

            DigitalIdCardPreview(
              name: studentName,
              department: department,
              digitalId: digitalId,
            ),

            const SizedBox(height: 24),

            StudentMenuTile(
              icon: Icons.badge,
              title: "Digital ID",
              onTap: () {
                // next step → digital_id_screen.dart
              },
            ),

            StudentMenuTile(
              icon: Icons.smart_toy,
              title: "AI Assistant",
              locked: true,
              onTap: () {},
            ),

            StudentMenuTile(
              icon: Icons.payment,
              title: "Payments",
              locked: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
