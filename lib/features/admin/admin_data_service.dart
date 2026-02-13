import 'package:cloud_firestore/cloud_firestore.dart';
import '../student/student_model.dart';
import '../payment/payment_model.dart';
import '../payment/installment_generator.dart';

class AdminDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<List<StudentModel>> getPendingStudentsStream() {
    return _firestore
        .collection('students')
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
                // নিচের লাইনটি আপনার এরর সমাধান করবে
                photoUrl: data['photoUrl'] ?? '', 
                status: data['status'] ?? 'pending',
                digitalId: data['digitalId'] ?? '',
                createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              );
            }).toList());
  }

  /// 🔹 স্টুডেন্ট অ্যাপ্রুভ করার সময় পেমেন্ট ডাটা সহ আপডেট
  static Future<void> approveStudent(String id, {double totalFee = 450000, double waiver = 20}) async {
    // ১. পেমেন্ট ক্যালকুলেশন
    double finalAmount = totalFee - (totalFee * (waiver / 100));
    
    // ২. কিস্তি তৈরি করা
    List<Installment> installments = InstallmentGenerator.generateSemesterInstallments(
      finalAmount: finalAmount,
    );

    // ৩. পেমেন্ট মডেল তৈরি
    PaymentModel payment = PaymentModel(
      studentId: id,
      totalCourseFee: totalFee,
      waiverPercent: waiver,
      finalPayableAmount: finalAmount,
      paymentPlan: 'Semester (3 installments)',
      totalInstallments: installments.length,
      installments: installments,
    );

    // ৪. ফায়ারস্টোরে আপডেট
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