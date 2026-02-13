import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_model.dart';
import 'installment_generator.dart';

// জিপিটির কোডে WaiverEngine চাওয়া হয়েছে, আমরা একটি ছোট ইঞ্জিন এখানেই তৈরি করে দিচ্ছি
class WaiverEngine {
  static double calculateWaiverPercent(String grade) {
    if (grade == "A+") return 40.0;
    if (grade == "A") return 30.0;
    if (grade == "B") return 20.0;
    return 10.0; // Default waiver
  }

  static double calculateFinalAmount({required double totalFee, required String grade}) {
    double waiver = calculateWaiverPercent(grade);
    return totalFee - (totalFee * (waiver / 100));
  }
}

class PaymentService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> createPaymentPlan({
    required String studentId,
    required String grade,
    required double totalCourseFee,
  }) async {
    // ১. ক্যালকুলেশন
    final finalAmount = WaiverEngine.calculateFinalAmount(
      totalFee: totalCourseFee,
      grade: grade,
    );

    final waiverPercent = WaiverEngine.calculateWaiverPercent(grade);

    // ২. কিস্তি তৈরি (ইন্সটলমেন্ট জেনারেটর ব্যবহার করে)
    final installments = InstallmentGenerator.generateSemesterInstallments(
      finalAmount: finalAmount,
    );

    // ৩. পেমেন্ট মডেল তৈরি
    final paymentModel = PaymentModel(
      studentId: studentId,
      totalCourseFee: totalCourseFee,
      waiverPercent: waiverPercent,
      finalPayableAmount: finalAmount,
      paymentPlan: "semester",
      totalInstallments: installments.length,
      installments: installments,
    );

    // ৪. সেভ করা
    await _firestore.collection("students").doc(studentId).update({
      "payment": paymentModel.toMap(),
    });
  }
}