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


Memory card

Context: NUBTK PILOT Project v1.0.0-stable

Tech: Flutter + Firebase + OpenRouter API
Features:
1. 3 Role: Student, Admin, Guest
2. Guest AI: Uses API with role='guest'. Knows waiver chart 2024-25: GPA 10=100%, 9.5-9.99=75%, 9-9.49=50%, 8.5-8.99=25%, 8-8.49=10%
3. AI Models: 28 free models, 5s timeout, local fallback if API fails
4. Firebase: Auth + Firestore. Laptop off থাকলেও চলে
5. APK: flutter build apk --release --no-shrink দিয়ে বানানো

Critical Fixes Done:
- Salam bug fixed: ইউজার সালাম দিলে তবেই সালাম
- Context trimmed: installments list বাদ, timeout খায় না
- All syntax error fixed, null-safety 100%

Git Tag: v1.0.0-stable
Location: D:\projects\nubtk_pilot