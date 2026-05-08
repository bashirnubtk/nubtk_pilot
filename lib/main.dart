//D:\projects\nubtk_pilot\lib\main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/home/languages/language_provider.dart';
import 'package:nubtk_pilot/features/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nubtk_pilot/services/api_service.dart';
import 'package:nubtk_pilot/features/auth/login_screen.dart'; // LoginScreen ইমপোর্ট করো

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: MyApp(prefs: prefs),
    ),
  );
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
    ApiService(widget.prefs).syncPendingUploads();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NUBTK PILOT',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // এই লাইনটা চেঞ্জ করেছি - routes অ্যাড করলাম
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(), // লগইন রুট অ্যাড করলাম
      },
    );
  }
}