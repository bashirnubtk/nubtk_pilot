import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../home/language/language_provider.dart';
import '../student/data_service.dart';
import '../student/student_model.dart';
import '../admin/admin_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isAdmin = false;
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  void _login(String lang) {
    if (isAdmin) {
      if (emailCtrl.text == 'admin' && passCtrl.text == 'admin@123') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
      } else {
        _showError(AppStrings.invalidCreds[lang]!);
      }
    } else {
      StudentModel? student = StudentDataService.loginStudent(
        emailCtrl.text,
        passCtrl.text,
      );

      if (student == null) {
        _showError(AppStrings.invalidCreds[lang]!);
      } else if (student.status != 'approved') {
        _showError(AppStrings.notApproved[lang]!);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(AppStrings.login[lang]!, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.lock_outline_rounded, size: 80, color: Colors.indigo),
            const SizedBox(height: 20),
            
            // Toggle
            SwitchListTile(
              title: Text(isAdmin ? AppStrings.adminLogin[lang]! : AppStrings.studentLogin[lang]!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              value: isAdmin,
              onChanged: (v) => setState(() => isAdmin = v),
            ),
            
            const SizedBox(height: 20),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: AppStrings.emailOrUser[lang],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppStrings.passwordOrId[lang],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock_open_rounded),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _login(lang),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(AppStrings.login[lang]!, style: const TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}