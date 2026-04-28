// ai_bot_screen.dart

import 'dart:typed_data'; // ছবির ডাটার জন্য
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // ইমেজ পিকার
import 'package:provider/provider.dart';
import 'package:nubtk_pilot/features/home/languages/language_provider.dart';
import 'package:nubtk_pilot/features/ai_bot/finance_ai_handler.dart';
import '../../core/constants/app_strings.dart';

class AiBotScreen extends StatefulWidget {
  const AiBotScreen({super.key});

  @override
  State<AiBotScreen> createState() => _AiBotScreenState();
}

class _AiBotScreenState extends State<AiBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker(); // ইমেজ পিকার অবজেক্ট
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  Uint8List? _selectedImageBytes; // সিলেক্ট করা ছবির ডাটা

  // ছবি সিলেক্ট করার ফাংশন
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        // ছবি সিলেক্ট হলেই চ্যাটে দেখাব (লোকালি)
        _messages.add({"text": "[Image Attached]", "isUser": true, "image": bytes});
      });
      // ছবি সিলেক্ট হওয়ার পর অটোমেটিক AI-তে পাঠাব
      _handleSend(fromImage: true);
    }
  }

  // মেসেজ বা ছবি পাঠানোর ফাংশন (আপডেট করা হয়েছে)
  Future<void> _handleSend({bool fromImage = false}) async {
    String text = _controller.text.trim();
    
    // ছবি বা টেক্সট—যেকোনো একটা অবশ্যই থাকতে হবে
    if (text.isEmpty && _selectedImageBytes == null) return;

    if (!fromImage && text.isNotEmpty) {
       setState(() {
        _messages.add({"text": text, "isUser": true});
        _isLoading = true;
      });
    } else if (fromImage) {
      // যদি শুধু ছবি হয়, চ্যাট বাবল অলরেডি _pickImage-এ অ্যাড হয়েছে
       setState(() {
        _isLoading = true;
      });
    }
    
    _controller.clear();

    try {
      // FinanceAIHandler-কে টেক্সট এবং ছবি দুটোই দিচ্ছি
      final result = await FinanceAIHandler.analyzeInput(
        textInput: text.isNotEmpty ? text : null,
        imageBytes: _selectedImageBytes,
      );
      
      setState(() {
        _messages.add({
          "text": "${result['reply']}\n\n💡 Tip: ${result['suggestion']}",
          "isUser": false
        });
        _selectedImageBytes = null; // ছবি পাঠানো শেষ, তাই নাল করে দিই
      });
    } catch (e) {
      setState(() {
        _messages.add({"text": "এরর: AI-এর সাথে সংযোগ বিচ্ছিন্ন হয়েছে।", "isUser": false});
        _selectedImageBytes = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).languageCode;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppStrings.askAIBot[lang] ?? "NUBTK AI", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.indigo[900],
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg);
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          _buildInputArea(lang),
        ],
      ),
    );
  }

  // চ্যাট বাবল আপডেট (ছবি সাপোর্ট করার জন্য)
  Widget _buildChatBubble(Map<String, dynamic> msg) {
    bool isUser = msg["isUser"];
    Uint8List? imageBytes = msg["image"];

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? Colors.indigo : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageBytes != null) // যদি ছবি থাকে, তবে দেখাব
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(imageBytes, fit: BoxFit.cover, height: 150),
                ),
              ),
            Text(
              msg["text"],
              style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // ইনপুট এরিয়া আপডেট (ছবির বাটন যোগ করা হয়েছে)
  Widget _buildInputArea(String lang) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // ছবির বাটন (গ্যালারি)
            IconButton(
              icon: const Icon(Icons.image_outlined, color: Colors.indigo, size: 28),
              onPressed: _isLoading ? null : _pickImage,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                decoration: InputDecoration(
                  hintText: lang == 'bn' ? 'এখানে লিখুন...' : 'Type here...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.indigo, size: 28),
              onPressed: _isLoading ? null : () => _handleSend(fromImage: false),
            ),
          ],
        ),
      ),
    );
  }
}