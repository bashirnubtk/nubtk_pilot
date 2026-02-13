import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/home/language/language_provider.dart';
import 'features/auth/login_screen.dart'; // লগইন স্ক্রিন ইমপোর্ট করুন

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NUBTK Pilot',
      theme: ThemeData(primarySwatch: Colors.indigo),
      // শুরুতে এখন লগইন স্ক্রিন দেখাবে
      home: const LoginScreen(), 
    );
  }
}