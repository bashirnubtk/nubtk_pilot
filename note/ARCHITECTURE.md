lib/
├── main.dart
├── core/
│ ├── theme/app_theme.dart
│ ├── utils/responsive_helper.dart
│ └── localization/
│ ├── app_language.dart
│ └── language_provider.dart
│
├── features/
│ ├── admin/ [EXISTING]
│ │ ├── admin_dashboard.dart
│ │ ├── admin_screen.dart
│ │ ├── admin_payment_approval_screen.dart
│ │ ├── admin_student_list_screen.dart
│ │ └── admin_data_service.dart
│ │
│ ├── auth/ [EXISTING]
│ │ ├── auth_service.dart ← রোল ম্যানেজমেন্ট এখানে
│ │ ├── auth_guard.dart
│ │ ├── login_screen.dart
│ │ └── register_screen.dart
│ │
│ ├── ai_bot/ [EXISTING]
│ │ ├── ai_bot_screen.dart
│ │ ├── ai_logic_center.dart ← Python API কল এখান থেকে
│ │ └── ai_data_archive.dart
│ │
│ ├── student/ [EXISTING]
│ │ ├── student_dashboard_screen.dart
│ │ ├── student_payment_list_screen.dart
│ │ └── student_resource_screen.dart
│ │
│ └── home/ [EXISTING]
│ ├── home_screen.dart
│ └── splash_screen.dart
│
├── models/ [CREATE IF NOT EXISTS]
│ ├── student_model.dart
│ ├── payment_model.dart
│ ├── resource_model.dart
│ └── analysis_result_model.dart ← নতুন যোগ করবো
│
└── services/ [CREATE THIS]
├── firebase_service.dart ← Firestore সব লজিক
├── local_cache_service.dart ← shared_preferences wrapper
└── api_service.dart ← Python backend কল

python_backend/
└── main.py ← check_models.py কে FastAPI দিয়ে wrap করবো



# NUBTK PILOT - System Architecture v2.0
**Updated: 2026-05-07**

## 1. Tech Stack
- **Frontend**: Flutter 3.10+ 
- **State Management**: Provider ^6.0.5
- **Backend**: Firebase (Auth, Firestore, Storage, Functions)
- **AI Engine**: Python `check_models.py` + Google Generative AI
- **Local DB**: shared_preferences (lightweight, লো-এন্ড ফোন ফ্রেন্ডলি)
- **Image**: image_picker ^1.2.1

## 2. User Roles & Access Control
**File: `lib/auth_service.dart`**

| Role | Screen Access | Permissions |
| --- | --- | --- |
| **admin** | `admin_dashboard.dart`, সব স্ক্রিন | Full CRUD, User Approve, Payment Approve |
| **student** | `student_dashboard_screen.dart` | Read own data, Upload images, Pay |
| **pending** | `waiting_approval_screen.dart` | No access, wait for admin |

রোল চেক হবে `auth_guard.dart` দিয়ে।

## 3. Project Structure - Actual Files
