class StudentModel {
  final String id; // auto generate later (Firebase / backend)
  final String fullName;
  final String email;
  final String phone;
  final String department;

  final double? sscGpa;
  final double? hscGpa;

  final String photoUrl; // later from Firebase Storage
  final String status; // pending | approved | rejected
  final String digitalId; // generated after approval

  final DateTime createdAt;

  StudentModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.department,
    this.sscGpa,
    this.hscGpa,
    required this.photoUrl,
    required this.status,
    required this.digitalId,
    required this.createdAt,
  });

  /// 🔹 Convert object → Map (for Firebase / API)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'department': department,
      'sscGpa': sscGpa,
      'hscGpa': hscGpa,
      'photoUrl': photoUrl,
      'status': status,
      'digitalId': digitalId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 🔹 Convert Map → object (from Firebase / API)
  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      department: map['department'] ?? '',
      sscGpa: map['sscGpa'] != null
          ? double.tryParse(map['sscGpa'].toString())
          : null,
      hscGpa: map['hscGpa'] != null
          ? double.tryParse(map['hscGpa'].toString())
          : null,
      photoUrl: map['photoUrl'] ?? '',
      status: map['status'] ?? 'pending',
      digitalId: map['digitalId'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
