import 'package:flutter/material.dart';

class DigitalIdScreen extends StatelessWidget {
  final String studentId; // এই লাইনটি যোগ করা হয়েছে

  const DigitalIdScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Digital ID Card"),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_2, size: 200, color: Colors.indigo),
            const SizedBox(height: 20),
            Text(
              "Student ID: $studentId",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}