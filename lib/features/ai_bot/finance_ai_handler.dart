import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class FinanceAIHandler {
  static const String _apiKey = "AIzaSyB4ctpaUTyyOzecNn2hn2ghGXKAvikwhek";

  static Future<Map<String, dynamic>> analyzeProject(String text) async {
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      final prompt = "Analyze this project and return ONLY JSON with keys 'summary', 'score' (0-100), and 'improvement': $text";
      
      final response = await model.generateContent([Content.text(prompt)]);
      final raw = response.text ?? "{}";
      final cleaned = raw.replaceAll("```json", "").replaceAll("```", "").trim();
      
      return jsonDecode(cleaned);
    } catch (e) {
      // এই এরর মেসেজটিই আপনি স্ক্রিনে দেখছেন
      return {
        "summary": "Connection failed. Please check internet.",
        "score": 0,
        "improvement": "Try again later."
      };
    }
  }
}