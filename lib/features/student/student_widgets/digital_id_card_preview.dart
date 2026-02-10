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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.indigo, Colors.deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Digital Student ID", style: TextStyle(color: Colors.white70)),
              Icon(Icons.nfc, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(department, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          Text(
            "ID: $digitalId",
            style: const TextStyle(color: Colors.white, letterSpacing: 1.2, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}