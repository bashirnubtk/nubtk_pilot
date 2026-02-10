import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // নতুন সংযোজন
import 'features/home/language/language_provider.dart';
import 'features/home/home_screen.dart';

void main() async {
  // ফায়ারবেস ইনিশিয়াল করার জন্য এই লাইনটি বাধ্যতামূলক
  WidgetsFlutterBinding.ensureInitialized();
  
  // ফায়ারবেস কানেক্ট করা হচ্ছে
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}