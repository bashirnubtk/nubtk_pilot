import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminStudentController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // EmailJS Credentials (আপনার স্ক্রিনশট থেকে নেওয়া)
  final String serviceId = 'service_xxxx'; // আপনার Service ID দিন
  final String templateId = 'template_xxxx'; // আপনার Template ID দিন
  final String publicKey = 'fi29Echo77ndbm7kN'; 
  final String privateKey = 'ttxoiGZEDBexD8XCjdKuh';

  Future<void> approveAndSendEmail({
    required String studentId,
    required String name,
    required String email,
  }) async {
    try {
      final docRef = _db.collection('students').doc(studentId);
      final counterRef = _db.collection('counters').doc('student_id');

      String generatedId = "";

      await _db.runTransaction((transaction) async {
        DocumentSnapshot counterSnap = await transaction.get(counterRef);
        int current = counterSnap.exists ? (counterSnap.get('current') ?? 0) : 0;
        int newSerial = current + 1;
        generatedId = "NUBTK-${DateTime.now().year}-${newSerial.toString().padLeft(4, '0')}";

        transaction.update(docRef, {
          'status': 'approved',
          'approved': true,
          'digitalId': generatedId,
        });
        transaction.set(counterRef, {'current': newSerial});
      });

      // API Call
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'accessToken': privateKey,
          'template_params': {
            'to_name': name,
            'to_email': email,
            'digital_id': generatedId,
          }
        }),
      );

      if (response.statusCode == 200) {
        await docRef.update({'emailSent': true});
      }
    } catch (e) {
      throw Exception("Approval failed: $e");
    }
  }
}