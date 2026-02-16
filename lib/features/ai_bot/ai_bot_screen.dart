import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nubtk_pilot/features/home/languages/language_provider.dart';
import 'package:nubtk_pilot/features/ai_bot/finance_ai_handler.dart';
import '../../core/constants/app_strings.dart';

class AIBotScreen extends StatefulWidget {
  const AIBotScreen({super.key});

  @override
  State<AIBotScreen> createState() => _AIBotScreenState();
}

class _AIBotScreenState extends State<AIBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  Future<void> _handleSend() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"text": text, "isUser": true});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final result = await FinanceAIHandler.analyzeProject(text);
      setState(() {
        _messages.add({
          "text": "📊 Summary: ${result['summary']}\n\n🏆 Score: ${result['score']}/100\n\n💡 Improvement: ${result['improvement']}",
          "isUser": false
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({"text": "Error: Failed to connect to AI.", "isUser": false});
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).languageCode;

    return Scaffold(
      backgroundColor: Colors.white, // ব্যাকগ্রাউন্ড সাদা করে দিলাম স্পষ্ট দেখানোর জন্য
      appBar: AppBar(
        title: Text(AppStrings.askAIBot[lang]!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.indigo[900], // গাঢ় রঙ
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
                return _buildChatBubble(msg["text"], msg["isUser"]);
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          _buildInputArea(lang),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
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
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 16),
        ),
      ),
    );
  }

  // স্পষ্ট এবং শার্প ইনপুট বক্স
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
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                decoration: InputDecoration(
                  hintText: lang == 'bn' ? 'এখানে লিখুন...' : 'Type here...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.indigo, size: 28),
              onPressed: _isLoading ? null : _handleSend,
            ),
          ],
        ),
      ),
    );
  }
}