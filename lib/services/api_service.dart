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

  // 🔥 তোমার ২৮টা মডেল - ফাস্ট গুলা আগে
  static const List<String> _textModels = [
    'google/gemma-4-31b-it:free', // 1. বেস্ট, ফাস্ট
    'google/gemma-4-26b-a4b-it:free', // 2. ফাস্ট
    'meta-llama/llama-3.3-70b-instruct:free', // 3. ইনস্ট্রাকশন ভালো
    'qwen/qwen3-next-80b-a3b-instruct:free', // 4. বড় কনটেক্সট
    'qwen/qwen3-coder:free', // 5. লজিক ভালো
    'z-ai/glm-4.5-air:free', // 6. ব্যাকআপ
    'openai/gpt-oss-120b:free', // 7. OpenAI
    'openai/gpt-oss-20b:free', // 8. OpenAI ছোট
    'nousresearch/hermes-3-llama-3.1-405b:free', // 9. সবচেয়ে বড়
    'nvidia/nemotron-3-super-120b-a12b:free', // 10. Nvidia
    'nvidia/nemotron-3-nano-30b-a3b:free', // 11. Nano
    'nvidia/nemotron-nano-9b-v2:free', // 12. ছোট
    'cognitivecomputations/dolphin-mistral-24b-venice-edition:free', // 13. Dolphin
    'minimax/minimax-m2.5:free', // 14. Minimax
    'inclusionai/ring-2.6-1t:free', // 15. 1T
    'baidu/cobuddy:free', // 16. Baidu
    'poolside/laguna-m.1:free', // 17. Laguna
    'poolside/laguna-xs.2:free', // 18. Laguna ছোট
    'openrouter/owl-alpha', // 19. Owl
    'openrouter/free', // 20. Default
    'liquid/lfm-2.5-1.2b-instruct:free', // 21. Liquid
    'liquid/lfm-2.5-1.2b-thinking:free', // 22. Liquid thinking
    'meta-llama/llama-3.2-3b-instruct:free', // 23. ছোট Llama
  ];

  // 🔥 ভিশন মডেল - তোমার লিস্ট থেকে
  static const List<String> _visionModels = [
    'google/gemma-4-31b-it:free', // 1. বেস্ট ভিশন
    'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free', // 2. Omni
    'nvidia/nemotron-nano-12b-v2-vl:free', // 3. Nano VL
    'baidu/qianfan-ocr-fast:free', // 4. OCR
    'google/lyria-3-clip-preview', // 5. Clip
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

  // 🔥 ফিক্স: Context ছোট রাখো। ২৪টা কিস্তি পাঠাইলে Timeout হবেই।
  Map<String, dynamic> _trimContext(String role, Map<String, dynamic> contextData) {
    if (role == 'guest') return {};

    final Map<String, dynamic> trimmed = {};

    if (role == 'student' && contextData['paymentInfo']!= null) {
      final p = contextData['paymentInfo'];
      final List inst = p['installments']?? [];
      trimmed['paymentInfo'] = {
        'name': p['name'],
        'studentId': p['studentId'],
        'status': p['status'],
        'totalDue': p['totalDue'],
        'totalPaid': p['totalPaid'],
        'paidCount': inst.where((i) => i['isPaid'] == true).length,
        'pendingCount': inst.where((i) => i['isPaid']!= true).length,
        'nextAmount': p['nextInstallment']?['amount'],
        'nextDueDate': p['nextInstallment']?['dueDate'],
        // 🔥 installments লিস্ট বাদ। এটাই Timeout করাইতেছিল।
      };
    }

    if (role == 'admin' && contextData['allStudents']!= null) {
      final List students = contextData['allStudents'];
      trimmed['summary'] = {
        'total': students.length,
        'approved': students.where((s) => s['paymentStatus'] == 'approved').length,
        'pending': students.where((s) => s['paymentStatus'] == 'pending').length,
      };
    }

    if (contextData['resources']!= null) {
      final List res = contextData['resources'];
      trimmed['resources'] = res.take(3).map((r) => r['title']).toList();
    }

    return trimmed;
  }

  String _buildSystemPrompt(String role) {
    const String guestRule = '''
You are NUBTK PILOT AI. User is GUEST.
First message: "হাই! আমি NUBTK PILOT AI। কিভাবে সাহায্য করতে পারি?"
Rules:
1. Only answer: waiver policy, admission, departments, location.
2. Waiver: "GPA 5.00=সর্বোচ্চ, 4.00-4.99=মাঝারি, 3.50-3.99=সাধারণ। বিস্তারিত: nubtk.edu.bd/admission"
3. For payment/resources: "এই তথ্যের জন্য লগইন করুন।"
4. Bangla, max 2 lines, friendly tone.''';

    const String studentRule = '''
You are NUBTK PILOT AI. User is STUDENT. Use contextData['paymentInfo'].
First message: "হাই! আমি NUBTK PILOT AI। পেমেন্ট বা রিসোর্স নিয়ে কী জানতে চান?"
Rules:
1. For "পেমেন্ট" queries:
   - If totalDue > 0: "মোট বাকি: {totalDue} টাকা\nপরিশোধ: {paidCount}টি, বাকি: {pendingCount}টি\nপরের কিস্তি: {nextAmount} টাকা, ডিউ: {nextDueDate}"
   - If totalDue = 0: "আপনার কোনো বকেয়া নেই ✅ সব {paidCount}টি কিস্তি পরিশোধিত।"
2. For resources: List from contextData['resources'].
3. DO NOT calculate. Use given numbers only.
4. Bangla, max 3 lines, human-like friendly tone.''';

    const String adminRule = '''
You are NUBTK PILOT AI. User is ADMIN. Use contextData['summary'].
First message: "হাই অ্যাডমিন! আমি NUBTK PILOT AI। রিপোর্ট লাগবে?"
Rules:
1. For "রিপোর্ট": "মোট স্টুডেন্ট: {total} জন\nApproved: {approved} জন\nPending: {pending} জন"
2. Bangla, max 3 lines.''';

    if (role == 'admin') return adminRule;
    if (role == 'student') return studentRule;
    return guestRule;
  }

  String _getLocalFallback(String role, String message, Map<String, dynamic> context) {
    final lower = message.toLowerCase();

    if (role == 'guest') {
      if (lower.contains('ওয়েভার') || lower.contains('gpa')) {
        return "GPA 5.00=সর্বোচ্চ, 4.00-4.99=মাঝারি ওয়েভার।\nবিস্তারিত: nubtk.edu.bd/admission";
      }
      if (lower.contains('ভর্তি')) {
        return "অনলাইন: nubtk.edu.bd/apply\nক্যাম্পাস: শিববাড়ি মোড়, খুলনা";
      }
      return "ভর্তি, ওয়েভার বা কোর্স সম্পর্কে জানতে চান?\nলগইন করলে পেমেন্ট দেখতে পারবেন।";
    }

    if (role == 'student' && context['paymentInfo']!= null) {
      final p = context['paymentInfo'];
      if (lower.contains('পেমেন্ট') || lower.contains('বাকি')) {
        if (p['totalDue'] > 0) {
          return "মোট বাকি: ${p['totalDue']} টাকা\nপরের কিস্তি: ${p['nextAmount']} টাকা\nডিউ: ${p['nextDueDate']}";
        } else {
          return "আপনার কোনো বকেয়া নেই ✅";
        }
      }
    }

    if (role == 'admin' && context['summary']!= null) {
      final s = context['summary'];
      return "মোট স্টুডেন্ট: ${s['total']} জন\nPending: ${s['pending']} জন";
    }

    return "দুঃখিত, বুঝতে পারিনি। আবার বলুন।";
  }

  Future<Map<String, dynamic>> chatWithAI(String message, String role, Map<String, dynamic> contextData) async {
    if (!await _isOnline()) {
      return {'success': true, 'data': _getLocalFallback(role, message, contextData)};
    }
    if (_openRouterKey.isEmpty) {
      return {'success': true, 'data': _getLocalFallback(role, message, contextData)};
    }

    final Map<String, dynamic> safeContext = _trimContext(role, _sanitizeData(contextData));
    final systemPrompt = _buildSystemPrompt(role);

    for (String model in _textModels) {
      try {
        debugPrint('Trying model: $model for role: $role');
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
            'temperature': 0.1,
            'max_tokens': 150,
          }),
        ).timeout(const Duration(seconds: 5)); // 🔥 8s → 5s। দ্রুত ফেইল করবে।

        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          debugPrint('Success with model: $model');
          return {
            'success': true,
            'data': jsonResponse['choices'][0]['message']['content']
          };
        }
      } catch (e) {
        debugPrint('Model $model failed: $e');
        continue; // 🔥 সাথে সাথে পরের মডেলে যাবে
      }
    }

    // 🔥 ২৮টা মডেল ফেইল করলেও লোকাল উত্তর দিবে। "সার্ভার ব্যস্ত" বলবে না।
    return {'success': true, 'data': _getLocalFallback(role, message, safeContext)};
  }

  Future<Map<String, dynamic>> analyzeImage(XFile imageFile, String userId) async {
    if (!await _isOnline()) {
      await _addToOfflineQueue(imageFile.path, userId);
      return {'success': true, 'data': 'ইন্টারনেট নাই। অনলাইনে এলে দেখাবো।'};
    }
    try {
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
                    {'type': 'text', 'text': 'এই ছবিটা কীসের? বাংলায় 2 লাইনে বলো।'},
                    {'type': 'image_url', 'image_url': {'url': dataUrl}}
                  ]
                }
              ],
              'max_tokens': 150,
            }),
          ).timeout(const Duration(seconds: 15));
          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            debugPrint('Vision success with: $model');
            return {
              'success': true,
              'data': jsonResponse['choices'][0]['message']['content']
            };
          }
        } catch (e) {
          debugPrint('Vision exception with $model: $e');
          continue;
        }
      }
      return await _sendToServer(imageFile, userId);
    } catch (e) {
      return {'success': false, 'error': 'ছবি প্রসেস করা যায়নি'};
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