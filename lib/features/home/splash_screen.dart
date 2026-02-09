import 'dart:async';
import 'package:flutter/material.dart';
import 'language/language_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/nubtk_logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'Northern University of\nBusiness & Technology Khulna',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'NUBTK PILOT',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
