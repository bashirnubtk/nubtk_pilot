import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // আপনার বিদ্যমান লগইন ফাংশন (নাম অপরিবর্তিত)
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; 
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return "এই জিমেইলটি নিবন্ধিত নয়।";
      if (e.code == 'wrong-password') return "ভুল পাসওয়ার্ড (ফোন নম্বর)!";
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // আপনার বিদ্যমান রোল চেক করার ফাংশন (নাম অপরিবর্তিত)
  Future<String> getRole(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? (doc.get('role') ?? 'student') : 'student';
  }

  // নতুন রেজিস্ট্রেশন লজিক ইন্টিগ্রেশন (Pending Status সহ)
  Future<String?> registerStudent({
    required String email,
    required String password,
    required Map<String, dynamic> studentData,
  }) async {
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), 
          password: password.trim()
      );
      
      if (res.user != null) {
        // এখানে ডাটা 'students' কালেকশনে যাচ্ছে অ্যাডমিন প্যানেলে দেখানোর জন্য
        await _db.collection('students').doc(res.user!.uid).set({
          ...studentData,
          'uid': res.user!.uid,
          'email': email.trim(),
          'role': 'student',
          'status': 'pending', // অ্যাডমিন এই 'pending' দেখে অ্যাপ্রুভ করবেন
          'approved': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // একইসাথে মূল 'users' কালেকশনেও ডাটা রাখা ভালো যাতে getRole কাজ করে
        await _db.collection('users').doc(res.user!.uid).set({
          'email': email.trim(),
          'role': 'student',
          'status': 'pending',
        });
        
        return null;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
    return "Registration Failed";
  }
}