import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentNotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check for upcoming dues (আপনার ম্যাপ স্ট্রাকচার অনুযায়ী)
  static Future<void> checkUpcomingDues(String studentId) async {
    final now = DateTime.now();
    final upcomingLimit = now.add(const Duration(days: 7));

    final doc = await _firestore.collection('students').doc(studentId).get();
    if (!doc.exists || !doc.data()!.containsKey('payment')) return;

    final paymentData = doc.data()!['payment'] as Map<String, dynamic>;
    final List<dynamic> installments = paymentData['installments'] ?? [];

    for (var inst in installments) {
      // String থেকে DateTime এ কনভার্ট করা (যেহেতু আমরা Iso8601String ব্যবহার করেছি)
      final dueDate = DateTime.parse(inst['dueDate']);
      final bool isPaid = inst['isPaid'] ?? false;

      if (!isPaid && dueDate.isAfter(now) && dueDate.isBefore(upcomingLimit)) {
        await _createInAppNotification(
          studentId,
          "Reminder: Installment ${inst['semester']} is due on ${inst['dueDate'].split('T')[0]}!",
        );
      }
    }
  }

  /// পেমেন্ট সাকসেস নোটিফিকেশন
  static Future<void> notifyPaymentSuccess(String studentId, int semester) async {
    await _createInAppNotification(
      studentId,
      "Success! Your payment for Installment $semester has been received.",
    );
  }

  /// ইন-অ্যাপ নোটিফিকেশন ডকুমেন্ট তৈরি
  static Future<void> _createInAppNotification(String studentId, String message) async {
    // ডুপ্লিকেট নোটিফিকেশন এড়াতে চেক করা যেতে পারে, তবে আপাতত সহজ রাখা হলো
    await _firestore
        .collection('students')
        .doc(studentId)
        .collection('notifications')
        .add({
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }
}