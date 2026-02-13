import 'package:cloud_firestore/cloud_firestore.dart';
import '../student/student_model.dart';
import '../payment/payment_model.dart';
import '../payment/installment_generator.dart';
import '../payment/waiver_engine.dart'; // ওয়েভার ইঞ্জিন ইম্পোর্ট নিশ্চিত করুন

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
                photoUrl: data['photoUrl'] ?? '', 
                status: data['status'] ?? 'pending',
                digitalId: data['digitalId'] ?? '',
                createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              );
            }).toList());
  }

  /// 🔹 স্টুডেন্ট অ্যাপ্রুভ করার সময় গ্রেড অনুযায়ী ওয়েভার ও পেমেন্ট জেনারেট
  static Future<void> approveStudent(String id, {
    double totalFee = 450000, 
    required String grade, // এখন সরাসরি গ্রেড ইনপুট নেবে
  }) async {
    
    // ১. WaiverEngine ব্যবহার করে ওয়েভার এবং ফাইনাল অ্যামাউন্ট বের করা
    double waiverPercent = WaiverEngine.calculateWaiverPercent(grade);
    double finalAmount = WaiverEngine.calculateFinalAmount(totalFee: totalFee, grade: grade);
    
    // ২. কিস্তি তৈরি করা (InstallmentGenerator ব্যবহার করে)
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

    // ৪. ফায়ারস্টোরে ডিজিটাল আইডি জেনারেশন (অপশনাল কিন্তু প্রফেশনাল)
    String digitalId = 'NUBTK-${DateTime.now().year}-${id.substring(id.length - 4).toUpperCase()}';

    // ৫. ফায়ারস্টোরে আপডেট
    await _firestore.collection('students').doc(id).update({
      'status': 'approved',
      'digitalId': digitalId,
      'payment': payment.toMap(), // পুরো পেমেন্ট অবজেক্ট ম্যাপ হিসেবে সেভ হবে
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> rejectStudent(String id) async {
    await _firestore.collection('students').doc(id).update({
      'status': 'rejected',
    });
  }
}