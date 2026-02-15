flutter create nubtk_pilot
cd nubtk_pilot
git init


https://console.firebase.google.com/u/0/project/nubtk-pilot/settings/general/android:com.nubtk.pilot


# প্রোজেক্ট শুরুর কমান্ড: প্রোজেক্ট শুরু করার সময় ডিফল্ট com.example ব্যবহার না করে আপনার অর্গানাইজেশন নাম দিয়ে শুরু করুন:
flutter create --org com.yourdomain project_name

git config --global user.email "bashircse.nubtk@gmail.com
git config --global user.name "bashirnubtk

git remote add origin https://github.com/bashirnubtk/nubtk_pilot.git

git pull origin main --rebase

git checkout -b dev

git add .
git commit -m "feat: initial project structure and splash screen implementation"
git push origin dev

git add .
git commit -m "feat: add lock functionality to StudentMenuTile for status-based access control"
git push origin dev


git add .
git commit -m "feat: implement PDF generation and download for digital ID"
git push origin main




কাজের ধরন,উদাহরণ (যা তুমি টাইপ করবে),কেন এটি প্রফেশনাল?
নতুন ফিচার যোগ করা,"git commit -m ""feat: added login screen UI""",feat দিয়ে ফিচার বোঝানো হয়।
কোনো ভুল ঠিক করা,"git commit -m ""fix: resolved overflow error in splash screen""",fix দিয়ে বাগ সল্ভিং বোঝানো হয়।
কোড সাজানো/রিফ্যাক্টর,"git commit -m ""refactor: reorganized folder structure for features""",refactor মানে তুমি কোড গুছিয়েছো।
ডকুমেন্টেশন আপডেট,"git commit -m ""docs: updated README with project setup guide""",docs দিয়ে ফাইলের বর্ণনা বোঝানো হয়।
স্টাইল বা ডিজাইন পরিবর্তন,"git commit -m ""style: updated theme colors and fonts""",style দিয়ে ডিজাইনের কাজ বোঝানো হয়।


#1no
git add .
git commit -m "chore: remove unused platform folders (ios, macos, windows, linux) to reduce project size"
git push origin dev

#  প্রফেশনাল হওয়ার জন্য ছোট একটি 'Secret' টিপস
git push origin dev

#2no
git add .
git commit -m "Initialize global theme system and reusable UI components"
09/02/26

#3no
git add .
git commit -m "Add splash screen with university branding and global theme setup"
09/02/26


git add .
git commit -m "Fix import paths and disable default widget test"
09/02/26

git commit -m "Add home screen with notices, quick links, and guest access flow"

git add .
git add lib/features/home/splash_screen.dart
git commit -m "Improve splash screen stability and safe navigation"
git push origin dev

git add .
git commit -m "fix(localization): fix LanguageProvider type errors"
git push origin dev


git add .
git commit -m "feat: add login UI and remove pending TODO navigation"
git push origin dev


git add .
git commit -m "Enhance home UI with notifications, cards, and quick links layout"
git push origin dev
03:01:03
09/02/2026

git add .
git commit -m "feat: upgrade Home UI with glassmorphic cards and Gemini-style AI interaction"
git push origin dev
09/02/2026

git add .
git commit -m "fix: resolve UI warnings and implement home to register navigation"
git push origin dev

git add .
git commit -m "added student model, admission logic and data service simulation"
git push origin main


git add .
git commit -m "feat: sync registration, admin, and data services with error fixes"
git push origin dev 


git add .
git commit -m "feat: modernize register UI and implement login logic with synced data services"
git push origin dev 



# ফায়ারবেস ইন্টিগ্রেশন এবং প্যাকেজ ফিক্সের জন্য কমেন্ট
git add .
git commit -m "feat: integrate firebase core, auth, and firestore with version conflict resolution"
git push origin dev


git add .
git commit -m "fix: resolve kts build errors, sync firebase package, and implement file upload UI"
git push origin dev

03:15:26
10/02/2026


git add .
git commit -m "feat: integrate Firestore for Admin approval and Student login with status guard"
git push origin main


git add .
git commit -m "refactor: clean up lints, fix async gaps and update deprecated members in Login and Register screens"
git push origin main


git add .
git commit -m "feat: implement Firebase Auth on registration and fix deprecated lints"
git push origin main


git add .
git commit -m "feat: integrate live firestore stream for student dashboard and fix lints"
git push origin main

git add .
git commit -m "feat: upgrade admin panel to real-time streams and sync with student dashboard"
git push origin main


git add .
git commit -m "cleanup: remove unused platform folders (windows, linux, macos)"
git push origin dev

git add .
git commit -m "feat: implement semester payment plan, installment generator and fix photoUrl errors"
git push origin dev


git add .
git commit -m "feat: implement auth system with dual-mode login and payment logic" -m "
- Added Firebase Auth service for student registration and login.
- Implemented professional UI for Login screen with Student/Admin toggle.
- Added password visibility toggle and smooth theme switching.
- Integrated automated semester-based payment plan generation (24 installments).
- Fixed photoUrl and model mapping errors in AdminDataService.
- Optimized app performance with flutter clean and code restructuring."
git push origin dev


git add .
git commit -m "fix: restore home screen navigation and fix admin login black screen" -m "
- Updated main.dart to set HomeScreen as the initial route.
- Fixed black screen issue in LoginScreen by adding admin login logic.
- Resolved syntax errors in AdminPaymentControl and updated imports.
- Re-connected Login and Register flow from the Guest Homepage.
- Cleaned up unused imports and improved code stability."
git push origin dev



git add .
git commit -m "fix: resolve undefined identifiers in payment logic and dashboard" -m "
- Fixed missing fromMap, id, and semester in Installment model.
- Implemented markInstallmentPaid in PaymentService.
- Resolved BuildContext async gap warnings in Auth screens.
- Fixed missing required photoUrl parameter in AdminDataService."
git push origin dev


git add .
git commit -m "fix: resolve all identified errors and sync payment logic" -m "
- Implemented createPaymentPlan and markInstallmentPaid in PaymentService.
- Fixed InstallmentGenerator to align with updated PaymentModel.
- Resolved missing photoUrl parameter in AdminDataService.
- Fixed deprecated 'value' property in RegisterScreen.
- Synchronized StudentDashboard with real-time Firestore updates."
git push origin dev

# এখন ডেভ ব্রাঞ্চকে সার্ভারে পাঠিয়ে দিন
 git push origin dev

git add .
git commit -m "feat: integrated payment notifications and synced dashboard with payment map structure"
git push origin dev


# সব নতুন ফাইল এবং পরিবর্তন অ্যাড করুন

git add .
git commit -m "feat: implement AuthGuard with role-based routing and approval status check"
git push origin dev


git add .
git commit -m "feat: complete student registration flow and admin approval dashboard" -m "Summary of changes:
- Redesigned RegisterScreen with premium UI and better error handling.
- Implemented real-time AdminScreen with Firestore StreamBuilder.
- Fixed Admin login logic and payment plan generation."
git push origin dev


git add .
git commit -m "feat: connect LoginScreen to new AdminDashboard and fix deprecated UI warnings"
git push origin dev


git add .
git commit -m "feat: setup Node.js, fix admin dashboard design, and update auth flow"
git push origin dev


প্রজেক্টের শেষে
git checkout main
git merge dev
git commit -m "release: final version with all features implemented"
git push origin main

# এখন ডেভ ব্রাঞ্চকে সার্ভারে পাঠিয়ে দিন
 git push origin dev