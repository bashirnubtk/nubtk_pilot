//C:\projects\Flutter project\nubtk_pilot\lib\features\ai_bot\ai_bot_screen.dart
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
        "image": _selectedImageBytes
      });
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      Map<String, dynamic>? studentData;
      if (user != null) {
        var snap = await FirebaseFirestore.instance.collection('students').doc(user.uid).get();
        studentData = snap.data();
      }

      final response = await AILogicCenter.analyzeInput(
        textInput: text.isNotEmpty ? text : null,
        imageBytes: _selectedImageBytes,
        studentData: studentData,
      );

      setState(() {
        _messages.add({
          "text": response['reply'],
          "suggestion": response['suggestion'],
          "isUser": false,
          "image": null
        });
        _selectedImageBytes = null;
      });
    } catch (e) {
      setState(() => _messages.add({"text": "এআই সাড়া দিচ্ছে না।", "isUser": false}));
    } finally {
      setState(() => _isLoading = false);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("NUBTK Pilot AI"), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildChatBubble(_messages[index]),
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
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg['image'] != null) Image.memory(msg['image'], height: 150),
            Text(msg['text'] ?? "", style: const TextStyle(fontSize: 15)),
            if (msg['suggestion'] != null)
              Text("\n💡 ${msg['suggestion']}", 
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.image, color: Colors.blue), onPressed: _pickImage),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: "প্রশ্ন লিখুন...", border: InputBorder.none),
            ),
          ),
          IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: () => _handleSend()),
        ],
      ),
    );
  }
}