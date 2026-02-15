lib/
│
├── main.dart
│
├── core/
│   ├── constants/
│   │   └── app_strings.dart
│   │
│   ├── localization/
│   │   ├── app_language.dart
│   │   ├── language_provider.dart
│   │   └── language_selection_screen.dart
│   │
│   ├── theme/
│   │   └── app_theme.dart
│   │
│   └── utils/
│       └── responsive_helper.dart
│
├── features/
│
│   ├── auth/
│   │   ├── auth_service.dart        ← Firebase logic
│   │   ├── auth_guard.dart          ← Route protection
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── waiting_approval_screen.dart
│
│   ├── home/
│   │   ├── splash_screen.dart
│   │   └── home_screen.dart
│
│   ├── admin/
│   │   ├── admin_screen.dart
│   │   ├── admin_dashboard.dart
│   │   ├── admin_data_service.dart
│   │   └── admin_payment_control.dart
│
│   ├── student/
│   │
│   │   ├── models/
│   │   │   └── student_model.dart
│   │
│   │   ├── screens/
│   │   │   ├── student_dashboard_screen.dart
│   │   │   ├── digital_id_screen.dart
│   │   │   └── payment_tile.dart
│   │
│   │   └── student_services/
│   │       ├── data_service.dart
│   │       └── digital_id_pdf_service.dart
│
│   ├── payment/
│   │   ├── payment_model.dart
│   │   ├── payment_service.dart
│   │   ├── installment_generator.dart
│   │   ├── waiver_engine.dart
│   │   └── payment_notification_service.dart
│
│   ├── ai_bot/
│   │   ├── ai_bot_screen.dart
│   │   └── finance_ai_handler.dart
│
│   └── cv_builder/
│       (future files)
│
└── widgets/
    └── primary_button.dart
