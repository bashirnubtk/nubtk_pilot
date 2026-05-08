//D:\projects\nubtk_pilot\lib\models\analysis_result_model.dart
class AnalysisResult {
  final String id;
  final String userId;
  final String imageUrl;
  final Map<String, dynamic> aiData; // তোমার check_models.py যা রিটার্ন করে
  final DateTime createdAt;
  final String status; // pending, completed, failed
  final String source; // server, offline, tflite

  AnalysisResult({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.aiData,
    required this.createdAt,
    required this.status,
    required this.source,
  });

  // Firestore এ সেভ করার জন্য
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'aiData': aiData,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'source': source,
    };
  }

  // Firestore থেকে পড়ার জন্য
  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'],
      userId: json['userId'],
      imageUrl: json['imageUrl'],
      aiData: json['aiData'],
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'],
      source: json['source'],
    );
  }
}
