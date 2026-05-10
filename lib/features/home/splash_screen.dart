//D:\projects\nubtk_pilot\lib\features\home\splash_screen.dart
import 'package:flutter/material.dart';
import 'package:nubtk_pilot/features/home/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 টাইমার, initState কিছু নাই। Build হওয়ার সাথে সাথে HomeScreen push
    // Flutter ইঞ্জিন লোডের 0.1s সাদা স্ক্রিন বাদে আর সাদা আসবে না। 98% ছবি।
    Future.microtask(() => Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/nubtk_pilot.png',
          width: MediaQuery.of(context).size.width * 0.8,
          errorBuilder: (context, error, stackTrace) {
            return const Text(
              'NUBTK PILOT',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
            );
          },
        ),
      ),
    );
  }
}