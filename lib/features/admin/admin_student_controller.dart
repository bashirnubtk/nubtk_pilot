//D:\projects\nubtk_pilot\lib\features\admin\admin_student_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../payment/waiver_engine.dart';
import '../payment/installment_generator.dart';
import '../auth/email_service.dart';

class AdminStudentController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> approveAndSendEmail({
    required String studentId,
    required String name,
    required String email,
    Map<String, dynamic>? data,
  }) async {
    final Map<String, dynamic> studentData = data ?? {
      'fullName': name,
      'email': email,
    };
    return await approveStudent(docId: studentId, data: studentData);
  }

  // 🔥 ফাইনাল ফিক্স: Firebase Auth টাচই করব না। Admin লগইন ভাঙবে না।
  Future<void> approveStudent({
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      String name = data['fullName'] ?? 'Unknown Student';
      String email = data['email']?.toString().trim() ?? '';
      String phone = data['phone']?.toString().trim() ?? '';
      double hscGpa = double.tryParse(data['hscGpa']?.toString() ?? '0.0') ?? 0.0;
      String dept = (data['department'] ?? "CSE").toString().toUpperCase();
      String uid = data['uid']?.toString().trim() ?? docId; // Student রেজিস্টারের সময় যে UID তৈরি হইছে

      if (email.isEmpty) throw Exception("স্টুডেন্টের ইমেইল পাওয়া যায়নি!");
      if (phone.isEmpty) throw Exception("স্টুডেন্টের ফোন নম্বর পাওয়া যায়নি!");
      if (uid.isEmpty) throw Exception("স্টুডেন্টের UID পাওয়া যায়নি!");

      String cleanPassword = phone.replaceAll(RegExp(r'[\s\-\+]'), '').replaceAll('88', '');
      if (cleanPassword.length > 11) {
        cleanPassword = cleanPassword.substring(cleanPassword.length - 11);
      }

      // ১. ডিজিটাল আইডি জেনারেশন
      final counterRef = _db.collection('counters').doc('student_id');
      String generatedId = await _db.runTransaction((transaction) async {
        DocumentSnapshot counterSnap = await transaction.get(counterRef);
        int newSerial = (counterSnap.exists ? (counterSnap.get('current') ?? 0) : 0) + 1;
        transaction.set(counterRef, {'current': newSerial}, SetOptions(merge: true));
        return "NUBTK-$dept-${DateTime.now().year}-${newSerial.toString().padLeft(4, '0')}";
      });

      // ২. কিস্তি ও ওয়েভার ক্যালকুলেশন
      double totalCourseFee = 450000;
      double netPayable = WaiverEngine.calculateFinalAmount(totalFee: totalCourseFee, grade: hscGpa.toString());
      double waiverAmount = totalCourseFee - netPayable;
      var installments = InstallmentGenerator.generateSemesterInstallments(finalAmount: netPayable);

      // ৩. students কালেকশন আপডেট - শুধু Status চেঞ্জ
      await _db.collection('students').doc(docId).update({
        'studentId': generatedId,
        'digitalId': generatedId,
        'status': 'approved', // 🔥 এটা দিয়েই Student লগইন করতে পারবে
        'approved': true,
        'waiverAmount': waiverAmount,
        'netPayable': netPayable,
        'systemPassword': cleanPassword,
        'installments': installments.map((e) => {
          'id': e.id,
          'amount': e.amount,
          'dueDate': e.dueDate.toIso8601String(),
          'isPaid': false,
          'semester': e.semester,
          'status': 'Pending'
        }).toList(),
        'approvalDate': FieldValue.serverTimestamp(),
      });

      // ৪. জিমেইল পাঠানো
      await EmailService.sendApprovalEmail(
        recipientEmail: email,
        studentName: name,
        digitalId: generatedId,
        password: cleanPassword,
        totalFee: totalCourseFee,
        waiver: waiverAmount,
        netPayable: netPayable,
      );

    } catch (e) {
      print("Approval Error: $e");
      throw Exception("এপ্রুভাল প্রসেস ব্যর্থ হয়েছে: $e");
    }
  }

  Future<void> makePayment(String studentUid, int index) async {
    try {
      DocumentReference ref = _db.collection('students').doc(studentUid);
      DocumentSnapshot snap = await ref.get();
      if (!snap.exists) throw Exception("স্টুডেন্ট খুঁজে পাওয়া যায়নি");

      List inst = List.from(snap.get('installments'));
      if (index >= 0 && index < inst.length) {
        inst[index]['isPaid'] = true;
        inst[index]['paymentDate'] = DateTime.now().toIso8601String();
        inst[index]['status'] = 'Paid';
        await ref.update({'installments': inst});
      }
    } catch (e) {
      throw Exception("পেমেন্ট আপডেট করতে সমস্যা হয়েছে: $e");
    }
  }
}