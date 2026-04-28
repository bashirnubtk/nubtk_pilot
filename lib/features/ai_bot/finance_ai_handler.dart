// finance_ai_handler.dart

import 'dart:convert';
import 'dart:typed_data'; // ছবির ডাটার জন্য
import 'package:google_generative_ai/google_generative_ai.dart';

class FinanceAIHandler {
  // আপনার API Key টি এখানে থাকবে
  static const String _apiKey = "AIzaSyB4ctpaUTyyOzecNn2hn2ghGXKAvikwhek";

  // টেক্সট এবং ছবি—দুটোই হ্যান্ডেল করার জন্য নতুন মেথড
  static Future<Map<String, dynamic>> analyzeInput({String? textInput, Uint8List? imageBytes}) async {
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      
      const systemPrompt = """
      You are the official AI Assistant for Northern University of Bangladesh (NUBTK). 
      Your goals:
      1. Provide information about NUBTK departments, admission, total cost, and waivers based on SSC/HSC results (suggest total cost depends on results).
      2. Analyze any image the user uploads. If it's an educational question, solve it. If it's a photo, describe it politely.
      3. Always be polite and support both Bangla and English.
      4. If the user asks something complex not related to NUBTK or educational help, remind them to login for full services.
      
      Return the output ONLY in JSON format with these keys:
      'reply' (the main answer/description/solution), 'suggestion' (a small follow-up tip).
      """;

      final List<Content> contentParts = [];

      // ১. টেক্সট থাকলে যোগ করি
      if (textInput != null && textInput.isNotEmpty) {
        contentParts.add(Content.text("$systemPrompt \n User Input: $textInput"));
      } else if (imageBytes != null) {
        // যদি শুধু ছবি থাকে, তখনো সিস্টেম প্রম্পট লাগবে
        contentParts.add(Content.text(systemPrompt));
      }

      // ২. ছবি থাকলে যোগ করি (DataPart হিসেবে)
      if (imageBytes != null) {
        // মনে রাখবেন, Gemini Flash ছবি সাপোর্ট করে।
        contentParts.add(Content.multi([
          DataPart('image/jpeg', imageBytes), // আমরা ছবিকে JPEG হিসেবে পাঠাচ্ছি
        ]));
      }

      final response = await model.generateContent(contentParts);
      
      final raw = response.text ?? "{}";
      final cleaned = raw.replaceAll("```json", "").replaceAll("```", "").trim();
      
      return jsonDecode(cleaned);
    } catch (e) {
      return {
        "reply": "দুঃখিত, ছবি বা তথ্য প্রসেস করতে সমস্যা হচ্ছে।",
        "suggestion": "অনুগ্রহ করে আবার চেষ্টা করুন।"
      };
    }
  }
}