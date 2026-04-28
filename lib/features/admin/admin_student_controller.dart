import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../payment/waiver_engine.dart';
import '../payment/installment_generator.dart';

class AdminStudentController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ১. স্টুডেন্ট এপ্রুভাল লজিক
  Future<void> approveAndSendEmail({
    required String studentId,
    required String name,
    required String email,
  }) async {
    // আগের পেন্ডিং ডাটা সংগ্রহ
    DocumentSnapshot doc = await _db.collection('users').doc(studentId).get();
    if (!doc.exists) throw Exception("ডাটা পাওয়া যায়নি!");
    
    var data = doc.data() as Map<String, dynamic>;
    String phone = data['phone']?.toString().trim() ?? '12345678'; // ডিফল্ট পাসওয়ার্ড হিসেবে ফোন
    double hscGpa = double.tryParse(data['hscGpa']?.toString() ?? '0.0') ?? 0.0;
    String dept = (data['department'] ?? "CSE").toString().toUpperCase();

    // ক. ডিজিটাল আইডি তৈরি (সিরিয়াল মেইনটেইন করে)
    final counterRef = _db.collection('counters').doc('student_id');
    DocumentSnapshot counterSnap = await counterRef.get();
    int newSerial = (counterSnap.exists ? (counterSnap.get('current') ?? 0) : 0) + 1;
    
    String generatedId = "NUBTK-$dept-${DateTime.now().year}-${newSerial.toString().padLeft(4, '0')}";
    await counterRef.set({'current': newSerial}, SetOptions(merge: true));

    // খ. কিস্তি ক্যালকুলেশন (Waiver Engine ব্যবহার করে)
    double totalCourseFee = 450000; 
    double netPayable = WaiverEngine.calculateFinalAmount(totalFee: totalCourseFee, grade: hscGpa.toString());
    var installments = InstallmentGenerator.generateSemesterInstallments(finalAmount: netPayable);

    // গ. Firebase Auth-এ একাউন্ট তৈরি
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: phone, 
    );

    // ঘ. ফাইনাল ডাটা সেভ (সব লজিক এখানে ইন্টিগ্রেট করা হয়েছে)
    await _db.collection('users').doc(cred.user!.uid).set({
      ...data,
      'uid': cred.user!.uid,
      'digitalId': generatedId, 
      'role': 'student', // রোল সবসময় ছোট হাতের
      'status': 'approved', // স্ট্যাটাস এপ্রুভড
      'systemPassword': phone, // পরবর্তীতে স্টুডেন্ট লগইন করার জন্য ফোন নম্বরটি পাসওয়ার্ড
      'installments': installments.map((e) => {
        'id': e.id,
        'amount': e.amount,
        'dueDate': e.dueDate.toIso8601String(), // DateTime কে String এ কনভার্ট করা হলো (ভুল এড়াতে)
        'isPaid': false,
        'semester': e.semester
      }).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // আগের পেন্ডিং রিকোয়েস্ট ডিলিট করা
    await doc.reference.delete();
  }

  // ২. এডমিন পেমেন্ট কনফার্মেশন ফাংশন
  Future<void> makePayment(String studentUid, int index) async {
    try {
      DocumentReference ref = _db.collection('users').doc(studentUid);
      DocumentSnapshot snap = await ref.get();
      
      if (!snap.exists) throw Exception("স্টুডেন্ট খুঁজে পাওয়া যায়নি");

      List inst = List.from(snap.get('installments'));
      
      // নির্দিষ্ট ইনডেক্সের কিস্তিটি পেইড করা
      if (index >= 0 && index < inst.length) {
        inst[index]['isPaid'] = true;
        inst[index]['paymentDate'] = DateTime.now().toIso8601String(); // পেমেন্টের তারিখ সেভ রাখা
        
        await ref.update({
          'installments': inst,
        });
      } else {
        throw Exception("ভুল কিস্তি ইনডেক্স");
      }
    } catch (e) {
      throw Exception("পেমেন্ট আপডেট করতে সমস্যা হয়েছে: $e");
    }
  }
}