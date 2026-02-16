import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nubtk_pilot/features/auth/email_service.dart';
import 'dart:math';

class AdminStudentController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // স্টুডেন্ট আইডি জেনারেট করার লজিক
  String _generateDigitalId() {
    final random = Random();
    int idNumber = 100000 + random.nextInt(900000);
    return "NUBTK-$idNumber";
  }

  // এপ্রুভ এবং ইমেইল পাঠানোর মেইন ফাংশন
  Future<void> approveAndSendEmail({
    required String studentId,
    required String name,
    required String email,
  }) async {
    try {
      final docRef = _db.collection('students').doc(studentId);
      final doc = await docRef.get();

      // যদি অলরেডি এপ্রুভড হয়, তবে আর কাজ করবে না
      if (doc.exists && doc.data()!['approved'] == true) {
        print("Student already approved.");
        return;
      }

      final digitalId = _generateDigitalId();

      // ১. ফায়ারস্টোরে এপ্রুভাল এবং আইডি আপডেট
      await docRef.update({
        'approved': true,
        'digitalId': digitalId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ২. আপনার সেই SMTP (App Password) ব্যবহার করে ইমেইল পাঠানো
      await EmailService.sendDigitalID(
        recipientEmail: email,
        studentName: name,
        digitalId: digitalId,
      );

      // ৩. ইমেইল পাঠানো সফল হলে স্ট্যাটাস আপডেট
      await docRef.update({'emailSent': true});
      
      print("Process Completed: Approved & Email Sent.");
    } catch (e) {
      print("Error in Admin Action: $e");
    }
  }
}