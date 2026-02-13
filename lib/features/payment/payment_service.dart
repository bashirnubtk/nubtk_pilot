import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_model.dart';
import 'installment_generator.dart';

class PaymentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // এডমিনের জন্য পেমেন্ট প্ল্যান তৈরি করার মেথড
  static Future<void> createPaymentPlan({
    required String studentId,
    required String grade,
    required double totalCourseFee,
  }) async {
    // গ্রেড অনুযায়ী ওয়েভার ক্যালকুলেশন
    double waiver = (grade == "A+") ? 20.0 : 10.0; 
    double finalAmount = totalCourseFee - (totalCourseFee * (waiver / 100));

    // ইনসটলমেন্ট জেনারেট করা
    List<Installment> installments = InstallmentGenerator.generateSemesterInstallments(
      finalAmount: finalAmount,
    );

    PaymentModel newPlan = PaymentModel(
      studentId: studentId,
      totalCourseFee: totalCourseFee,
      waiverPercent: waiver,
      finalPayableAmount: finalAmount,
      paymentPlan: "Semester Based",
      totalInstallments: installments.length,
      installments: installments,
    );

    // স্টুডেন্টের ডক আপডেট করা
    await _db.collection('students').doc(studentId).update({
      'installments': newPlan.installments.map((e) => e.toMap()).toList(),
      'paymentStatus': 'generated',
    });
  }

  // স্টুডেন্টের জন্য কিস্তি পেইড মার্ক করা
  static Future<void> markInstallmentPaid(String installmentId) async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = _db.collection('students').doc(uid);
    final doc = await docRef.get();

    if (doc.exists) {
      List<dynamic> installments = doc.get('installments') ?? [];
      for (var i = 0; i < installments.length; i++) {
        if (installments[i]['id'] == installmentId) {
          installments[i]['isPaid'] = true;
          break;
        }
      }
      await docRef.update({'installments': installments});
    }
  }
}