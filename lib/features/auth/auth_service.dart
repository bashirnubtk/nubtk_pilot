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
      
      // Firestore এ ইউজার ডেটা সেভ, ডিফল্ট রোল 'pending'
      await _db.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'name': name,
        'email': email,
        'role': 'pending', // admin পরে approve করবে
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // লগইন + রোল চেক
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Firestore থেকে রোল আনো
      DocumentSnapshot userDoc = await _db.collection('users').doc(result.user!.uid).get();
      String role = userDoc['role'];
      
      // লোকালে সেভ করো, অফলাইনে লাগবে
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role_${result.user!.uid}', role);
      
      return {
        'user': result.user,
        'role': role, // admin, student, pending
      };
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // বর্তমান ইউজারের রোল পাও
  Future<String> getCurrentUserRole() async {
    User? user = _auth.currentUser;
    if (user == null) return 'guest';
    
    final prefs = await SharedPreferences.getInstance();
    // প্রথমে লোকাল থেকে ট্রাই করো
    String? localRole = prefs.getString('user_role_${user.uid}');
    if (localRole != null) return localRole;
    
    // লোকালে না পেলে Firebase থেকে
    DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get();
    return userDoc['role'] ?? 'student';
  }

  // অ্যাডমিন দিয়ে রোল আপডেট
  Future<void> updateUserRole(String uid, String newRole) async {
    await _db.collection('users').doc(uid).update({'role': newRole});
  }

  Future<dynamic> getRole(String uid) async {}

  Future<String?> registerStudent({required String email, required String password, required Map<String, dynamic> studentData}) async {
    return null;
  }
}