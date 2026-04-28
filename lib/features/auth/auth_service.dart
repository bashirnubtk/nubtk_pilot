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

  /// আপডেট করা লগইন লজিক
  Future<String?> login(String identifier, String password) async {
    try {
      String emailToUse = identifier;
      Map<String, dynamic>? userData;

      // ১. ডিজিটাল আইডি থেকে ইমেইল এবং অন্যান্য তথ্য খুঁজে বের করা
      if (!identifier.contains('@')) {
        final querySnapshot = await _db
            .collection('users')
            .where('digitalId', isEqualTo: identifier.trim())
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          return "ভুল ডিজিটাল আইডি! এই আইডি দিয়ে কোনো স্টুডেন্ট পাওয়া যায়নি।";
        }
        
        userData = querySnapshot.docs.first.data();
        emailToUse = userData['email'];
      }

      // ২. ফায়ারবেস অথ দিয়ে লগইন
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailToUse.trim(),
        password: password.trim(),
      );

      // ৩. নতুন চাহিদা অনুযায়ী ফায়ারবেস কনসোলের তথ্য আপডেট করা (অটোমেশন)
      if (userCredential.user != null) {
        // যদি ডিজিটাল আইডি দিয়ে লগইন না করে সরাসরি ইমেইল দিয়ে করে, তবে ডাটাবেজ থেকে তথ্য আবার নিতে হবে
        if (userData == null) {
          final doc = await _db.collection('users').doc(userCredential.user!.uid).get();
          if (doc.exists) userData = doc.data() as Map<String, dynamic>;
        }

        if (userData != null) {
          // ফায়ারবেস অথ প্রোফাইলে নাম (সাথে ডিজিটাল আইডি) সেট করা
          await userCredential.user!.updateDisplayName("${userData['name']} (${userData['digitalId']})");
        }
      }

      return null; // লগইন সফল
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return "এই ইমেইলটি নিবন্ধিত নয়।";
      if (e.code == 'wrong-password') return "ভুল পাসওয়ার্ড বা ফোন নাম্বার!";
      if (e.code == 'invalid-email') return "ইমেইল বা ডিজিটাল আইডির ফরম্যাট সঠিক নয়।";
      return "লগইন এরর: ${e.message}";
    } catch (e) {
      return e.toString();
    }
  }

  // লগআউট
  Future<void> logout() async {
    await _auth.signOut();
  }
}