import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/primary_button.dart';
import '../../core/constants/app_strings.dart';
import '../../core/localization/language_provider.dart';
import '../ai_bot/ai_bot_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Current language from Provider
    final languageCode = Provider.of<LanguageProvider>(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NUBTK PILOT'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _noticeSection(languageCode),
            const SizedBox(height: 24),
            _quickLinksSection(languageCode),
            const SizedBox(height: 32),

            // AI Bot Button
            PrimaryButton(
              title: AppStrings.askAIBot[languageCode]!,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AIBotScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // Login Button
            PrimaryButton(
              title: AppStrings.login[languageCode]!,
              onPressed: () {
                // TODO: Implement Login Screen navigation
              },
            ),
            const SizedBox(height: 12),

            // Register Button
            PrimaryButton(
              title: AppStrings.register[languageCode]!,
              onPressed: () {
                // TODO: Implement Registration Screen navigation
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _noticeSection(String languageCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📢 ${AppStrings.latestNotices[languageCode]!}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Card(
          child: ListTile(
            title: Text('Spring Semester Admission Ongoing'),
            subtitle: Text('Last date: 30 March'),
          ),
        ),
        const Card(
          child: ListTile(
            title: Text('Mid Term Exam Schedule Published'),
          ),
        ),
      ],
    );
  }

  Widget _quickLinksSection(String languageCode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔗 ${AppStrings.quickLinks[languageCode]!}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppStrings.universityWebsite[languageCode]!),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.school),
            title: Text(AppStrings.resultPortal[languageCode]!),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.app_registration),
            title: Text(AppStrings.onlineAdmission[languageCode]!),
          ),
        ),
      ],
    );
  }
}
