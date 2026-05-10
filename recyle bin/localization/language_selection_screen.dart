//D:\projects\nubtk_pilot\lib\core\localization\language_selection_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 30),

            PrimaryButton(
              title: 'বাংলা',
              onPressed: () {
                // Future: set Bangla
              },
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              title: 'English',
              onPressed: () {
                // Future: set English
              },
            ),
          ],
        ),
      ),
    );
  }
}
