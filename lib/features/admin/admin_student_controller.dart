// C:\projects\Flutter project\nubtk_pilot\lib\features\admin\admin_student_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../payment/waiver_engine.dart';
import '../payment/installment_generator.dart';
import '../auth/email_service.dart'; // ইমেইল সার্ভিস ইমপোর্ট করা হয়েছে

class AdminStudentController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ১. স্টুডেন্ট এপ্রুভাল লজিক (স্ক্রিন ফাইলের সাথে সামঞ্জস্য রেখে নাম পরিবর্তন করা হয়েছে)
  Future<void> approveStudent({
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      // ক. ডাটা থেকে প্রয়োজনীয় তথ্য সংগ্রহ
      String name = data['fullName'] ?? 'Unknown Student';
      String email = data['email']?.toString().trim() ?? '';
      String phone = data['phone']?.toString().trim() ?? '12345678';
      double hscGpa = double.tryParse(data['hscGpa']?.toString() ?? '0.0') ?? 0.0;
      String dept = (data['department'] ?? "CSE").toString().toUpperCase();

      if (email.isEmpty) throw Exception("স্টুডেন্টের ইমেইল পাওয়া যায়নি!");

      // খ. ডিজিটাল আইডি জেনারেশন (ট্রানজ্যাকশন ব্যবহার করে যাতে আইডি ডুপ্লিকেট না হয়)
      final counterRef = _db.collection('counters').doc('student_id');
      String generatedId = await _db.runTransaction((transaction) async {
        DocumentSnapshot counterSnap = await transaction.get(counterRef);
        int newSerial = (counterSnap.exists ? (counterSnap.get('current') ?? 0) : 0) + 1;
        
        transaction.set(counterRef, {'current': newSerial}, SetOptions(merge: true));
        
        return "NUBTK-$dept-${DateTime.now().year}-${newSerial.toString().padLeft(4, '0')}";
      });

      // গ. কিস্তি ও ওয়েভার ক্যালকুলেশন
      double totalCourseFee = 450000;
      double netPayable = WaiverEngine.calculateFinalAmount(totalFee: totalCourseFee, grade: hscGpa.toString());
      double waiverAmount = totalCourseFee - netPayable;
      
      // কিস্তি জেনারেট করা
      var installments = InstallmentGenerator.generateSemesterInstallments(finalAmount: netPayable);

      // ঘ. ডাটা আপডেট করা (যেহেতু আপনার স্ক্রিন 'students' কালেকশন থেকে ডাটা পড়ছে, তাই সেখানেই আপডেট হবে)
      await _db.collection('students').doc(docId).update({
        'digitalId': generatedId,
        'status': 'approved', 
        'role': 'student', 
        'approved': true,
        'waiverAmount': waiverAmount,
        'netPayable': netPayable,
        'systemPassword': phone, // প্রাথমিক পাসওয়ার্ড হিসেবে ফোন নাম্বার
        'installments': installments.map((e) => {
          'id': e.id,
          'amount': e.amount,
          'dueDate': e.dueDate.toIso8601String(),
          'isPaid': false,
          'semester': e.semester
        }).toList(),
        'approvalDate': FieldValue.serverTimestamp(),
      });

      // ঙ. জিমেইল পাঠানো
      await EmailService.sendApprovalEmail(
        recipientEmail: email,
        studentName: name,
        digitalId: generatedId,
        password: phone,
        totalFee: totalCourseFee,
        waiver: waiverAmount,
        netPayable: netPayable,
      );

      print("Process Successfully Completed for: $email | ID: $generatedId");

    } catch (e) {
      print("Approval Error: $e");
      throw Exception("এপ্রুভাল প্রসেস ব্যর্থ হয়েছে: $e");
    }
  }

  // ২. পেমেন্ট কনফার্মেশন ফাংশন
  Future<void> makePayment(String studentUid, int index) async {
    try {
      DocumentReference ref = _db.collection('students').doc(studentUid);
      DocumentSnapshot snap = await ref.get();
     
      if (!snap.exists) throw Exception("স্টুডেন্ট খুঁজে পাওয়া যায়নি");

      List inst = List.from(snap.get('installments'));
     
      if (index >= 0 && index < inst.length) {
        inst[index]['isPaid'] = true;
        inst[index]['paymentDate'] = DateTime.now().toIso8601String();
        inst[index]['status'] = 'Paid';
       
        await ref.update({
          'installments': inst,
        });
      } else {
        throw Exception("ভুল কিস্তি ইনডেক্স");
      }
    } catch (e) {
      print("Payment Error: $e");
      throw Exception("পেমেন্ট আপডেট করতে সমস্যা হয়েছে: $e");
    }
  }

  Future<void> approveAndSendEmail({required String studentId, required String name, required String email}) async {}
}