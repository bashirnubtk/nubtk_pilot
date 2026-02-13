import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // রেজিস্ট্রেশন করার সময় সরাসরি ফায়ারবেস অথেন্টিকেশনে ইউজার তৈরি হবে
  Future<String?> registerStudent({
    required String fullName,
    required String email,
    required String phone,
    required String department,
    required String digitalId,
    required String photoUrl,
  }) async {
    try {
      // ইউজার তৈরি করা (পাসওয়ার্ড হিসেবে ডিজিটাল আইডি ব্যবহার করা হচ্ছে)
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: digitalId);

      // ফায়ারস্টোরে স্টুডেন্টের বিস্তারিত তথ্য সেভ করা
      await _db.collection('students').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'department': department,
        'digitalId': digitalId,
        'photoUrl': photoUrl,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null; // সফলতা
    } on FirebaseAuthException catch (e) {
      return e.message; // এরর মেসেজ
    }
  }

  // লগইন লজিক
  Future<User?> login({required String email, required String password}) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // রোল চেক করা (স্টুডেন্ট নাকি এডমিন)
  Future<String> getRole(String uid) async {
    // প্রথমে স্টুডেন্ট কালেকশনে চেক করবে
    DocumentSnapshot doc = await _db.collection('students').doc(uid).get();
    if (doc.exists) return 'student';

    // তারপর এডমিন কালেকশনে চেক করবে
    DocumentSnapshot adminDoc = await _db.collection('admins').doc(uid).get();
    if (adminDoc.exists) return 'admin';

    return 'unknown';
  }

  // লগআউট
  Future<void> logout() async {
    await _auth.signOut();
  }
}