import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ১. পেন্ডিং স্টুডেন্টদের লিস্ট দেখা (Role: student এবং Status: pending)
  Stream<QuerySnapshot> getPendingStudents() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // ২. এপ্রুভড স্টুডেন্টদের লিস্ট দেখা (Role: student এবং Status: approved)
  Stream<QuerySnapshot> getApprovedStudents() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('status', isEqualTo: 'approved')
        .snapshots();
  }

  // ৩. প্রফেশনাল আইডি জেনারেশন এবং এপ্রুভাল লজিক
  Future<void> approveStudent(String docId) async {
    final counterRef = _db.collection('counters').doc('student_id');
    final studentRef = _db.collection('users').doc(docId);

    return _db.runTransaction((transaction) async {
      // স্টুডেন্টের ডাটা থেকে ডিপার্টমেন্ট কোড নেওয়া
      DocumentSnapshot studentSnap = await transaction.get(studentRef);
      
      if (!studentSnap.exists) {
        throw Exception("Student does not exist!");
      }

      String dept = (studentSnap.get('department') ?? "GEN").toString().toUpperCase();

      // কাউন্টার থেকে বর্তমান সিরিয়াল নেওয়া
      DocumentSnapshot counterSnap = await transaction.get(counterRef);
      int current = 0;
      
      if (counterSnap.exists) {
        // ফায়ারবেস থেকে ডাটা নেওয়ার সময় টাইপ চেক করা ভালো
        current = counterSnap.get('current') ?? 0;
      }

      int newSerial = current + 1;
      String year = DateTime.now().year.toString();
      
      // আইডি ফরম্যাট: NUBTK-CSE-2026-0001
      String formattedId = "NUBTK-$dept-$year-${newSerial.toString().padLeft(4, '0')}";

      // ১. কাউন্টার আপডেট করা (পরের স্টুডেন্টের জন্য সিরিয়াল বাড়িয়ে রাখা)
      transaction.set(
        counterRef, 
        {'current': newSerial}, 
        SetOptions(merge: true)
      );

      // ২. স্টুডেন্ট ডাটা আপডেট করা (Status, ID, এবং Timestamp)
      transaction.update(studentRef, {
        'status': 'approved',
        'digitalId': formattedId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ৪. স্টুডেন্ট রিজেক্ট করা
  Future<void> rejectStudent(String docId) async {
    await _db.collection('users').doc(docId).update({
      'status': 'rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}