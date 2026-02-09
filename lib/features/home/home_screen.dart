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
      backgroundColor: const Color(0xFFF9FAFB), // Soft modern background
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'NUBTK PILOT',
          style: TextStyle(
            fontWeight: FontWeight.w800, 
            letterSpacing: 1.0,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 26),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerGreeting(),
              const SizedBox(height: 24),

              _sectionTitle('📢', AppStrings.latestNotices[languageCode]!),
              const SizedBox(height: 12),
              _noticeSection(),
              const SizedBox(height: 28),

              _sectionTitle('🔗', AppStrings.quickLinks[languageCode]!),
              const SizedBox(height: 12),
              _quickLinksSection(languageCode),
              const SizedBox(height: 32),

              // AI Assistant Button with Sparkle Icon
              _aiAssistantButton(languageCode, context),
              const SizedBox(height: 20),

              // Auth Buttons (Login & Register)
              _authButtons(languageCode, context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerGreeting() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to NUBTK 👋',
            style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 6),
          Text(
            'Digital Campus Pilot',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _aiAssistantButton(String languageCode, BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIBotScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.indigo]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.purple.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 22), // Gemini style sparkle
            const SizedBox(width: 10),
            Text(
              AppStrings.askAIBot[languageCode]!,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _authButtons(String languageCode, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _modernButton(
            title: AppStrings.login[languageCode]!,
            isFilled: false,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _modernButton(
            title: AppStrings.register[languageCode]!,
            isFilled: true,
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _modernButton({required String title, required bool isFilled, required VoidCallback onPressed}) {
    return SizedBox(
      height: 55,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isFilled ? Colors.indigo : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isFilled ? Colors.transparent : Colors.indigo.shade200),
          ),
          elevation: isFilled ? 2 : 0,
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(
            color: isFilled ? Colors.white : Colors.indigo,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String emoji, String title) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
        ),
      ],
    );
  }

  Widget _noticeSection() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: const [
          _NoticeCard(
            title: 'Spring Admission',
            subtitle: 'Ongoing till 30 March',
            icon: Icons.notifications_active,
            color: Colors.blue,
          ),
          _NoticeCard(
            title: 'Exam Schedule',
            subtitle: 'Mid-term is coming',
            icon: Icons.calendar_today,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _quickLinksSection(String languageCode) {
    return Column(
      children: [
        _ModernListTile(
          icon: Icons.language_rounded,
          title: AppStrings.universityWebsite[languageCode]!,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _ModernListTile(
          icon: Icons.school_outlined,
          title: AppStrings.resultPortal[languageCode]!,
          onTap: () {},
        ),
      ],
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _NoticeCard({required this.title, required this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ModernListTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.indigo.shade400, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}