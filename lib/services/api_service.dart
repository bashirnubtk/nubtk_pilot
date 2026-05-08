// D:\projects\nubtk_pilot\lib\services\api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'; // debugPrint এর জন্য

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8000'; 
  static const String _openRouterUrl = 'https://openrouter.ai/api/v1/chat/completions';
  
  // 🔥 ফিক্স ১: static final বাদ দিয়ে getter বানালাম। এখন main() এ dotenv লোড হওয়ার পরে Key পড়বে
  String get _openRouterKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';
  
  final SharedPreferences _prefs;
  static const String _queueKey = 'offline_upload_queue';

  ApiService(this._prefs);

  Future<bool> _isOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.mobile) || 
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    }
    return false;
  }

  // OpenRouter এ টেক্সট চ্যাট পাঠানো
  Future<Map<String, dynamic>> chatWithAI(String message, String role, Map<String, dynamic> contextData) async {
    bool online = await _isOnline();
    if (!online) {
      return {
        'success': false,
        'error': 'দুঃখিত, ইন্টারনেট সংযোগ নেই।'
      };
    }

    // 🔥 ফিক্স ২: Key খালি কিনা চেক করো
    if (_openRouterKey.isEmpty) {
      debugPrint('OpenRouter API Key পাওয়া যায়নি। .env ফাইল চেক করো।');
      return {
        'success': false,
        'error': 'API Key সেট করা হয়নি।'
      };
    }

    try {
      String systemPrompt = '''
      তুমি NUBTK PILOT অ্যাপের AI অ্যাসিস্ট্যান্ট। 
      ইউজার রোল: $role
      ইউজারের ডাটা: ${jsonEncode(contextData)}
      
      নিয়ম:
      1. স্টুডেন্ট হলে তার ইনস্টলমেন্ট, পেমেন্ট নিয়ে হেল্প করো।
      2. রিসোর্স চাইলে resources ডাটা থেকে লিংক দাও। উদাহরণ: "Resources সেকশনে 'VS Code Guide' আছে।"
      3. এডমিন হলে সব স্টুডেন্টের রিপোর্ট দাও।
      4. গেস্ট হলে শুধু পাবলিক ইনফো দাও।
      5. বাংলায় উত্তর দাও। ছোট করে পয়েন্ট আকারে বলো।
      ''';

      final response = await http.post(
        Uri.parse(_openRouterUrl),
        headers: {
          'Authorization': 'Bearer $_openRouterKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://nubtk-pilot.app', // 🔥 ফিক্স ৩: OpenRouter এটা চায়
          'X-Title': 'NUBTK PILOT', // 🔥 ফিক্স ৩
        },
        body: jsonEncode({
          'model': 'meta-llama/llama-3.1-8b-instruct:free', // 🔥 ফ্রি মডেল, gpt-3.5 ফ্রি না
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': message}
          ],
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return {
          'success': true,
          'data': jsonResponse['choices'][0]['message']['content']
        };
      } else {
        debugPrint('OpenRouter Error: ${response.statusCode} ${response.body}');
        return {
          'success': false,
          'error': 'AI সার্ভার এরর: ${response.statusCode}'
        };
      }
    } catch (e) {
      debugPrint('chatWithAI Error: $e');
      return {
        'success': false,
        'error': 'সংযোগের সমস্যা: $e'
      };
    }
  }

  // ছবি অ্যানালাইসিস - আগের মতোই থাকবে
  Future<Map<String, dynamic>> analyzeImage(XFile imageFile, String userId) async {
    bool online = await _isOnline();
    if (online) {
      try {
        return await _sendToServer(imageFile, userId);
      } catch (e) {
        await _addToOfflineQueue(imageFile.path, userId);
        return {
          'success': false,
          'source': 'offline',
          'message': 'Server unreachable, saved for later.'
        };
      }
    } else {
      await _addToOfflineQueue(imageFile.path, userId);
      return {
        'success': true,
        'source': 'offline',
        'data': {'message': 'Saved offline. Will sync when online.'}
      };
    }
  }

  Future<Map<String, dynamic>> _sendToServer(XFile imageFile, String userId) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/analyze'), 
      );
      request.fields['userId'] = userId;
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return {'success': true, 'source': 'server', 'data': jsonResponse};
      } else {
        return {'success': false, 'error': 'Server returned ${response.statusCode}'};
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _addToOfflineQueue(String imagePath, String userId) async {
    List<String> queue = _prefs.getStringList(_queueKey) ?? [];
    Map<String, String> item = {
      'imagePath': imagePath,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    queue.add(jsonEncode(item));
    await _prefs.setStringList(_queueKey, queue);
  }

  Future<void> syncPendingUploads() async {
    bool online = await _isOnline();
    if (!online) return;
    List<String> queue = _prefs.getStringList(_queueKey) ?? [];
    if (queue.isEmpty) return;
    List<String> remainingQueue = [];
    for (String itemStr in queue) {
      try {
        Map<String, dynamic> item = jsonDecode(itemStr);
        XFile imageFile = XFile(item['imagePath']);
        var result = await _sendToServer(imageFile, item['userId']);
        if (result['success'] != true) remainingQueue.add(itemStr);
      } catch (e) {
        remainingQueue.add(itemStr);
      }
    }
    await _prefs.setStringList(_queueKey, remainingQueue);
  }
}