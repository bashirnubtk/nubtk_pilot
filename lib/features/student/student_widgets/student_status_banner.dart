import 'package:flutter/material.dart';

class StudentStatusBanner extends StatelessWidget {
  final String status;

  const StudentStatusBanner({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool approved = status == 'approved';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: approved ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            approved ? Icons.check_circle : Icons.hourglass_bottom,
            color: approved ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 10),
          Text(
            approved
                ? "Your application is approved"
                : "Your application is under review",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
