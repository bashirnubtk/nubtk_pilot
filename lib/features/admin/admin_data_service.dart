import 'package:cloud_firestore/cloud_firestore.dart';
import '../student/student_model.dart';
import '../payment/payment_model.dart';
import '../payment/installment_generator.dart';
import '../payment/waiver_engine.dart';

class AdminDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ফায়ারবেস থেকে পেন্ডিং স্টুডেন্টদের স্ট্রীম আনা
  static Stream<List<StudentModel>> getPendingStudentsStream() {
    return _firestore
        .collection('students') // রেজিস্ট্রেশন ফাইলে কালেকশন নাম 'students' রাখা হয়েছে
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return StudentModel(
                id: doc.id,
                fullName: data['fullName'] ?? '',
                email: data['email'] ?? '',
                phone: data['phone'] ?? '',
                department: data['department'] ?? '',
                photoUrl: data['photoUrl'] ?? '', 
                status: data['status'] ?? 'pending',
                digitalId: data['digitalId'] ?? '',
                createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              );
            }).toList());
  }

  static Future<void> approveStudent(String id, {
    double totalFee = 450000, 
    required String grade,
  }) async {
    // ১. ওয়েভার ক্যালকুলেশন
    double waiverPercent = WaiverEngine.calculateWaiverPercent(grade);
    double finalAmount = WaiverEngine.calculateFinalAmount(totalFee: totalFee, grade: grade);
    
    // ২. কিস্তি জেনারেট করা
    List<Installment> installments = InstallmentGenerator.generateSemesterInstallments(
      finalAmount: finalAmount,
    );

    // ৩. পেমেন্ট মডেল তৈরি
    PaymentModel payment = PaymentModel(
      studentId: id,
      totalCourseFee: totalFee,
      waiverPercent: waiverPercent,
      finalPayableAmount: finalAmount,
      paymentPlan: '8 Semesters (24 Installments)',
      totalInstallments: installments.length,
      installments: installments,
    );

    // ৪. স্ট্যাটাস আপডেট করা
    await _firestore.collection('students').doc(id).update({
      'status': 'approved',
      'payment': payment.toMap(), 
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> rejectStudent(String id) async {
    await _firestore.collection('students').doc(id).update({
      'status': 'rejected',
    });
  }
}