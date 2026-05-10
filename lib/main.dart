//D:\projects\nubtk_pilot\lib\main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // 🔥 নতুন লাইন ১
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nubtk_pilot/features/home/splash_screen.dart';
import 'package:nubtk_pilot/features/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nubtk_pilot/services/api_service.dart';
import 'package:nubtk_pilot/features/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  
  // 🔥 নতুন লাইন ২, ৩, ৪ - শুধু এইটুকু অ্যাড
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: prefs),
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
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}