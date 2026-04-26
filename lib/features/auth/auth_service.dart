import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// রোল এবং এপ্রুভাল স্ট্যাটাস চেক করা
  Future<String> getRole(String uid) async {
    try {
      // গুরুত্বপূর্ণ: আমরা শুধুমাত্র 'users' কালেকশন ব্যবহার করবো সবকিছুর জন্য
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        String role = data['role'] ?? 'unknown';
        String status = data['status'] ?? 'pending';

        // স্টুডেন্ট হলে এপ্রুভাল চেক করা
        if (role == 'student') {
          if (status == 'approved') {
            return 'student';
          } else {
            throw Exception("Your account is not approved yet.");
          }
        }
        
        // অ্যাডমিন হলে সরাসরি রিটার্ন
        if (role == 'admin') return 'admin';
      }

      return 'unknown';
    } catch (e) {
      if (e.toString().contains("not approved")) {
        rethrow;
      }
      return 'unknown';
    }
  }

  // লগইন লজিক
  Future<User?> login({required String email, required String password}) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), 
        password: password.trim(),
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // লগআউট
  Future<void> logout() async {
    await _auth.signOut();
  }
}