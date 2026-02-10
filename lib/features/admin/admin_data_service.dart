import 'package:cloud_firestore/cloud_firestore.dart';
import '../student/student_model.dart';

class AdminDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 ফায়ারস্টোর থেকে পেন্ডিং স্টুডেন্টদের লিস্ট আনা
  static Future<List<StudentModel>> getPendingStudents() async {
    try {
      final snapshot = await _firestore
          .collection('students')
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return StudentModel(
          id: doc.id,
          fullName: data['fullName'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
          department: data['department'] ?? '',
          sscGpa: (data['sscGpa'] as num?)?.toDouble(),
          hscGpa: (data['hscGpa'] as num?)?.toDouble(),
          photoUrl: data['photoUrl'] ?? '', // আপনার রেজিস্ট্রেশন স্ক্রিনের ফিল্ড নাম অনুযায়ী
          status: data['status'] ?? 'pending',
          digitalId: data['digitalId'] ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print("Error fetching students: $e");
      return [];
    }
  }

  /// 🔹 স্টুডেন্টের স্ট্যাটাস আপডেট করা (Approve/Reject)
  static Future<void> updateStatus(String docId, String status) async {
    await _firestore.collection('students').doc(docId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}