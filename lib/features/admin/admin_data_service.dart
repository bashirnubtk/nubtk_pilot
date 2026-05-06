//D:\projects\nubtk_pilot\lib\features\admin\admin_data_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ১. পেন্ডিং স্টুডেন্টদের লিস্ট (Admission Tab এর জন্য)
  Stream<QuerySnapshot> getPendingStudents() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // ২. অ্যাপ্রুভড স্টুডেন্টদের লিস্ট (Payment Tab এর জন্য)
  Stream<QuerySnapshot> getApprovedStudents() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('status', isEqualTo: 'approved')
        .snapshots();
  }

  // ৩. অ্যাপ্রুভ লজিক ও ডিজিটাল আইডি জেনারেশন (Transaction ব্যবহার করে)
  Future<void> approveStudent(String docId) async {
    final counterRef = _db.collection('counters').doc('student_id');
    final studentRef = _db.collection('users').doc(docId);

    return _db.runTransaction((transaction) async {
      DocumentSnapshot studentSnap = await transaction.get(studentRef);
      
      if (!studentSnap.exists) return;

      String dept = (studentSnap.get('department') ?? "GEN").toString().toUpperCase();

      // কাউন্টার থেকে বর্তমান সিরিয়াল নেওয়া
      DocumentSnapshot counterSnap = await transaction.get(counterRef);
      int current = counterSnap.exists ? (counterSnap.get('current') ?? 0) : 0;
      int newSerial = current + 1;
      
      String year = DateTime.now().year.toString();
      // আইডি ফরম্যাট: NUBTK-CSE-2026-0001
      String formattedId = "NUBTK-$dept-$year-${newSerial.toString().padLeft(4, '0')}";

      // কাউন্টার আপডেট
      transaction.set(counterRef, {'current': newSerial}, SetOptions(merge: true));

      // স্টুডেন্ট ডাটা আপডেট
      transaction.update(studentRef, {
        'status': 'approved',
        'digitalId': formattedId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ৪. রিজেক্ট বা ডিলিট অপশন (সরাসরি ডাটাবেস থেকে মুছে ফেলবে)
  Future<void> deleteOrRejectStudent(String id) async {
    await _db.collection('users').doc(id).delete();
  }
}