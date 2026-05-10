//D:\projects\nubtk_pilot\lib\features\ai_bot\ai_logic_center.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'ai_data_archive.dart';
import 'package:nubtk_pilot/services/api_service.dart'; // ← এটা অ্যাড করলাম
import 'package:nubtk_pilot/models/analysis_result_model.dart'; // ← এটা অ্যাড করলাম

String _encodeImageInBackground(Uint8List imageBytes) => base64Encode(imageBytes);

class AILogicCenter {
  static final String _apiKey = dotenv.env['OPENROUTER_API_KEY']?? "";
  static List<Map<String, dynamic>> _freeModelsCache = [];
  static const String _cacheKey = 'openrouter_free_models_v2';
  static const String _cacheTimeKey = 'openrouter_free_models_time_v2';

  // তোমার দেওয়া লিস্ট থেকে সেরা ফ্রি মডেল - ভিশন আগে
  static const List<Map<String, dynamic>> _fallbackModels = [
    {
      "id": "nvidia/nemotron-nano-12b-v2-vl:free", // ভিশন + বাংলা ভালো
      "architecture": {"input_modalities": ["text", "image"]}
    },
    {
      "id": "qwen/qwen3-next-80b-a3b-instruct:free", // বাংলা খুব ভালো
      "architecture": {"input_modalities": ["text"]}
    },
    {
      "id": "meta-llama/llama-3.2-3b-instruct:free", // স্টেবল
      "architecture": {"input_modalities": ["text"]}
    },
    {
      "id": "google/gemma-4-26b-a4b-it:free", // গুগলের মডেল
      "architecture": {"input_modalities": ["text"]}
    },
  ];

  static Future<List<Map<String, dynamic>>> _getFreeModels() async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetch = prefs.getInt(_cacheTimeKey);

    if (lastFetch!= null &&
        DateTime.now().millisecondsSinceEpoch - lastFetch < 6 * 60 * 60 * 1000 &&
        _freeModelsCache.isNotEmpty) {
      return _freeModelsCache;
    }

    try {
      final response = await http.get(
        Uri.parse("https://openrouter.ai/api/v1/models"),
        headers: {"Authorization": "Bearer $_apiKey"},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allModels = data['data'] as List;

        _freeModelsCache = allModels.where((model) {
          final pricing = model['pricing'] as Map<String, dynamic>?;
          final promptPrice = double.tryParse(pricing?['prompt']?? '1')?? 1.0;
          final completionPrice = double.tryParse(pricing?['completion']?? '1')?? 1.0;
          return promptPrice == 0.0 && completionPrice == 0.0;
        }).map((e) => e as Map<String, dynamic>).toList();

        // ভিশন মডেল আগে
        _freeModelsCache.sort((a, b) {
          final aArch = a['architecture'] as Map<String, dynamic>?;
          final bArch = b['architecture'] as Map<String, dynamic>?;
          bool aHasVision = (aArch?['input_modalities'] as List?)?.contains('image')?? false;
          bool bHasVision = (bArch?['input_modalities'] as List?)?.contains('image')?? false;
          if (aHasVision &&! bHasVision) return -1;
          if (!aHasVision && bHasVision) return 1;
          return 0;
        });

        await prefs.setString(_cacheKey, jsonEncode(_freeModelsCache));
        await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
        debugPrint("Live Free Models: ${_freeModelsCache.map((m) => m['id']).toList()}");
        return _freeModelsCache;
      }
    } catch (e) {
      debugPrint("Fetch models failed: $e");
    }

