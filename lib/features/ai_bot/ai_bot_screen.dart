// D:\projects\nubtk_pilot\lib\features\ai_bot\ai_bot_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/api_service.dart';
import '../../services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../payment/waiver_engine.dart'; // 🔥 ডিলিট করলাম - গেস্টে লাগবে না

class AiBotScreen extends StatefulWidget {
  final bool isGuestMode;
  const AiBotScreen({super.key, this.isGuestMode = false});

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
  XFile? _selectedXFile;

  late ApiService _apiService;
  late FirebaseService _firebaseService;

  @override
  void initState() {
    super.initState();
    _initServices();
    // 🔥 ফিক্স: গেস্ট হলে শুরুতেই ওয়েলকাম মেসেজ দেখাও
    if (widget.isGuestMode) {
      _messages.add({
        "text": "আসালামু আলাইকুম! 👋\nআমি NUBTK PILOT AI।\n\nভর্তি, ওয়েভার, কোর্স সম্পর্কে জানতে চান?\nলগইন করলে পেমেন্ট ও রিসোর্স দেখতে পারবেন।",
        "isUser": false,
        "image": null,
      });
    }
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

  // 🔥 ফিক্স: WaiverEngine বাদ, শুধু সেফ টেক্সট
  String _getGuestReply(String text) {
    String lowerText = text.toLowerCase().trim();

    // 1. প্রথমে সৌজন্যতা - খালি মেসেজ বা হাই/হ্যালো
    if (lowerText.isEmpty || lowerText == 'hi' || lowerText == 'hello' ||
        lowerText.contains('হাই') || lowerText.contains('হ্যালো') ||
        lowerText.contains('কেমন') || lowerText.contains('আছ') ||
        lowerText.contains('assalamu') || lowerText.contains('সালাম')) {
      return "ওয়ালাইকুম আসসালাম! 😊\n\nআমি ভর্তি, ওয়েভার, কোর্স সম্পর্কে হেল্প করতে পারি।\n\nকী জানতে চান?";
    }

    // 2. ওয়েভার/খরচ - 🔥 হিসাব না, শুধু পলিসি
    if (lowerText.contains('ওয়েভার') || lowerText.contains('খরচ') || lowerText.contains('waiver') ||
        lowerText.contains('টাকা') || lowerText.contains('ফি') || lowerText.contains('cost') ||
        lowerText.contains('ssc') || lowerText.contains('hsc') || lowerText.contains('gpa')) {

      return "NUBTK তে SSC ও HSC এর GPA এর উপর ভিত্তি করে টিউশন ফি ওয়েভার দেওয়া হয়।\n\n"
          "📊 সাধারণ ওয়েভার কাঠামো:\n"
          "• GPA 5.00 = সর্বোচ্চ ওয়েভার\n"
          "• GPA 4.00-4.99 = মাঝারি ওয়েভার\n"
          "• GPA 3.50-3.99 = সাধারণ ওয়েভার\n\n"
          "⚠️ সঠিক হিসাবের জন্য:\n"
          "আপনার বিভাগ, SSC+HSC এর মোট GPA এবং বর্তমান সেমিস্টার লাগবে।\n\n"
          "✅ নির্ভুল তথ্য পেতে:\n"
          "1. অ্যাপে লগইন করে 'AI Assistant' এ আপনার GPA লিখুন\n"
          "2. অথবা ভিজিট: nubtk.edu.bd/admission\n"
          "3. হেল্পলাইন: 017XX-XXXXXX";
    }

    // 3. ভর্তি সংক্রান্ত
    if (lowerText.contains('ভর্তি') || lowerText.contains('admission') || lowerText.contains('apply')) {
      return "ভর্তির জন্য:\n\n"
          "1. 🌐 অনলাইন: nubtk.edu.bd/apply\n"
          "2. 📍 ক্যাম্পাস: শিববাড়ি মোড়, খুলনা\n"
          "3. 📞 হেল্পলাইন: 017XX-XXXXXX\n\n"
          "ভর্তির পর অ্যাপে লগইন করে ক্লাস রুটিন, পেমেন্ট, রিসোর্স সব পাবেন।";
    }

    // 4. কোর্স/সাবজেক্ট
    if (lowerText.contains('কোর্স') || lowerText.contains('সাবজেক্ট') || lowerText.contains('subject') ||
        lowerText.contains('department') || lowerText.contains('bba') || lowerText.contains('cse') ||
        lowerText.contains('law') || lowerText.contains('english')) {
      return "NUBTK তে বর্তমান বিভাগসমূহ:\n\n"
          "• BBA - ব্যবসায় প্রশাসন\n"
          "• CSE - কম্পিউটার সায়েন্স\n"
          "• English - ইংরেজি\n"
          "• Law - আইন\n\n"
          "প্রতিটি বিভাগের বিস্তারিত সিলেবাস: nubtk.edu.bd/departments\n\n"
          "লগইন করলে আপনার বিভাগের রুটিন ও রিসোর্স পাবেন।";
    }

    // 5. লোকেশন/ঠিকানা
    if (lowerText.contains('কোথায়') || lowerText.contains('ঠিকানা') || lowerText.contains('location') ||
        lowerText.contains('address') || lowerText.contains('ক্যাম্পাস')) {
      return "Northern University of Business & Technology Khulna\n\n"
          "📍 ঠিকানা: শিববাড়ি মোড়, সোনাডাঙ্গা, খুলনা-9000\n"
          "🌐 ওয়েব: nubtk.edu.bd\n"
          "📞 ফোন: 017XX-XXXXXX\n\n"
          "Google Map: 'NUBTK Khulna' সার্চ করুন";
    }

    // 6. বাকি সব প্রশ্ন - লগইন সাজেস্ট
    return "দুঃখিত, এই তথ্যটি শুধুমাত্র রেজিস্টার্ড স্টুডেন্টদের জন্য।\n\n"
        "আপনি জানতে পারেন:\n"
        "✓ ভর্তির যোগ্যতা ও প্রক্রিয়া\n"
        "✓ ওয়েভার পলিসি\n"
        "✓ বিভাগসমূহ\n"
        "✓ ক্যাম্পাস লোকেশন\n\n"
        "বিস্তারিত: nubtk.edu.bd\n"
        "অ্যাপের সব সেবা পেতে লগইন করুন।";
  }

  // 🔥 ফাইনাল লজিক: গেস্ট = মুখস্থ, স্টুডেন্ট/এডমিন = API
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
      // 🔥 ফিক্স: গেস্ট হলে এখানেই শেষ। Firebase বা SharedPreferences টাচ করবা না।
      if (widget.isGuestMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          setState(() {
            _messages.add({
              "text": _getGuestReply(text),
              "isUser": false,
              "image": null,
            });
            _isLoading = false;
          });
          _scrollToBottom();
        }
        return; // 🔥 গেস্ট হলে এখানেই return, নিচে আর যাবে না
      }

