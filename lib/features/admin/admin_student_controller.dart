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

  Future<void> approveStudent({
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      String name = data['fullName'] ?? 'Unknown Student';
      String email = data['email']?.toString().trim() ?? '';
      String phone = data['phone']?.toString().trim() ?? '12345678';
      double hscGpa = double.tryParse(data['hscGpa']?.toString() ?? '0.0') ?? 0.0;
      String dept = (data['department'] ?? "CSE").toString().toUpperCase();

      if (email.isEmpty) throw Exception("স্টুডেন্টের ইমেইল পাওয়া যায়নি!");

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

      // ৩. ডাটা আপডেট (সবচেয়ে গুরুত্বপূর্ণ অংশ)
      // এখানে 'studentId' এবং 'digitalId' দুটিই রাখা হয়েছে যাতে কোনো পেজ খালি না থাকে
      await _db.collection('students').doc(docId).set({
        ...data, // আগের সব ডাটা (যেমন ফটো, মার্কশিট) অক্ষুণ্ণ রাখা হলো
        'studentId': generatedId, // স্টুডেন্ট পোর্টালে সাধারণত এই নামেই আইডি খোঁজে
        'digitalId': generatedId, 
        'status': 'approved',
        'role': 'student',
        'approved': true,
        'waiverAmount': waiverAmount,
        'netPayable': netPayable,
        'systemPassword': phone,
        'installments': installments.map((e) => {
          'id': e.id,
          'amount': e.amount,
          'dueDate': e.dueDate.toIso8601String(),
          'isPaid': false,
          'semester': e.semester,
          'status': 'Pending' // কিস্তির প্রাথমিক স্ট্যাটাস
        }).toList(),
        'approvalDate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // merge: true দিলে আগের ডাটা হারাবে না

      // ৪. জিমেইল পাঠানো
      await EmailService.sendApprovalEmail(
        recipientEmail: email,
        studentName: name,
        digitalId: generatedId,
        password: phone,
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