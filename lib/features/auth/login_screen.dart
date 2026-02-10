import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ফায়ারবেস অথ
import '../../core/constants/app_strings.dart';
import '../home/language/language_provider.dart';
import '../admin/admin_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isAdmin = false;
  bool isLoading = false; // লোডিং স্টেট
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  Future<void> _login(String lang) async {
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError(AppStrings.invalidCreds[lang]!);
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isAdmin) {
        // --- এডমিন লগইন (স্ট্যাটিক লজিক) ---
        if (email == 'admin' && password == 'admin@123') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminScreen()),
          );
        } else {
          _showError(AppStrings.invalidCreds[lang]!);
        }
      } else {
        // --- স্টুডেন্ট লগইন (Firestore Logic) ---
        // আমরা সরাসরি Firestore এ সার্চ করছি কারণ রেজিস্ট্রেশনে Auth ইউজ না হয়ে থাকলে এটা নিরাপদ
        final querySnapshot = await FirebaseFirestore.instance
            .collection('students')
            .where('email', isEqualTo: email)
            .where('digitalId', isEqualTo: password) // আপনার লজিক অনুযায়ী পাসওয়ার্ড ডিজিটাল আইডি হতে পারে
            .get();

        if (querySnapshot.docs.isEmpty) {
          _showError(AppStrings.invalidCreds[lang]!);
        } else {
          final studentData = querySnapshot.docs.first.data();
          final status = studentData['status'];

          if (status != 'approved') {
            _showError(AppStrings.notApproved[lang]!);
          } else {
            // ✅ Approved -> Home Screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        }
      }
    } catch (e) {
      _showError("Login Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
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
        title: Text(AppStrings.login[lang]!, 
          style: const TextStyle(fontWeight: FontWeight.bold)),
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
            
            // Admin/Student Toggle Switch
            SwitchListTile(
              title: Text(isAdmin ? AppStrings.adminLogin[lang]! : AppStrings.studentLogin[lang]!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              value: isAdmin,
              activeColor: Colors.indigo,
              onChanged: (v) => setState(() => isAdmin = v),
            ),
            
            const SizedBox(height: 20),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: AppStrings.emailOrUser[lang],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.white,
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
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            
            // Login Button with Loading State
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _login(lang),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(AppStrings.login[lang]!, 
                      style: const TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}