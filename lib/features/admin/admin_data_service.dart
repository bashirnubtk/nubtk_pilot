import 'package:cloud_firestore/cloud_firestore.dart';
import '../student/student_model.dart';

class AdminDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 ফায়ারস্টোর থেকে পেন্ডিং স্টুডেন্টদের লিস্ট আনা (রিয়েল-টাইম স্ট্রিম)
  /// এর ফলে এডমিন স্ক্রিনে ডাটা অটোমেটিক আপডেট হবে
  static Stream<List<StudentModel>> getPendingStudentsStream() {
    return _firestore
        .collection('students')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
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
          photoUrl: data['photoUrl'] ?? '',
          status: data['status'] ?? 'pending',
          digitalId: data['digitalId'] ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  /// 🔹 স্টুডেন্টের স্ট্যাটাস আপডেট করা (Approve)
  static Future<void> approveStudent(String id) async {
    await _firestore.collection('students').doc(id).update({
      'status': 'approved',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 🔹 স্টুডেন্টের স্ট্যাটাস আপডেট করা (Reject)
  static Future<void> rejectStudent(String id) async {
    await _firestore.collection('students').doc(id).update({
      'status': 'rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}