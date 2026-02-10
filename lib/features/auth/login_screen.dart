import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // অপ্রয়োজনীয় তাই রিমুভড

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
  bool isLoading = false;
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
        if (email == 'admin' && password == 'admin@123') {
          if (!mounted) return; // ✅ Async gap guard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminScreen()),
          );
        } else {
          _showError(AppStrings.invalidCreds[lang]!);
        }
      } else {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('students')
            .where('email', isEqualTo: email)
            .where('digitalId', isEqualTo: password)
            .get();

        if (!mounted) return; // ✅ Async gap guard

        if (querySnapshot.docs.isEmpty) {
          _showError(AppStrings.invalidCreds[lang]!);
        } else {
          final studentData = querySnapshot.docs.first.data();
          final status = studentData['status'];

          if (status != 'approved') {
            _showError(AppStrings.notApproved[lang]!);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        }
      }
    } catch (e) {
      _showError("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
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
        title: Text(AppStrings.login[lang]!),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.lock_outline_rounded, size: 80, color: Colors.indigo),
            SwitchListTile(
              title: Text(isAdmin ? AppStrings.adminLogin[lang]! : AppStrings.studentLogin[lang]!),
              value: isAdmin,
              activeThumbColor: Colors.indigo, // ✅ Deprecated member fixed
              onChanged: (v) => setState(() => isAdmin = v),
            ),
            // ... বাকি ডিজাইন একই থাকবে
            const SizedBox(height: 20),
            TextField(controller: emailCtrl),
            const SizedBox(height: 16),
            TextField(controller: passCtrl, obscureText: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _login(lang),
                child: isLoading ? const CircularProgressIndicator() : Text(AppStrings.login[lang]!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}