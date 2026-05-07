// D:\projects\nubtk_pilot\lib\features\ai_bot\ai_bot_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ai_logic_center.dart';
import 'ai_data_archive.dart';

class AiBotScreen extends StatefulWidget {
  const AiBotScreen({super.key});

  @override
  State<AiBotScreen> createState() => _AiBotScreenState();
}

class _AiBotScreenState extends State<AiBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImageBytes;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ইমেজ পিক করার পর অটো সেন্ড হবে না
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image!= null) {
      final bytes = await image.readAsBytes();
      setState(() => _selectedImageBytes = bytes);
    }
  }

  // মেইন সেন্ড ফাংশন - রোল ডিটেক্ট করে পাঠাবে
  Future<void> _handleSend() async {
    String text = _controller.text.trim();
    if (text.isEmpty && _selectedImageBytes == null) return;

    final tempImage = _selectedImageBytes; // API তে পাঠানোর জন্য কপি
    setState(() {
      _messages.add({
        "text": text.isEmpty? "ছবি পাঠানো হয়েছে" : text,
        "isUser": true,
        "image": tempImage,
      });
      _isLoading = true;
      _selectedImageBytes = null; // UI থেকে ক্লিয়ার
    });
    _scrollToBottom();
    _controller.clear();

    try {
      final user = FirebaseAuth.instance.currentUser;
      Map<String, dynamic>? studentData;
      String userRole = 'guest'; // ডিফল্ট গেস্ট

      // Firebase থেকে ইউজার রোল + ডাটা নাও
      if (user!= null) {
        try {
          var userSnap = await FirebaseFirestore.instance.collection('students').doc(user.uid).get();
          studentData = userSnap.data();
          if (studentData!= null) {
            userRole = studentData['role']?? 'student';
          }
        } catch (e) {
          debugPrint("Firebase Error: $e");
          // Firebase ফেইল করলে লোকাল আর্কাইভ থেকে টেস্ট ডাটা
          studentData = AIDataArchive.getStudentData("2021-1-60-001");
          userRole = 'student';
        }
      }

      final response = await AILogicCenter.analyzeInput(
        textInput: text,
        imageBytes: tempImage,
        studentData: studentData,
        userRole: userRole, // এইটা ইম্পর্ট্যান্ট
      );

      if (mounted) {
        setState(() {
          _messages.add({
            "text": response['reply']?? "উত্তর পাওয়া যায়নি",
            "suggestion": response['suggestion'],
            "isUser": false,
            "image": null,
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint("Handle Send Error: $e");
      if (mounted) {
        setState(() {
          _messages.add({
            "text": "দুঃখিত, একটি সমস্যা হয়েছে।",
            "isUser": false,
          });
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("NUBTK Pilot AI", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          // ইমেজ সিলেক্ট হলে প্রিভিউ দেখাবে
          if (_selectedImageBytes!= null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(_selectedImageBytes!, height: 100),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _selectedImageBytes = null),
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isUser = msg['isUser']?? false;
    return Align(
      alignment: isUser? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isUser? Colors.indigo[700] : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser? 16 : 0),
                bottomRight: Radius.circular(isUser? 0 : 16),
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg['image']!= null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(msg['image'], height: 200, width: double.infinity, fit: BoxFit.cover),
                  ),
                if (msg['image']!= null) const SizedBox(height: 8),
                Text(
                  msg['text']?? "",
                  style: TextStyle(color: isUser? Colors.white : Colors.black87, fontSize: 15),
                ),
              ],
            ),
          ),
          if (msg['suggestion']!= null && msg['suggestion'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(msg['suggestion'],
                        style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add_a_photo_rounded, color: Colors.indigo[900]),
              onPressed: _pickImage,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(25)),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: "কিছু জিজ্ঞেস করুন...", border: InputBorder.none),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.indigo[900],
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}