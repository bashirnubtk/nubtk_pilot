// C:\projects\Flutter project\nubtk_pilot\lib\features\auth\auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // লগইন ফাংশন: স্টুডেন্ট এবং অ্যাডমিন উভয়ের জন্য
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

  // রোল চেক করার ফাংশন: লগইন এর পর ড্যাশবোর্ড ঠিক করার জন্য
  Future<String> getRole(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? (doc.get('role') ?? 'student') : 'student';
  }

  // নতুন রেজিস্ট্রেশন লজিক: ডাটা 'students' এবং 'users' উভয় কালেকশনে যাবে
  Future<String?> registerStudent({
    required String email,
    required String password,
    required Map<String, dynamic> studentData,
  }) async {
    try {
      // ১. ফায়ারবেস অথেন্টিকেশনে ইউজার তৈরি
      UserCredential res = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), 
          password: password.trim()
      );
      
      if (res.user != null) {
        final String uid = res.user!.uid;

        // ২. 'students' কালেকশনে বিস্তারিত ডাটা পাঠানো (অ্যাডমিন প্যানেলের জন্য)
        await _db.collection('students').doc(uid).set({
          ...studentData,
          'uid': uid,
          'email': email.trim(),
          'role': 'student',
          'status': 'pending', // অ্যাডমিন এই পেন্ডিং স্ট্যাটাস দেখে এপ্রুভ করবেন
          'approved': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // ৩. 'users' কালেকশনে বেসিক ডাটা পাঠানো (লগইন ও রোল ম্যানেজমেন্টের জন্য)
        await _db.collection('users').doc(uid).set({
          'uid': uid,
          'email': email.trim(),
          'role': 'student',
          'status': 'pending',
        });
        
        return null; // সফলতা বুঝাতে null রিটার্ন
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
    return "Registration Failed";
  }
}