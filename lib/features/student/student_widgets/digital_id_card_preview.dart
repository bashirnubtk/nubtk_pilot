import 'package:flutter/material.dart';

class DigitalIdCardPreview extends StatelessWidget {
  final String name;
  final String department;
  final String digitalId;

  const DigitalIdCardPreview({
    super.key,
    required this.name,
    required this.department,
    required this.digitalId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.indigo, Colors.deepPurple],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Digital Student ID",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            department,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            "ID: $digitalId",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
