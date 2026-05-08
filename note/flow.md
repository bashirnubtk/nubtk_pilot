১. ইউজার রোল + অ্যাক্সেস:
Admin → সব ডেটা, ইউজার ম্যানেজ, মডেল আপডেট
Analyst → রিপোর্ট দেখা, CSV এক্সপোর্ট, ফিল্টার
User → শুধু ইমেজ আপলোড + নিজের রেজাল্ট দেখা

২. ডেটা ফ্লো - অনলাইন:


Flutter App [User]
    ↓ ছবি + GPS
Firebase Storage ← ছবি আপলোড
    ↓
Firebase Function ট্রিগার
    ↓
Python FastAPI Server [check_models.py] ← AI অ্যানালাইসিস
    ↓ JSON রেজাল্ট
Firestore Database ← রেজাল্ট সেভ
    ↓
Flutter App ← রিয়েল-টাইম রেজাল্ট দেখাবে

৩. ডেটা ফ্লো - অফলাইন:
Flutter App [User]
    ↓ ছবি + GPS
SQLite Local DB ← কিউ তে রাখো
    ↓
TFLite মডেল ← লোকাল হালকা অ্যানালাইসিস
    ↓
UI তে "Pending Sync" দেখাও
    ↓ নেট আসলে
Auto Sync → Firebase এ পাঠাও

৪. ফাইল স্ট্রাকচার - তোমার যা আছে ওটাই রাখবো:
lib/
├── main.dart
├── admin/ ← তোমার অলরেডি আছে
├── models/ ← তোমার অলরেডি আছে, এখানে analysis_result.dart অ্যাড করবো
├── services/
│ ├── firebase_service.dart ← নতুন বানাবো
│ ├── local_db_service.dart ← নতুন বানাবো
│ └── auth_service.dart ← ৩ ইউজারের লগইন
└── screens/
    ├── analyst/ ← নতুন, যদি না থাকে
    └── user/ ← নতুন, যদি না থাকে

python_backend/
└── main.py ← check_models.py কে API বানাবো

