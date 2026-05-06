import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/home/languages/language_provider.dart';
import 'features/auth/auth_guard.dart';
import 'features/auth/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ডটএনভী ইমপোর্ট করা হয়েছে

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ১. ফায়ারবেস ইনিশিয়ালাইজেশন
  await Firebase.initializeApp();

  // ২. ডটএনভী ফাইল লোড করা (এটি ফায়ারবেসের পরেই করা ভালো)
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("Environment file loaded successfully!");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
  }

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
      theme: ThemeData(
        primaryColor: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGuard(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
