import 'package:flutter/material.dart';

class AppTheme {
  // University primary color
  static const Color primaryColor = Colors.indigo;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,

    scaffoldBackgroundColor: Colors.white,

    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
