//D:\projects\nubtk_pilot\lib\features\home\languages\language_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import 'language_provider.dart';
import '../home_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentCode = languageProvider.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.selectLanguage[currentCode]!),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _languageButton(context, AppStrings.bangla[currentCode]!, 'bn'),
            const SizedBox(height: 16),
            _languageButton(context, AppStrings.english[currentCode]!, 'en'),
          ],
        ),
      ),
    );
  }

  Widget _languageButton(BuildContext context, String title, String code) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          final languageProvider =
              Provider.of<LanguageProvider>(context, listen: false);
          languageProvider.setLanguage(code);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        },
        child: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
