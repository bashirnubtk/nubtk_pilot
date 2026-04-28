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
      // ক. আগের পেন্ডিং ডাটা সংগ্রহ
      DocumentSnapshot doc = await _db.collection('users').doc(studentId).get();
      if (!doc.exists) throw Exception("ডাটা পাওয়া যায়নি!");
      
      var data = doc.data() as Map<String, dynamic>;
      String phone = data['phone']?.toString().trim() ?? '12345678'; 
      double hscGpa = double.tryParse(data['hscGpa']?.toString() ?? '0.0') ?? 0.0;
      String dept = (data['department'] ?? "CSE").toString().toUpperCase();

      // খ. ডিজিটাল আইডি তৈরি (সিরিয়াল মেইনটেইন করে)
      final counterRef = _db.collection('counters').doc('student_id');
      DocumentSnapshot counterSnap = await counterRef.get();
      int newSerial = (counterSnap.exists ? (counterSnap.get('current') ?? 0) : 0) + 1;
      
      String generatedId = "NUBTK-$dept-${DateTime.now().year}-${newSerial.toString().padLeft(4, '0')}";
      await counterRef.set({'current': newSerial}, SetOptions(merge: true));

      // গ. কিস্তি ও ওয়েভার ক্যালকুলেশন
      double totalCourseFee = 450000; 
      double netPayable = WaiverEngine.calculateFinalAmount(totalFee: totalCourseFee, grade: hscGpa.toString());
      double waiverAmount = totalCourseFee - netPayable; // ওয়েভারের পরিমাণ
      var installments = InstallmentGenerator.generateSemesterInstallments(finalAmount: netPayable);

      // ঘ. Firebase Auth-এ একাউন্ট তৈরি
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: phone, 
      );

      // ঙ. ফাইনাল ডাটা সেভ (সব লজিক এখানে ইন্টিগ্রেট করা হয়েছে)
      await _db.collection('users').doc(cred.user!.uid).set({
        ...data,
        'uid': cred.user!.uid,
        'digitalId': generatedId, 
        'role': 'student', 
        'status': 'approved', 
        'approved': true, // আপডেট অনুযায়ী যোগ করা হলো
        'systemPassword': phone, 
        'waiverAmount': waiverAmount.toString(), // ইমেইলের জন্য সেভ রাখা হলো
        'installments': installments.map((e) => {
          'id': e.id,
          'amount': e.amount,
          'dueDate': e.dueDate.toIso8601String(), 
          'isPaid': false,
          'semester': e.semester
        }).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // চ. ইমেইল বডি সাজানো (আপনার আপডেট অনুযায়ী)
      final String subject = "Registration Approved - Welcome to NUBTK Portal";
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

      // এখানে আপনার ইমেইল সার্ভিস কল করুন (যদি থাকে)
      // emailService.sendEmail(to: email, subject: subject, body: body);
      print("Email Prepared: \n$body"); // টেস্টিং এর জন্য

      // ছ. আগের পেন্ডিং রিকোয়েস্ট ডিলিট করা
      await doc.reference.delete();

    } catch (e) {
      print("Approval Error: $e");
      throw Exception("এপ্রুভাল প্রসেস ব্যর্থ হয়েছে: $e");
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
      } else {
        throw Exception("ভুল কিস্তি ইনডেক্স");
      }
    } catch (e) {
      throw Exception("পেমেন্ট আপডেট করতে সমস্যা হয়েছে: $e");
    }
  }
}