      // 🔥 নিচের কোড শুধু লগইন করা ইউজারের জন্য
      final user = FirebaseAuth.instance.currentUser!;
      String userRole = 'student';
      Map<String, dynamic> contextData = {};

      try {
        userRole = await _firebaseService.getUserRole();
        debugPrint('🔥 User Role: $userRole');

        if (userRole == 'student') {
          final paymentInfo = await _firebaseService.getStudentPaymentInfo(user.uid);
          if (paymentInfo!= null) contextData['paymentInfo'] = paymentInfo;
        }
        if (userRole == 'admin') {
          contextData['allStudents'] = await _firebaseService.getAllStudentsReport();
        }
      } catch (e) {
        debugPrint("User data load error: $e");
      }

      try {
        contextData['resources'] = await _firebaseService.getAllResources();
      } catch (e) {
        debugPrint("Resource load error: $e");
        contextData['resources'] = [];
      }

      Map<String, dynamic> response;

      if (text.isNotEmpty) {
        debugPrint('Sending to API for role: $userRole');
        response = await _apiService.chatWithAI(text, userRole, contextData);
      } else if (tempXFile!= null) {
        debugPrint('Sending image to Vision API');
        response = await _apiService.analyzeImage(tempXFile, user.uid);
      } else {
        response = {'success': false, 'error': 'কিছু লিখুন বা ছবি দিন'};
      }

      if (mounted) {
        setState(() {
          _messages.add({
            "text": response['data']?? response['error']?? "উত্তর পাওয়া যায়নি",
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
            "text": "দুঃখিত, একটি সমস্যা হয়েছে। আবার চেষ্টা করুন।",
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
        title: Text(
          widget.isGuestMode? "NUBTK Guest AI" : "NUBTK Pilot AI",
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
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