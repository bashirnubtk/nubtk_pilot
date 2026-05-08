// D:\projects\nubtk_pilot\lib\features\ai_bot\ai_bot_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/api_service.dart';
import '../../services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  XFile? _selectedXFile; // সার্ভারে পাঠানোর জন্য

  late ApiService _apiService;
  late FirebaseService _firebaseService;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _firebaseService = FirebaseService();
  }

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

  // ইমেজ পিক - XFile ও রাখছি সার্ভারে পাঠানোর জন্য
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image!= null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedXFile = image;
      });
    }
  }

  // মেইন সেন্ড ফাংশন - সব লজিক এখানে
  Future<void> _handleSend() async {
    String text = _controller.text.trim();
    if (text.isEmpty && _selectedXFile == null) return;

    final tempImageBytes = _selectedImageBytes;
    final tempXFile = _selectedXFile;

    setState(() {
      _messages.add({
        "text": text.isEmpty? "ছবি পাঠানো হয়েছে" : text,
        "isUser": true,
        "image": tempImageBytes,
      });
      _isLoading = true;
      _selectedImageBytes = null;
      _selectedXFile = null;
    });
    _scrollToBottom();
    _controller.clear();

    try {
      final user = FirebaseAuth.instance.currentUser;
      String userRole = 'guest';
      Map<String, dynamic> contextData = {};

      // 1. ইউজার রোল + ডাটা লোড করো
      if (user!= null) {
        userRole = await _firebaseService.getUserRole();

        if (userRole == 'student') {
          contextData['paymentInfo'] = await _firebaseService.getStudentPaymentInfo(user.uid);
        }
        if (userRole == 'admin') {
          contextData['allStudents'] = await _firebaseService.getAllStudentsReport();
        }
      }

      // 2. রিসোর্স সবসময় লোড করো - AI যেন লিংক দিতে পারে
      contextData['resources'] = await _firebaseService.getAllResources();

      Map<String, dynamic> response;

      // 3. ছবি থাকলে ছবি + টেক্সট একসাথে পাঠাও, না হলে শুধু চ্যাট
      if (tempXFile!= null) {
        // ছবি + টেক্সট: Python Backend এ পাঠাও
        response = await _apiService.analyzeImage(tempXFile, user?.uid?? 'guest');
        if (response['success'] == true) {
          response['data'] = response['data']['result']?? response['data']['message']?? 'ছবি বিশ্লেষণ সম্পন্ন।';
        }
      } else {
        // শুধু টেক্সট: OpenRouter এ পাঠাও + Context সহ
        response = await _apiService.chatWithAI(text, userRole, contextData);
      }

      if (mounted) {
        setState(() {
          _messages.add({
            "text": response['data']?? response['error']?? "উত্তর পাওয়া যায়নি",
            "suggestion": null,
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
            "text": "দুঃখিত, একটি সমস্যা হয়েছে: $e",
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
                    onTap: () => setState(() {
                      _selectedImageBytes = null;
                      _selectedXFile = null;
                    }),
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
      child: Container(
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