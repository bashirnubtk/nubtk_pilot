// D:\projects\nubtk_pilot\lib\features\payment\payment_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_model.dart';
import 'installment_generator.dart';
import 'payment_notification_service.dart';

class PaymentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ১. এডমিনের জন্য পেমেন্ট প্ল্যান জেনারেট (students কালেকশনে আপডেট হবে)
  static Future<void> createPaymentPlan({
    required String studentId,
    required String grade,
    required double totalCourseFee,
  }) async {
    // ওয়েভার লজিক
    double waiver = (grade == "A+") ? 20.0 : 10.0;
    double finalAmount = totalCourseFee - (totalCourseFee * (waiver / 100));

    List<Installment> installments =
        InstallmentGenerator.generateSemesterInstallments(
          finalAmount: finalAmount,
        );

    // কিস্তিগুলোকে ম্যাপে রূপান্তর করা
    List<Map<String, dynamic>> installmentList = installments
        .map(
          (e) => {
            'id': e.id,
            'amount': e.amount,
            'dueDate': e.dueDate.toIso8601String(),
            'isPaid': false,
            'status': 'Pending', // ডিফল্ট স্ট্যাটাস
            'semester': e.semester,
          },
        )
        .toList();

    // 'students' কালেকশনে পেমেন্ট ইনফো আপডেট করা হচ্ছে
    await _db.collection('students').doc(studentId).update({
      'installments': installmentList,
      'paymentStatus': 'generated',
    });
  }

  // ২. ড্যাশবোর্ডের জন্য কিস্তি রিড করা ('students' কালেকশন থেকে)
  static Future<List<Installment>> getStudentInstallments() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    try {
      final doc = await _db.collection('students').doc(uid).get();

      if (doc.exists && doc.data()!.containsKey('installments')) {
        List<dynamic> list = doc.data()!['installments'];
        return list
            .map((e) => Installment.fromMap(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print("Error fetching installments: $e");
    }
    return [];
  }

  // ৩. কিস্তি পেইড মার্ক করা (নতুন ট্রানজ্যাকশন লজিক অনুযায়ী আপডেট করা হয়েছে)
  static Future<void> markInstallmentPaid(String installmentId) async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = _db.collection('students').doc(uid);

    try {
      await _db.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        // কিস্তি লিস্টটি নেওয়া হচ্ছে
        List<dynamic> installments = List.from(
          snapshot.get('installments') ?? [],
        );

        int paidSemester = 0;
        bool found = false;

        for (var i = 0; i < installments.length; i++) {
          if (installments[i]['id'] == installmentId) {
            installments[i]['isPaid'] = true;
            installments[i]['status'] =
                'Paid'; // নতুন রিকোয়ারমেন্ট অনুযায়ী ডাবল চেক
            installments[i]['paymentDate'] = DateTime.now().toIso8601String();

            paidSemester = installments[i]['semester'] ?? 0;
            found = true;
            break;
          }
        }

        if (found) {
          transaction.update(docRef, {'installments': installments});

          // ৪. পেমেন্ট সফল হলে নোটিফিকেশন ট্রিগার করা
          if (paidSemester > 0) {
            // ট্রানজ্যাকশন শেষ হওয়ার পর নোটিফিকেশন পাঠানো ভালো
            PaymentNotificationService.notifyPaymentSuccess(uid, paidSemester);
          }
        }
      });
    } catch (e) {
      print("Transaction failed: $e");
      rethrow;
    }
  }
}
