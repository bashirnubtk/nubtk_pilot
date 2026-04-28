import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; 
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return "এই জিমেইলটি নিবন্ধিত নয়।";
      if (e.code == 'wrong-password') return "ভুল পাসওয়ার্ড (ফোন নম্বর)!";
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> getRole(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? (doc.get('role') ?? 'student') : 'student';
  }
}