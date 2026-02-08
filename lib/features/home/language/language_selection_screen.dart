import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _languageButton(context, 'বাংলা', 'bn'),
            const SizedBox(height: 16),
            _languageButton(context, 'English', 'en'),
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
          // future: save language & navigate home
        },
        child: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
