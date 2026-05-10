//D:\projects\nubtk_pilot\lib\features\auth\auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ইউজার রেজিস্টার + রোল সেট
  Future<User?> register(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Firestore এ ইউজার ডেটা সেভ
      await _db.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'name': name,
        'email': email,
        'role': 'student', // ডিফল্ট স্টুডেন্ট রোল দেওয়া হলো
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      return result.user;
    } catch (e) {
      print("Register Error: ${e.toString()}");
      return null;
    }
  }

  // লগইন + রোল চেক (সংশোধিত)
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // 🔥 ফিক্স: লগইন এর আগে সব পুরান ক্যাশ ক্লিয়ার করে নাও
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Firestore থেকে রোল আনো
      DocumentSnapshot userDoc = await _db.collection('users').doc(result.user!.uid).get();
      
      if (!userDoc.exists) {
        return {'success': false, 'message': 'User data not found in Firestore'};
      }

      String role = userDoc['role'] ?? 'student';
      
      // লোকালে সেভ করো
      await prefs.setString('user_role_${result.user!.uid}', role);
      
      return {
        'success': true,
        'user': result.user,
        'role': role,
      };
    } on FirebaseAuthException catch (e) {
      // ফায়ারবেস এর নির্দিষ্ট এরর মেসেজ হ্যান্ডেল করা
      return {'success': false, 'message': e.message ?? 'Authentication failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // লগআউট ফাংশন - 🔥 ফিক্স: সব ক্যাশ ক্লিয়ার
  Future<void> logout() async {
    try {
      // 🔥 পুরা SharedPreferences ক্লিয়ার করে দাও। একটা কী ও রাখবা না।
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Firebase থেকে সাইন আউট করো
      await _auth.signOut();
    } catch (e) {
      print("Logout Error: ${e.toString()}");
    }
  }

  // ইউজার রোল পাওয়ার জন্য সঠিক ফাংশন
  Future<String> getRole(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // প্রথমে লোকাল থেকে ট্রাই করো
      String? localRole = prefs.getString('user_role_$uid');
      if (localRole != null) return localRole;

      // লোকালে না পেলে Firestore থেকে
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        String role = userDoc['role'] ?? 'student';
        await prefs.setString('user_role_$uid', role);
        return role;
      }
      return 'student';
    } catch (e) {
      return 'student';
    }
  }

  // বর্তমান ইউজারের রোল পাও
  Future<String> getCurrentUserRole() async {
    User? user = _auth.currentUser;
    if (user == null) return 'guest';
    return await getRole(user.uid);
  }

  // অ্যাডমিন দিয়ে রোল আপডেট
  Future<void> updateUserRole(String uid, String newRole) async {
    await _db.collection('users').doc(uid).update({'role': newRole});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role_$uid', newRole);
  }

  // 🔥 ফিক্স: স্টুডেন্ট রেজিস্ট্রেশন - students কালেকশনেও সেভ করবে
  Future<String?> registerStudent({
    required String email, 
    required String password, 
    required Map<String, dynamic> studentData
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      String uid = result.user!.uid;
      
      // 1. users কালেকশনে সেভ - লগইন এর জন্য
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'role': 'student',
        'createdAt': DateTime.now().toIso8601String(),
      });

      // 2. 🔥 students কালেকশনে সেভ - এডমিন এপ্রুভালের জন্য
      await _db.collection('students').doc(uid).set({
        ...studentData,
        'uid': uid,
        'email': email,
        'status': 'pending', // 🔥 এটা দিয়ে এডমিন ফিল্টার করবে
        'approved': false,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return null; // Null মানে কোন এরর নেই
    } catch (e) {
      return e.toString();
    }
  }
}