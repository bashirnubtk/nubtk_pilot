// D:\projects\nubtk_pilot\lib\services\firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. ইউজারের রোল বের করা: student/admin/guest
  Future<String> getUserRole() async {
    User? user = _auth.currentUser;
    if (user == null) return 'guest';
    
    var doc = await _db.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return doc.data()?['role'] ?? 'student';
    }
    return 'student';
  }

  // 2. স্টুডেন্টের ইনস্টলমেন্ট ডাটা
  Future<Map<String, dynamic>> getStudentPaymentInfo(String userId) async {
    var doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return {};
    
    var data = doc.data()!;
    int totalInstallment = data['totalInstallment'] ?? 5;
    int paidInstallment = data['paidInstallment'] ?? 0;
    int dueAmount = data['dueAmount'] ?? 0;
    
    return {
      'totalInstallment': totalInstallment,
      'paidInstallment': paidInstallment,
      'dueInstallment': totalInstallment - paidInstallment,
      'dueAmount': dueAmount,
    };
  }

  // 3. সব রিসোর্স পড়া - AI এখান থেকে লিংক দেবে
  Future<List<Map<String, dynamic>>> getAllResources() async {
    var snapshot = await _db.collection('resources').get();
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data()
    }).toList();
  }

  // 4. এডমিনের জন্য: সব স্টুডেন্টের রিপোর্ট
  Future<List<Map<String, dynamic>>> getAllStudentsReport() async {
    var snapshot = await _db.collection('users').where('role', isEqualTo: 'student').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}