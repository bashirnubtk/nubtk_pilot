import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ১. পেন্ডিং স্টুডেন্টদের স্ট্রীম আনা
  Stream<QuerySnapshot> getPendingStudents() {
    return _db
        .collection('students')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // ২. অ্যাপ্রুভড স্টুডেন্টদের স্ট্রীম আনা
  Stream<QuerySnapshot> getApprovedStudents() {
    return _db
        .collection('students')
        .where('status', isEqualTo: 'approved')
        .snapshots();
  }

  // ৩. স্টুডেন্ট অ্যাপ্রুভ করা + আইডি জেনারেশন + পেমেন্ট প্ল্যান (একসাথে)
  Future<void> approveStudent(String docId) async {
    final counterRef = _db.collection('counters').doc('student_id');

    return _db.runTransaction((transaction) async {
      // আইডি জেনারেশন লজিক
      DocumentSnapshot counterSnap = await transaction.get(counterRef);
      int current = counterSnap.exists ? (counterSnap.get('current') ?? 0) : 0;
      int newSerial = current + 1;
      String year = DateTime.now().year.toString();
      String formattedId = "NUBTK-$year-${newSerial.toString().padLeft(4, '0')}";

      // কাউন্টার আপডেট
      transaction.set(counterRef, {'current': newSerial}, SetOptions(merge: true));

      // স্টুডেন্ট ডাটা আপডেট (স্ট্যাটাস এবং ডিজিটাল আইডি)
      transaction.update(_db.collection('students').doc(docId), {
        'status': 'approved',
        'digitalId': formattedId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ৪. রিজেক্ট করার লজিক
  Future<void> rejectStudent(String id) async {
    await _db.collection('students').doc(id).update({
      'status': 'rejected',
    });
  }
}