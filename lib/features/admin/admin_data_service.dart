import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getPendingStudents() {
    return _db.collection('students').where('status', isEqualTo: 'pending').snapshots();
  }

  Stream<QuerySnapshot> getApprovedStudents() {
    return _db.collection('students').where('status', isEqualTo: 'approved').snapshots();
  }

  // ৩. প্রফেশনাল আইডি জেনারেশন (ডিপার্টমেন্ট কোডসহ)
  Future<void> approveStudent(String docId) async {
    final counterRef = _db.collection('counters').doc('student_id');
    final studentRef = _db.collection('students').doc(docId);

    return _db.runTransaction((transaction) async {
      // স্টুডেন্টের ডাটা থেকে ডিপার্টমেন্ট কোড নেওয়া (যেমন: CSE, BBA)
      DocumentSnapshot studentSnap = await transaction.get(studentRef);
      String dept = (studentSnap.get('department') ?? "GEN").toString().toUpperCase();

      // কাউন্টার থেকে বর্তমান সিরিয়াল নেওয়া
      DocumentSnapshot counterSnap = await transaction.get(counterRef);
      int current = counterSnap.exists ? (counterSnap.get('current') ?? 0) : 0;
      int newSerial = current + 1;
      
      String year = DateTime.now().year.toString();
      // ফরম্যাট: NUBTK-CSE-2026-0001
      String formattedId = "NUBTK-$dept-$year-${newSerial.toString().padLeft(4, '0')}";

      // ১. কাউন্টার আপডেট করা
      transaction.set(counterRef, {'current': newSerial}, SetOptions(merge: true));

      // ২. স্টুডেন্ট ডাটা আপডেট করা
      transaction.update(studentRef, {
        'status': 'approved',
        'digitalId': formattedId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> rejectStudent(String id) async {
    await _db.collection('students').doc(id).update({'status': 'rejected'});
  }
}