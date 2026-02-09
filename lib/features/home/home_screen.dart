import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/primary_button.dart';
import '../../core/constants/app_strings.dart';
import '../home/language/language_provider.dart';
import '../auth/login_screen.dart';
import '../ai_bot/ai_bot_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageProvider>(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'NUBTK PILOT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerGreeting(),
            const SizedBox(height: 20),

            _noticeSection(languageCode),
            const SizedBox(height: 28),

            _quickLinksSection(languageCode),
            const SizedBox(height: 32),

            PrimaryButton(
              title: AppStrings.askAIBot[languageCode]!,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AIBotScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            PrimaryButton(
              title: AppStrings.login[languageCode]!,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
            const SizedBox(height: 10),

            PrimaryButton(
              title: AppStrings.register[languageCode]!,
              onPressed: () {
                // Next step
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerGreeting() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.indigo.withOpacity(0.08),
      ),
      child: const Text(
        'Welcome to NUBTK Digital Campus 👋',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _NoticeCard(
                title: 'Spring Semester Admission',
                subtitle: 'Last date: 30 March',
              ),
              _NoticeCard(
                title: 'Mid Term Exam',
                subtitle: 'Schedule Published',
              ),
            ],
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
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _QuickLinkCard(
              icon: Icons.language,
              title: AppStrings.universityWebsite[languageCode]!,
            ),
            _QuickLinkCard(
              icon: Icons.school,
              title: AppStrings.resultPortal[languageCode]!,
            ),
            _QuickLinkCard(
              icon: Icons.app_registration,
              title: AppStrings.onlineAdmission[languageCode]!,
            ),
          ],
        ),
      ],
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _NoticeCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _QuickLinkCard({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.indigo.withOpacity(0.08),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Colors.indigo),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
