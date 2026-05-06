import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ai_logic_center.dart';

class AiBotScreen extends StatefulWidget {
  const AiBotScreen({super.key});

  @override
  State<AiBotScreen> createState() => _AiBotScreenState();
}

class _AiBotScreenState extends State<AiBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImageBytes;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _selectedImageBytes = bytes);
      _handleSend(fromImage: true);
    }
  }

  Future<void> _handleSend({bool fromImage = false}) async {
    String text = _controller.text.trim();
    if (text.isEmpty && _selectedImageBytes == null) return;

    setState(() {
      _messages.add({
        "text": fromImage ? "[ছবি বিশ্লেষণ করা হচ্ছে...]" : text,
        "isUser": true,
        "image": _selectedImageBytes,
      });
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      Map<String, dynamic>? studentData;
      Map<String, dynamic> systemContext = {};

      // ১. পাবলিক তথ্য লোড (ইউনিভার্সিটির সাধারণ ডাটা)
      var publicSnap = await FirebaseFirestore.instance
          .collection('settings')
          .doc('university_info')
          .get();
      systemContext['publicInfo'] =
          publicSnap.data()?['raw_data'] ?? "তথ্য পাওয়া যায়নি।";

      if (user != null) {
        // ২. ইউজারের নিজের ডাটা রিড করা
        var userSnap = await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .get();
        studentData = userSnap.data();
        String role = studentData?['role'] ?? 'student';

        if (role == 'admin') {
          // অ্যাডমিনের জন্য ডাইনামিক ডাটা রিড (ডিপার্টমেন্ট অনুযায়ী স্টুডেন্ট সংখ্যা)
          var allStudents = await FirebaseFirestore.instance
              .collection('students')
              .get();

          Map<String, int> deptCount = {};
          for (var doc in allStudents.docs) {
            String dept = doc.data()['department'] ?? 'Unknown';
            deptCount[dept] = (deptCount[dept] ?? 0) + 1;
          }

          systemContext['adminStats'] = {
            "total_students": allStudents.docs.length,
            "department_breakdown": deptCount,
            "pending_approvals": allStudents.docs
                .where((d) => d.data()['approved'] == false)
                .length,
          };
        } else {
          // ৩. স্টুডেন্টের নিজের পেমেন্ট ডাটা রিড করা
          var paymentSnap = await FirebaseFirestore.instance
              .collection('payments')
              .where('userId', isEqualTo: user.uid)
              .get();

          double totalPaid = 0;
          for (var doc in paymentSnap.docs) {
            totalPaid += (doc.data()['amount'] ?? 0).toDouble();
          }

          systemContext['studentFees'] = {
            "completed_installments": paymentSnap.docs.length,
            "total_paid": totalPaid,
            "department": studentData?['department'],
          };
        }
      }

      // ৪. এআই-এর কাছে সব ডাটা পাঠানো
      final response = await AILogicCenter.analyzeInput(
        textInput: text.isNotEmpty ? text : null,
        imageBytes: _selectedImageBytes,
        studentData: studentData,
        systemContext: systemContext,
      );

      setState(() {
        _messages.add({
          "text": response['reply'],
          "suggestion": response['suggestion'],
          "isUser": false,
          "image": null,
        });
        _selectedImageBytes = null;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "text": "সিস্টেম ত্রুটি। আবার চেষ্টা করুন।",
          "isUser": false,
        });
      });
    } finally {
      setState(() => _isLoading = false);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "NUBTK Pilot AI",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _buildChatBubble(_messages[index]),
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    bool isUser = msg['isUser'] ?? false;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[600] : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(isUser ? 15 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg['image'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    msg['image'],
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Text(
              msg['text'] ?? "",
              style: TextStyle(
                fontSize: 15,
                color: isUser ? Colors.white : Colors.black87,
              ),
            ),
            if (msg['suggestion'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "💡 ${msg['suggestion']}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image_outlined, color: Colors.blue),
            onPressed: _pickImage,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "আপনার প্রশ্নটি লিখুন...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: Colors.blue),
            onPressed: () => _handleSend(),
          ),
        ],
      ),
    );
  }
}
