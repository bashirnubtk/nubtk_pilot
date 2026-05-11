//D:\projects\nubtk_pilot\lib\features\auth\auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> register(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      await _db.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'name': name,
        'email': email,
        'role': 'student',
        'createdAt': DateTime.now().toIso8601String(),
      });
      return result.user;
    } catch (e) {
      print("Register Error: ${e.toString()}");
      return null;
    }
  }

  // 🔥 ফিক্স: Admin নাকি Student চেক করে পাসওয়ার্ড ক্লিন করো
  Future<Map<String, dynamic>> login(String email, String password, {required bool isAdmin}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      String finalPassword = password.trim();

      // 🔥 শুধু Student হলে পাসওয়ার্ড ক্লিন করো। Admin হলে করবা না।
      if (!isAdmin) {
        finalPassword = password.replaceAll(RegExp(r'[\s\-\+]'), '').replaceAll('88', '');
        if (finalPassword.length > 11) {
          finalPassword = finalPassword.substring(finalPassword.length - 11);
        }
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: finalPassword
      );

      DocumentSnapshot userDoc = await _db.collection('users').doc(result.user!.uid).get();
      if (!userDoc.exists) {
        return {'success': false, 'message': 'User data not found in Firestore'};
      }
      String role = userDoc['role'] ?? 'student';
      await prefs.setString('user_role_${result.user!.uid}', role);
      return {'success': true, 'user': result.user, 'role': role};
    } on FirebaseAuthException catch (e) {
      String msg = 'Login failed';
      if (e.code == 'user-not-found') msg = 'এই ইমেইলে কোনো একাউন্ট নাই';
      if (e.code == 'wrong-password') msg = isAdmin ? 'পাসওয়ার্ড ভুল' : 'পাসওয়ার্ড ভুল। ফোন নম্বর ব্যবহার করুন';
      if (e.code == 'invalid-email') msg = 'ইমেইল ঠিক নাই';
      return {'success': false, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _auth.signOut();
    } catch (e) {
      print("Logout Error: ${e.toString()}");
    }
  }

  Future<String> getRole(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? localRole = prefs.getString('user_role_$uid');
      if (localRole != null) return localRole;
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

  Future<String> getCurrentUserRole() async {
    User? user = _auth.currentUser;
    if (user == null) return 'guest';
    return await getRole(user.uid);
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    await _db.collection('users').doc(uid).update({'role': newRole});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role_$uid', newRole);
  }

  Future<String?> registerStudent({
    required String email,
    required String password,
    required Map<String, dynamic> studentData
  }) async {
    try {
      String cleanPassword = password.replaceAll(RegExp(r'[\s\-\+]'), '').replaceAll('88', '');
      if (cleanPassword.length > 11) {
        cleanPassword = cleanPassword.substring(cleanPassword.length - 11);
      }
      if (cleanPassword.length != 11) {
        return 'ফোন নম্বর ১১ ডিজিটের হতে হবে';
      }
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: cleanPassword
      );
      String uid = result.user!.uid;
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'email': email.trim(),
        'name': studentData['fullName'] ?? 'Student',
        'role': 'student',
        'createdAt': DateTime.now().toIso8601String(),
      });
      await _db.collection('students').doc(uid).set({
        ...studentData,
        'uid': uid,
        'email': email.trim(),
        'phone': cleanPassword,
        'status': 'pending',
        'approved': false,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return 'এই ইমেইল দিয়ে আগেই রেজিস্ট্রেশন করা আছে';
      if (e.code == 'weak-password') return 'পাসওয়ার্ড কমপক্ষে ৬ ডিজিটের হতে হবে';
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}