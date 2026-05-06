//D:\projects\nubtk_pilot\lib\features\models\resource_model.dart
class ResourceModel {
  final String id;
  final String title;
  final String link;
  final String category; // 'Video', 'Desktop App', 'Mobile App'

  ResourceModel({
    required this.id,
    required this.title,
    required this.link,
    required this.category,
  });

  // ডাটাবেজ থেকে ডাটা পড়ার জন্য
  factory ResourceModel.fromMap(Map<String, dynamic> map, String docId) {
    return ResourceModel(
      id: docId,
      title: map['title'] ?? '',
      link: map['link'] ?? '',
      category: map['category'] ?? 'Video',
    );
  }

  // ডাটাবেজে ডাটা পাঠানোর জন্য
  Map<String, dynamic> toMap() {
    return {'title': title, 'link': link, 'category': category};
  }
}
