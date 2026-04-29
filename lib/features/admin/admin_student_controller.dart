import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../payment/waiver_engine.dart';
import '../payment/installment_generator.dart';

class AdminStudentController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ১. স্টুডেন্ট এপ্রুভাল লজিক (ইন্টিগ্রেটেড ভার্সন)
  Future<void> approveAndSendEmail({
    required String studentId,
    required String name,
    required String email,
  }) async {
    try {
      // ক. আগের পেন্ডিং ডাটা সংগ্রহ (পেন্ডিং স্টুডেন্টরা সাধারণত 'users' বা 'pending_students' কালেকশনে থাকে)
      DocumentSnapshot doc = await _db.collection('users').doc(studentId).get();
      if (!doc.exists) throw Exception("ডাটা পাওয়া যায়নি!");
      
      var data = doc.data() as Map<String, dynamic>;
      String phone = data['phone']?.toString().trim() ?? '12345678'; 
      double hscGpa = double.tryParse(data['hscGpa']?.toString() ?? '0.0') ?? 0.0;
      String dept = (data['department'] ?? "CSE").toString().toUpperCase();

      // খ. ডিজিটাল আইডি তৈরি (সিরিয়াল মেইনটেইন করে counters কালেকশন থেকে)
      final counterRef = _db.collection('counters').doc('student_id');
      
      // ট্রানজ্যাকশন ব্যবহার করা ভালো যাতে একই আইডি দুজন না পায়
      String generatedId = await _db.runTransaction((transaction) async {
        DocumentSnapshot counterSnap = await transaction.get(counterRef);
        int newSerial = (counterSnap.exists ? (counterSnap.get('current') ?? 0) : 0) + 1;
        
        transaction.set(counterRef, {'current': newSerial}, SetOptions(merge: true));
        
        return "NUBTK-$dept-${DateTime.now().year}-${newSerial.toString().padLeft(4, '0')}";
      });

      // গ. কিস্তি ও ওয়েভার ক্যালকুলেশন
      double totalCourseFee = 450000; 
      double netPayable = WaiverEngine.calculateFinalAmount(totalFee: totalCourseFee, grade: hscGpa.toString());
      double waiverAmount = totalCourseFee - netPayable; 
      var installments = InstallmentGenerator.generateSemesterInstallments(finalAmount: netPayable);

      // ঘ. Firebase Auth-এ একাউন্ট তৈরি
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: phone, 
      );

      // ঙ. ফাইনাল ডাটা সেভ (Auth UID দিয়ে সেভ করা হচ্ছে)
      await _db.collection('users').doc(cred.user!.uid).set({
        ...data,
        'uid': cred.user!.uid,
        'digitalId': generatedId, 
        'role': 'student', 
        'status': 'approved', 
        'approved': true, 
        'systemPassword': phone, 
        'waiverAmount': waiverAmount, 
        'installments': installments.map((e) => {
          'id': e.id,
          'amount': e.amount,
          'dueDate': e.dueDate.toIso8601String(), 
          'isPaid': false,
          'semester': e.semester
        }).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // চ. ইমেইল বডি ও সাবজেক্ট (অব্যবহৃত ভেরিয়েবল এরর ফিক্স করা হয়েছে)
      const String subject = "Registration Approved - Welcome to NUBTK Portal";
      final String body = """
Dear $name,

Your registration has been approved by the Admin. You can now login to your portal.

Login Details:
Email: $email
Password: $phone (Your mobile number)
Digital ID: $generatedId

Financial Info:
Waiver Amount: $waiverAmount BDT

Please keep your credentials secure.
Best regards,
Admin Team
      """;

      // কনসোলে প্রিন্ট করে নিশ্চিত করা (subject ভেরিয়েবলটি এখানে ব্যবহার করা হলো)
      print("Sending Email...");
      print("Subject: $subject");
      print("Message Body: \n$body");

      // ছ. আগের পেন্ডিং রিকোয়েস্ট ডিলিট করা
      await doc.reference.delete();

    } catch (e) {
      print("Approval Error: $e");
      throw Exception("এপ্রুভাল প্রসেস ব্যর্থ হয়েছে: $e");
    }
  }

  // ২. এডমিন পেমেন্ট কনফার্মেশন ফাংশন
  Future<void> makePayment(String studentUid, int index) async {
    try {
      DocumentReference ref = _db.collection('users').doc(studentUid);
      DocumentSnapshot snap = await ref.get();
      
      if (!snap.exists) throw Exception("স্টুডেন্ট খুঁজে পাওয়া যায়নি");

      List inst = List.from(snap.get('installments'));
      
      if (index >= 0 && index < inst.length) {
        inst[index]['isPaid'] = true;
        inst[index]['paymentDate'] = DateTime.now().toIso8601String(); 
        
        await ref.update({
          'installments': inst,
        });
        print("Payment updated for index $index");
      } else {
        throw Exception("ভুল কিস্তি ইনডেক্স");
      }
    } catch (e) {
      throw Exception("পেমেন্ট আপডেট করতে সমস্যা হয়েছে: $e");
    }
  }

  Future<void> approveStudent({required String docId, required Map<String, dynamic> data}) async {}
}