import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../payment/waiver_engine.dart';
import '../payment/installment_generator.dart';
import '../auth/email_service.dart';

class AdminStudentController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ১. এপ্রুভ এবং ইমেইল পাঠানোর মেইন এন্ট্রি পয়েন্ট
  Future<void> approveAndSendEmail({
    required String studentId,
    required String name,
    required String email,
  }) async {
    // 'users' কালেকশন থেকে স্টুডেন্টের ডাটা (টেম্পোরারি আইডি/ইমেইল ফরম্যাট দিয়ে) চেক করা হচ্ছে
    DocumentSnapshot doc = await _db.collection('users').doc(studentId).get();
    
    if (!doc.exists) {
      throw Exception("Student record not found in 'users' collection!");
    }
    
    return processFullApproval(doc);
  }

  /// ২. সম্পূর্ণ এপ্রুভাল প্রসেস: আইডি জেনারেশন এবং ডাটা মাইগ্রেশন (Temp ID to UID)
  Future<void> processFullApproval(DocumentSnapshot studentDoc) async {
    try {
      var data = studentDoc.data() as Map<String, dynamic>;
      String name = data['fullName'] ?? 'Student';
      String email = data['email'] ?? '';
      String rawPhone = data['phone']?.toString().trim() ?? '';
      
      if (rawPhone.isEmpty) {
        throw Exception("Phone number is missing! Cannot set password.");
      }
      
      double hscGpa = (data['hscGpa'] ?? 0.0).toDouble(); 
      String dept = (data['department'] ?? "GEN").toString().toUpperCase();

      // ১. পেমেন্ট ক্যালকুলেশন
      double totalCourseFee = 450000; 
      double waiverPercent = WaiverEngine.calculateWaiverPercent(hscGpa.toString());
      double netPayable = WaiverEngine.calculateFinalAmount(totalFee: totalCourseFee, grade: hscGpa.toString());
      double totalWaiverAmount = totalCourseFee - netPayable;

      // ২. আইডি জেনারেশন প্রিপারেশন
      final counterRef = _db.collection('counters').doc('student_id');
      String generatedId = "";

      // ৩. কিস্তি জেনারেশন
      var installments = InstallmentGenerator.generateSemesterInstallments(finalAmount: netPayable);

      // ৪. ফায়ারবেস ট্রানজ্যাকশন: আইডি তৈরি এবং টেম্পোরারি ডকুমেন্ট আপডেট
      await _db.runTransaction((transaction) async {
        DocumentSnapshot counterSnap = await transaction.get(counterRef);
        int current = counterSnap.exists ? (counterSnap.get('current') ?? 0) : 0;
        int newSerial = current + 1;
        
        String year = DateTime.now().year.toString();
        generatedId = "NUBTK-$dept-$year-${newSerial.toString().padLeft(4, '0')}";

        transaction.update(studentDoc.reference, {
          'id': generatedId,
          'digitalId': generatedId,
          'systemPassword': rawPhone, // এখন পাসওয়ার্ড হবে ফোন নাম্বার
          'status': 'approved',
          'totalFee': totalCourseFee,
          'waiverPercent': waiverPercent,
          'netPayable': netPayable,
          'approvedAt': FieldValue.serverTimestamp(),
          'installments': installments.map((e) => {
            'id': e.id,
            'amount': e.amount,
            'dueDate': e.dueDate, 
            'isPaid': false,
            'semester': e.semester
          }).toList(),
        });

        transaction.set(counterRef, {'current': newSerial}, SetOptions(merge: true));
      });

      // ৫. Firebase Authentication-এ অ্যাকাউন্ট তৈরি এবং ডাটা মাইগ্রেশন (UID-তে স্থানান্তর)
      try {
        // নতুন ইউজার ক্রিয়েট করা - পাসওয়ার্ড হিসেবে ফোন নাম্বার ব্যবহার হচ্ছে
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: rawPhone, 
        );

        String newUid = userCredential.user!.uid;

        // আপডেট হওয়া টেম্পোরারি ডকুমেন্ট থেকে ফ্রেশ ডাটা নেওয়া
        var updatedDoc = await studentDoc.reference.get();
        var studentData = updatedDoc.data() as Map<String, dynamic>;
        
        studentData['uid'] = newUid; 
        studentData['id'] = generatedId; 

        // নতুন UID নামে ডকুমেন্ট তৈরি করা
        await _db.collection('users').doc(newUid).set(studentData);

        // পুরনো টেম্পোরারি ডকুমেন্টটি ডিলিট করে দেওয়া
        await studentDoc.reference.delete();

        print("Auth account created and Firestore updated with UID: $newUid");
      } on FirebaseAuthException catch (authError) {
        print("Auth Error: ${authError.message}");
        if (authError.code == 'email-already-in-use') {
           throw Exception("This email is already registered in Authentication.");
        }
      }

      // ৬. ইমেইল পাঠানো (পাসওয়ার্ড হিসেবে rawPhone পাঠানো হচ্ছে)
      await EmailService.sendApprovalEmail(
        recipientEmail: email,
        studentName: name,
        digitalId: generatedId,
        password: rawPhone,
        totalFee: totalCourseFee,
        waiver: totalWaiverAmount,
        netPayable: netPayable,
      );

      print("Process Completed: Student $generatedId is now active.");

    } catch (e) {
      print("Global Approval Error: $e");
      rethrow; 
    }
  }
}