import 'package:flutter/material.dart';

class StudentStatusBanner extends StatelessWidget {
  final String status;
  const StudentStatusBanner({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'approved':
        color = Colors.green;
        text = 'Your application is approved';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Application Rejected';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.orange;
        text = 'Your application is under review';
        icon = Icons.hourglass_bottom;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15), // লেটেস্ট ভার্সন অনুযায়ী ফিক্সড
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}