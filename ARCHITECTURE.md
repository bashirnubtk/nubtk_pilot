nubtk_pilot/
└── lib/
    ├── core/
    │   ├── constants/
    │   │   └── app_strings.dart
    │   ├── localization/
    │   │   ├── app_language.dart
    │   │   └── language_provider.dart
    │   ├── theme/
    │   │   └── app_theme.dart
    │   └── utils/
    │       └── responsive_helper.dart
    │
    ├── features/
    │   ├── home/
    │   │   └── home_screen.dart
    │   ├── language/
    │   │   └── language_selection_screen.dart
    │   ├── auth/
    |   |   ├── auth_service.dart  
    |   |   ├── login_screen.dart  
    |   |   ├── register_screen.dart     
    ├── student/
    │   ├──student_services\
    │   ├── student_model.dart
    │   ├── data_service.dart
    │   ├── student_dashboard_screen.dart
    │   ├── digital_id_screen.dart
    │   └── student_widgets/    // 🔒 Explicit name
    │   │   ├── student_status_banner.dart
    │   │   ├── digital_id_card_preview.dart
    │   │   └── student_menu_tile.dart
    │   ├── admin/
    |   |    ├──admin_screen.dart
    |   |    ├── admin_data_service.dart
    |   |    └── admin_payment_control.dart
    │   ├── ai_bot/
    |   |   ├──finance_ai_handler.dart
    |   |   ├──  ai_bot_screen.dart 
    │   |
    |   ├── payment/
    |   │   ├── payment_model.dart
    │   │   ├── payment_service.dart
    │   │   ├── installment_generator.dart
    │   │   ├── waiver_engine.dart
    │   │   └── payment_notification_service.dart
    │   │
    │   └── cv_builder/
    │
    ├── widgets/
    │   └── primary_button.dart
    │
    └── main.dart


SYSTEM ARCHITECTURE
  
  Admin:
  - Approve Student
  - Set Waiver %
  - Set Payment Plan
  - Generate Login Credential
  - Approve Payment

System:
  - Auto Calculate 4-Year Fee
  - Apply Waiver
  - Generate Installment Schedule
  - Send Email
  - Show Due Alert

Student:
  - View Due
  - Pay Installment
  - Get Notification

 Firestore Structure

students
   └── studentId
        ├── personal data
        ├── status
        └── payment
             ├── totalCourseFee
             ├── waiverPercent
             ├── finalPayableAmount
             ├── paymentPlan
             └── installments[]
