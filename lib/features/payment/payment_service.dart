import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_model.dart';
import 'installment_generator.dart';
import 'payment_notification_service.dart'; // নোটিফিকেশন সার্ভিস ইমপোর্ট করা হলো

class PaymentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ১. এডমিনের জন্য পেমেন্ট প্ল্যান জেনারেট
  static Future<void> createPaymentPlan({
    required String studentId,
    required String grade,
    required double totalCourseFee,
  }) async {
    double waiver = (grade == "A+") ? 20.0 : 10.0; 
    double finalAmount = totalCourseFee - (totalCourseFee * (waiver / 100));

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

    await _db.collection('students').doc(studentId).update({
      'payment': newPlan.toMap(),
      'paymentStatus': 'generated',
    });
  }

  // ২. ড্যাশবোর্ডের জন্য কিস্তি রিড করা
  static Future<List<Installment>> getStudentInstallments() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final doc = await _db.collection('students').doc(uid).get();
    if (doc.exists && doc.data()!.containsKey('payment')) {
      final paymentData = doc.data()!['payment'] as Map<String, dynamic>;
      if (paymentData.containsKey('installments')) {
        List<dynamic> list = paymentData['installments'];
        return list.map((e) => Installment.fromMap(e as Map<String, dynamic>)).toList();
      }
    }
    return [];
  }

  // ৩. কিস্তি পেইড মার্ক করা এবং নোটিফিকেশন পাঠানো
  static Future<void> markInstallmentPaid(String installmentId) async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = _db.collection('students').doc(uid);
    
    await _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (!data.containsKey('payment')) return;

      Map<String, dynamic> payment = Map<String, dynamic>.from(data['payment']);
      List<dynamic> installments = List.from(payment['installments'] ?? []);
      
      int paidSemester = 0; // নোটিফিকেশনের জন্য সেমিস্টার ট্র্যাক করা

      for (var i = 0; i < installments.length; i++) {
        if (installments[i]['id'] == installmentId) {
          installments[i]['isPaid'] = true;
          paidSemester = installments[i]['semester'] ?? 0;
          break;
        }
      }

      payment['installments'] = installments;
      transaction.update(docRef, {'payment': payment});

      // ৪. পেমেন্ট সফল হলে নোটিফিকেশন ট্রিগার করা
      if (paidSemester > 0) {
        await PaymentNotificationService.notifyPaymentSuccess(uid, paidSemester);
      }
    });
  }
}