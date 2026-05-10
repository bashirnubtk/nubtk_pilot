// D:\projects\nubtk_pilot\lib\services\api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8000';
  static const String _openRouterUrl = 'https://openrouter.ai/api/v1/chat/completions';

  String get _openRouterKey => dotenv.env['OPENROUTER_API_KEY']?? '';

  final SharedPreferences _prefs;
  static const String _queueKey = 'offline_upload_queue';

  // 🔥 টেক্সট মডেল - ইনস্ট্রাকশন ফলো করে এমনগুলা আগে
  static const List<String> _textModels = [
    'z-ai/glm-4.5-air:free',
    'cognitivecomputations/dolphin-mistral-24b-venice-edition:free',
    'meta-llama/llama-3.3-70b-instruct:free',
    'qwen/qwen3-coder:free',
    'google/gemma-4-31b-it:free',
    'nousresearch/hermes-3-llama-3.1-405b:free',
    'nvidia/nemotron-3-super-120b-a12b:free',
    'minimax/minimax-m2.5:free',
    'openai/gpt-oss-120b:free',
    'openai/gpt-oss-20b:free',
  ];

  // 🔥 ভিশন মডেল - ছবি বোঝে এমনগুলা
  static const List<String> _visionModels = [
    'google/gemma-4-31b-it:free', // বেস্ট ভিশন
    'nvidia/nemotron-nano-12b-v2-vl:free', // ফাস্ট ভিশন
    'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free', // রিজনিং সহ
    'baidu/qianfan-ocr-fast:free', // OCR এর জন্য
    'google/lyria-3-clip-preview', // ইমেজ বর্ণনা
  ];

  ApiService(this._prefs);

  Future<bool> _isOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);
  }

  dynamic _sanitizeData(dynamic data) {
    if (data is Timestamp) return data.toDate().toIso8601String();
    if (data is DateTime) return data.toIso8601String();
    if (data is DocumentReference) return data.path;
    if (data is GeoPoint) return {'latitude': data.latitude, 'longitude': data.longitude};
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), _sanitizeData(value)));
    }
    if (data is List) return data.map((e) => _sanitizeData(e)).toList();
    return data;
  }

  // 🔥 রোল-গার্ডরেইল প্রম্পট - গেস্ট/স্টুডেন্ট/এডমিন আলাদা
  String _buildSystemPrompt(String role) {
    const String guestRule = '''
You are NUBTK PILOT AI. User is a GUEST. You MUST follow these rules:
1. NEVER reveal payment, installment, student names, resources, or internal data.
2. If user says "hi", "hello", reply ONLY: "হাই! আমি NUBTK PILOT AI। ভর্তি, ওয়েভার বা কোর্সের তথ্যের জন্য nubtk.edu.bd ভিজিট করুন। ভর্তির পর লগইন করে সব তথ্য পাবেন।"
3. If asked about payment/resources/student data, reply: "এই তথ্যের জন্য লগইন করতে হবে।"
4. Keep reply under 3 lines. Bangla only.''';

    const String studentRule = '''
You are NUBTK PILOT AI. User is a STUDENT. You CAN use provided contextData.
1. If user says "hi", reply: "হাই! পেমেন্ট, ইনস্টলমেন্ট বা রিসোর্স নিয়ে হেল্প করতে পারি। কী জানতে চাও?"
2. For payment queries, use contextData['paymentInfo']. Format: "- ইনস্টলমেন্ট: X টাকা বাকি\n- ডিউ ডেট: X তারিখ"
3. For resources, list ONLY titles from contextData['resources']. No links.
4. NEVER invent data. If contextData is empty, say "তথ্যটি পাওয়া যায়নি।"
5. Bangla only, max 4 lines.''';

    const String adminRule = '''
You are NUBTK PILOT AI. User is an ADMIN. You CAN use contextData['allStudents'].
1. If user says "hi", reply: "হাই অ্যাডমিন! স্টুডেন্ট রিপোর্ট বা পেমেন্ট সারাংশ লাগবে?"
2. For report, give summary: "মোট: X জন, পরিশোধ: Y জন, বাকি: Z জন"
3. NEVER list individual student names unless asked.
4. Bangla only, max 4 lines.''';

    if (role == 'admin') return adminRule;
    if (role == 'student') return studentRule;
    return guestRule; // Default = guest
  }

  Future<Map<String, dynamic>> chatWithAI(String message, String role, Map<String, dynamic> contextData) async {
    if (!await _isOnline()) {
      return {'success': false, 'error': 'দুঃখিত, ইন্টারনেট সংযোগ নেই।'};
    }

    if (_openRouterKey.isEmpty) {
      return {'success': false, 'error': 'API Key সেট করা হয়নি।'};
    }

    // 🔥 গুরুত্বপূর্ণ: শুধু স্টুডেন্ট/এডমিন হলে ডাটা পাঠাবো, গেস্ট হলে খালি
    final Map<String, dynamic> safeContext = (role == 'guest')? {} : _sanitizeData(contextData);
    final systemPrompt = _buildSystemPrompt(role);

    for (String model in _textModels) {
      try {
        debugPrint('Trying text model: $model for role: $role');
        final response = await http.post(
          Uri.parse(_openRouterUrl),
          headers: {
            'Authorization': 'Bearer $_openRouterKey',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://nubtk-pilot.app',
            'X-Title': 'NUBTK PILOT',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': "Context: ${jsonEncode(safeContext)}\n\nUser: $message"}
            ],
            'temperature': 0.2, // আরও স্ট্রিক্ট
            'max_tokens': 250,
          }),
        ).timeout(const Duration(seconds: 25));

        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          debugPrint('Success with model: $model');
          return {
            'success': true,
            'data': jsonResponse['choices'][0]['message']['content']
          };
        } else if (response.statusCode == 429 || response.statusCode == 402) {
          debugPrint('Rate limited: $model, trying next...');
          continue;
        }
      } catch (e) {
        debugPrint('Exception with $model: $e');
        continue;
      }
    }
    return {'success': false, 'error': 'সব AI সার্ভার ব্যস্ত। 1 মিনিট পর আবার চেষ্টা করুন।'};
  }

  // 🔥 ভিশন মডেল দিয়ে ছবি অ্যানালাইসিস
  Future<Map<String, dynamic>> analyzeImage(XFile imageFile, String userId) async {
    if (!await _isOnline()) {
      await _addToOfflineQueue(imageFile.path, userId);
      return {'success': true, 'source': 'offline', 'data': 'Saved offline. Will sync when online.'};
    }

    try {
      // ছবিকে base64 এ কনভার্ট
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final dataUrl = 'data:image/jpeg;base64,$base64Image';

      for (String model in _visionModels) {
        try {
          debugPrint('Trying vision model: $model');
          final response = await http.post(
            Uri.parse(_openRouterUrl),
            headers: {
              'Authorization': 'Bearer $_openRouterKey',
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://nubtk-pilot.app',
              'X-Title': 'NUBTK PILOT',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {
                  'role': 'user',
                  'content': [
                    {'type': 'text', 'text': 'এই ছবিটা কীসের? বাংলায় 2 লাইনে বলো। যদি কোড হয়, কী কোড বুঝাও।'},
                    {'type': 'image_url', 'image_url': {'url': dataUrl}}
                  ]
                }
              ],
              'max_tokens': 200,
            }),
          ).timeout(const Duration(seconds: 30));

          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            debugPrint('Vision success with: $model');
            return {
              'success': true,
              'source': 'vision',
              'data': jsonResponse['choices'][0]['message']['content']
            };
          } else if (response.statusCode == 429 || response.statusCode == 402) {
            debugPrint('Vision rate limited: $model, trying next...');
            continue;
          }
        } catch (e) {
          debugPrint('Vision exception with $model: $e');
          continue;
        }
      }

      // সব ভিশন ফেইল করলে লোকাল সার্ভার ট্রাই করো
      return await _sendToServer(imageFile, userId);
    } catch (e) {
      await _addToOfflineQueue(imageFile.path, userId);
      return {'success': false, 'error': 'ছবি প্রসেস করা যায়নি: $e'};
    }
  }

  Future<Map<String, dynamic>> _sendToServer(XFile imageFile, String userId) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/analyze'));
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
    List<String> queue = _prefs.getStringList(_queueKey)?? [];
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
    List<String> queue = _prefs.getStringList(_queueKey)?? [];
    if (queue.isEmpty) return;
    List<String> remainingQueue = [];
    for (String itemStr in queue) {
      try {
        Map<String, dynamic> item = jsonDecode(itemStr);
        XFile imageFile = XFile(item['imagePath']);
        var result = await _sendToServer(imageFile, item['userId']);
        if (result['success']!= true) remainingQueue.add(itemStr);
      } catch (e) {
        remainingQueue.add(itemStr);
      }
    }
    await _prefs.setStringList(_queueKey, remainingQueue);
  }
}