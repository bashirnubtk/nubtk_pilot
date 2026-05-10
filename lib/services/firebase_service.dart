// D:\projects\nubtk_pilot\lib\services\firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔥 ফিক্স: গেস্ট/লগআউট সেফ রোল চেক
  Future<String> getUserRole() async {
    final user = _auth.currentUser;
    
    // ইউজার লগইন না থাকলে সরাসরি guest
    if (user == null) {
      debugPrint('No user logged in -> guest');
      return 'guest';
    }

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      
      // ডকুমেন্ট না থাকলে guest
      if (!doc.exists) {
        debugPrint('User doc not found -> guest');
        return 'guest';
      }

      final data = doc.data();
      // role ফিল্ড না থাকলে guest
      if (data == null || !data.containsKey('role')) {
        debugPrint('Role field missing -> guest');
        return 'guest';
      }
      
      final role = data['role'] as String;
      debugPrint('User role from DB: $role');
      
      // শুধু student বা admin ভ্যালিড, বাকি সব guest
      if (role == 'admin' || role == 'student') {
        return role;
      } else {
        return 'guest';
      }
    } catch (e) {
      debugPrint("getUserRole error: $e -> guest");
      return 'guest'; // এরর হলেও guest
    }
  }

  // ইউজার প্রোফাইল
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      return doc.data();
    } catch (e) {
      debugPrint("getUserProfile error: $e");
      return null;
    }
  }

  // স্টুডেন্ট পেমেন্ট ইনফো
  Future<Map<String, dynamic>?> getStudentPaymentInfo(String uid) async {
    try {
      final doc = await _db.collection('students').doc(uid).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return {
        'name': data['name'] ?? '',
        'studentId': data['studentId'] ?? '',
        'installments': data['installments'] ?? [],
        'paymentStatus': data['paymentStatus'] ?? 'pending',
        'totalDue': data['totalDue'] ?? 0,
        'totalPaid': data['totalPaid'] ?? 0,
      };
    } catch (e) {
      debugPrint("getStudentPaymentInfo error: $e");
      return null;
    }
  }

  // সব স্টুডেন্ট রিপোর্ট - এডমিনের জন্য
  Future<List<Map<String, dynamic>>> getAllStudentsReport() async {
    try {
      final snapshot = await _db.collection('students').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'name': data['name'] ?? '',
          'studentId': data['studentId'] ?? '',
          'paymentStatus': data['paymentStatus'] ?? 'pending',
          'totalDue': data['totalDue'] ?? 0,
          'totalPaid': data['totalPaid'] ?? 0,
        };
      }).toList();
    } catch (e) {
      debugPrint("getAllStudentsReport error: $e");
      return [];
    }
  }

  // সব রিসোর্স
  Future<List<Map<String, dynamic>>> getAllResources() async {
    try {
      final snapshot = await _db.collection('resources').orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'description': data['description'] ?? '',
          'url': data['url'] ?? '',
          'category': data['category'] ?? '',
          'createdAt': data['createdAt'],
        };
      }).toList();
    } catch (e) {
      debugPrint("getAllResources error: $e");
      return [];
    }
  }

  // রিসোর্স অ্যাড - এডমিন
  Future<void> addResource(Map<String, dynamic> resourceData) async {
    try {
      await _db.collection('resources').add({
        ...resourceData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("addResource error: $e");
      rethrow;
    }
  }

  // রিসোর্স ডিলিট - এডমিন
  Future<void> deleteResource(String docId) async {
    try {
      await _db.collection('resources').doc(docId).delete();
    } catch (e) {
      debugPrint("deleteResource error: $e");
      rethrow;
    }
  }

  // পেমেন্ট আপডেট - এডমিন
  Future<void> updateStudentPayment(String studentId, Map<String, dynamic> paymentData) async {
    try {
      await _db.collection('students').doc(studentId).update(paymentData);
    } catch (e) {
      debugPrint("updateStudentPayment error: $e");
      rethrow;
    }
  }

  // AI রেজাল্ট সেভ
  Future<void> saveAnalysisResult(String userId, Map<String, dynamic> result) async {
    try {
      await _db.collection('results').add({
        'userId': userId,
        'result': result,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("saveAnalysisResult error: $e");
      rethrow;
    }
  }
}