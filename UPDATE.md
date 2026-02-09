flutter create nubtk_pilot
cd nubtk_pilot
git init

git config --global user.email "bashircse.nubtk@gmail.com
git config --global user.name "bashirnubtk

git remote add origin https://github.com/bashirnubtk/nubtk_pilot.git

git pull origin main --rebase

git checkout -b dev

git add .
git commit -m "feat: initial project structure and splash screen implementation"
git push origin dev






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

প্রজেক্টের শেষে
git checkout main
git merge dev
git commit -m "release: final version with all features implemented"
git push origin main