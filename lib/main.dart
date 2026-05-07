import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nubtk_pilot/features/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nubtk_pilot/services/api_service.dart';
// তোমার হোম স্ক্রিনের নাম

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  @override
  void initState() {
    super.initState();
    // অ্যাপ স্টার্ট হলেই পেন্ডিং আপলোড সিঙ্ক হবে
    ApiService(widget.prefs).syncPendingUploads();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NUBTK PILOT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // তোমার প্রথম স্ক্রিন
    );
  }
}