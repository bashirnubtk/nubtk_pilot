import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // রেজিস্ট্রেশন: আপনার আগের সব প্যারামিটার ঠিক রাখা হয়েছে
  Future<String?> registerStudent({
    required String fullName,
    required String email,
    required String phone,
    required String department,
    required String digitalId,
    required String photoUrl,
  }) async {
    try {
      // পাসওয়ার্ড হিসেবে ডিজিটাল আইডি ব্যবহার করা হচ্ছে
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: digitalId);

      await _db.collection('students').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'department': department,
        'digitalId': digitalId,
        'photoUrl': photoUrl,
        'status': 'pending', // ডিফল্ট পেন্ডিং
        'role': 'student',   // রোল ডিফাইন করা হলো
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
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

  // রোল চেক করা
  Future<String> getRole(String uid) async {
    DocumentSnapshot doc = await _db.collection('students').doc(uid).get();
    if (doc.exists) return 'student';

    DocumentSnapshot adminDoc = await _db.collection('admins').doc(uid).get();
    if (adminDoc.exists) return 'admin';

    return 'unknown';
  }

  // লগআউট
  Future<void> logout() async {
    await _auth.signOut();
  }
}