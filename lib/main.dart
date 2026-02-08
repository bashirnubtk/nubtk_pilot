import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/splash_screen.dart';

void main() {
  runApp(const NubtkPilotApp());
}

class NubtkPilotApp extends StatelessWidget {
  const NubtkPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NUBTK PILOT',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
