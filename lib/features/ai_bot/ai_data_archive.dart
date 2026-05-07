// D:\projects\nubtk_pilot\lib\features\ai_bot\ai_data_archive.dart

class AIDataArchive {
  // ইউনিভার্সিটির ডিটেইলস ওয়েবসাইট ডাটা
  static const String universityDetails = """
    NUBTK (Northern University Business and Technology Khulna)
    প্রতিষ্ঠা: ২০১৫। অবস্থান: শিব বাড়ি মোড়, খুলনা।
    বিভাগসমূহ: সিএসই (CSE), ইইই (EEE), সিভিল (Civil), বিবিএ (BBA), ইংরেজি (English)।
    সুবিধাসমূহ: আধুনিক ল্যাব, অভিজ্ঞ শিক্ষক এবং কিস্তি সুবিধা।
    ওয়েবসাইট: https://nubtk.ac.bd
  """;

  // স্টুডেন্টদের বিস্তারিত ডাটাবেজ (ফায়ারবেস ছাড়া)
  static final List<Map<String, dynamic>> studentLedger = [
    {
      "id": "2021-1-60-001",
      "fullName": "Bashir Alam",
      "role": "student",
      "department": "CSE",
      "semester": "8th",
      "financials": {"total": 85000, "paid": 60000, "due": 25000},
    },
    {
      "id": "2021-1-60-002",
      "fullName": "Tisha Chakro Borty",
      "role": "student",
      "department": "CSE",
      "semester": "8th",
      "financials": {"total": 85000, "paid": 85000, "due": 0},
    },
    {
      "id": "admin_01",
      "fullName": "Professor Rahat",
      "role": "admin",
      "department": "All",
      "managed_students": 350,
    },
  ];

  // ডাটা রিড করার মেথড
  static Map<String, dynamic> getStudentData(String id) {
    return studentLedger.firstWhere(
      (s) => s['id'] == id,
      orElse: () => studentLedger[0], // না পেলে ডিফল্ট বশিরের ডাটা দেবে
    );
  }
}