    // ফেইল করলে তোমার লিস্ট থেকে হার্ডকোডেড ব্যাকআপ
    return _fallbackModels;
  }

  static Future<Map<String, dynamic>> analyzeInput({
    String? textInput,
    Uint8List? imageBytes,
    Map<String, dynamic>? studentData,
    required String userRole,
  }) async {
    if (_apiKey.isEmpty) return {"reply": "API Key নাই", "suggestion": ".env চেক করুন।"};

    final freeModels = await _getFreeModels();
    String systemPrompt = _buildSystemPrompt(userRole, studentData);
    List<Map<String, dynamic>> userContent = [];

    if (textInput!= null && textInput.trim().isNotEmpty) {
      userContent.add({"type": "text", "text": textInput.trim()});
    }

    bool needsVision = imageBytes!= null;
    if (needsVision) {
      if (imageBytes.length > 2 * 1024 * 1024) {
        return {"reply": "ছবি 2MB এর বেশি", "suggestion": "ছোট ছবি দিন।"};
      }
      try {
        String base64Image = await compute(_encodeImageInBackground, imageBytes);
        userContent.add({
          "type": "image_url",
          "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
        });
      } catch (e) {
        return {"reply": "ছবি প্রসেস এরর", "suggestion": "অন্য ছবি দিন।"};
      }
    }

    if (userContent.isEmpty) userContent.add({"type": "text", "text": "হ্যালো"});

    for (var model in freeModels) {
      String modelId = model['id'] as String;
      final arch = model['architecture'] as Map<String, dynamic>?;
      List modalities = arch?['input_modalities'] as List;

      if (needsVision &&! modalities.contains('image')) continue;

      try {
        debugPrint("Trying: $modelId");
        final response = await http.post(
          Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
          headers: {
            "Authorization": "Bearer $_apiKey",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://nubtk.ac.bd",
            "X-Title": "NUBTK Pilot",
          },
          body: jsonEncode({
            "model": modelId,
            "messages": [
              {"role": "system", "content": systemPrompt},
              {"role": "user", "content": userContent}
            ],
            "max_tokens": 1000,
            "temperature": 0.3, // কমিয়ে দিলাম যাতে বানায় না বলে
          }),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          String content = decoded['choices'][0]['message']['content'];
          debugPrint("Success: $modelId");
          return _parseJson(content);
        }
      } catch (e) {
        debugPrint("$modelId failed: $e");
        continue;
      }
    }

    return {"reply": "সব ফ্রি মডেল ব্যস্ত", "suggestion": "পরে ট্রাই করুন।"};
  }

  // এখানে আসল ফিক্স - ডাটা জোর করে ঢুকানো
  static String _buildSystemPrompt(String userRole, Map<String, dynamic>? studentData) {
    // ১. বেস ডাটা
    String basePrompt = """
    তুমি NUBTK Pilot AI। নিয়ম:
    ১. সব উত্তর বাংলা ভাষায় দিবে।
    ২. উত্তর JSON ফরম্যাটে হবে: {"reply": "তোমার উত্তর", "suggestion": "পরবর্তী সাজেশন"}
    ৩. নিচে দেওয়া ডাটাবেস থেকে তথ্য নিয়ে উত্তর দিবে। নিজে থেকে বানাবে না।

    === ইউনিভার্সিটি ডাটাবেস ===
    ${AIDataArchive.universityDetails}
    """;

    // ২. ইউজার রোল অনুযায়ী ডাটা ইনজেক্ট
    switch (userRole) {
      case 'admin':
        String allStudents = AIDataArchive.studentLedger
          .where((s) => s['role'] == 'student')
          .map((s) => "- ${s['fullName']} | ID: ${s['id']} | বিভাগ: ${s['department']} | বকেয়া: ${s['financials']['due']} টাকা")
          .join("\n");

        return """
        $basePrompt
        === ইউজার রোল: অ্যাডমিন ===
        তুমি অ্যাডমিন ${studentData?['fullName']?? 'Professor Rahat'}।

        === স্টুডেন্ট লিস্ট ===
        $allStudents

        নির্দেশ: উপরের লিস্ট থেকে সরাসরি উত্তর দিবে। "যোগাযোগ করুন" বলবে না। মোট স্টুডেন্ট ${AIDataArchive.studentLedger.where((s) => s['role'] == 'student').length} জন।
        """;

      case 'student':
        return """
        $basePrompt
        === ইউজার রোল: স্টুডেন্ট ===
        === এই স্টুডেন্টের ডাটা ===
        নাম: ${studentData?['fullName']}
        আইডি: ${studentData?['id']}
        বিভাগ: ${studentData?['department']}
        সেমিস্টার: ${studentData?['semester']}
        মোট ফি: ${studentData?['financials']?['total']} টাকা
        জমা: ${studentData?['financials']?['paid']} টাকা
        বকেয়া: ${studentData?['financials']?['due']} টাকা

        নির্দেশ: উপরের ডাটা থেকে সরাসরি উত্তর দিবে। অন্য কারো তথ্য দিবে না।
        """;

      case 'guest':
      default:
        // গেস্টের জন্য খরচ হিসাব করে দিলাম
        int totalFee = 85000;
        int semesterFee = totalFee ~/ 8;
        return """
        $basePrompt
        === ইউজার রোল: গেস্ট/ভিজিটর ===

        === খরচের হিসাব ===
        CSE বিভাগে ৪ বছরে মোট খরচ: $totalFee টাকা
        প্রতি সেমিস্টার: $semesterFee টাকা প্রায়
        কিস্তি সুবিধা: আছে

        নির্দেশ: উপরের হিসাব থেকে সরাসরি উত্তর দিবে। ব্যক্তিগত তথ্য দিবে না। ভর্তির জন্য উৎসাহিত করবে।
        """;
    }
  }

  static Map<String, dynamic> _parseJson(String raw) {
    try {
      int start = raw.indexOf('{');
      int end = raw.lastIndexOf('}');
      if (start!= -1 && end!= -1) return jsonDecode(raw.substring(start, end + 1));
    } catch (e) {
      debugPrint("JSON Error: $e");
    }
    return {"reply": raw.replaceAll('```json', '').replaceAll('```', '').trim(), "suggestion": "আরো কিছু?"};
  }

  // ========== নিচে আমার অ্যাড করা কোড - তোমার Python Backend + Offline কল করার জন্য ==========
  // তোমার existing কোডের নিচে এটা অ্যাড করো। উপরের কিছু চেঞ্জ করো নাই।

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // নতুন ফাংশন: ইমেজ পিক + তোমার Python Backend এ পাঠানো + Firebase সেভ
  Future<String> pickImageAndAnalyzeWithPython() async {
    try {
      // 1. ইউজার চেক
      User? user = _auth.currentUser;
      if (user == null) return "Error: Please login first";

      // 2. গ্যালারি থেকে ইমেজ
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image == null) return "Error: No image selected";

      // 3. ApiService দিয়ে Python Backend এ পাঠাও
      final prefs = await SharedPreferences.getInstance();
      final api = ApiService(prefs);
      final result = await api.analyzeImage(image, user.uid);

      // 4. Firebase এ সেভ
      if (result['success'] == true && result['data']!= null) {
        String docId = _db.collection('results').doc().id;
        AnalysisResult analysisResult = AnalysisResult(
          id: docId,
          userId: user.uid,
          imageUrl: image.path,
          aiData: result['data'],
          createdAt: DateTime.now(),
          status: result['source'] == 'offline'? 'pending_sync' : 'completed',
          source: result['source'],
        );
        await _db.collection('results').doc(docId).set(analysisResult.toJson());
        return "Success: Analysis done via ${result['source']}";
      } else {
        return "Error: ${result['error']}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}