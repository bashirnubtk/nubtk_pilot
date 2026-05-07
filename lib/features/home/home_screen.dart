import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_strings.dart';
import 'languages/language_provider.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../ai_bot/ai_bot_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // URL ওপেন করার জন্য নিরাপদ ফাংশন
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageProvider>(context).languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerGreeting(),
                  const SizedBox(height: 25),

                  _sectionTitle('📢', AppStrings.latestNotices[languageCode]!),
                  const SizedBox(height: 12),
                  _noticeSection(),
                  const SizedBox(height: 30),

                  _sectionTitle('🚀', "Quick Actions"),
                  const SizedBox(height: 15),
                  _buildQuickActionGrid(languageCode, context),
                  const SizedBox(height: 35),

                  _aiAssistantButton(languageCode, context),
                  const SizedBox(height: 25),

                  _authButtons(languageCode, context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // আধুনিক Sliver AppBar
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 90,
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'NUBTK PILOT',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          fontSize: 20,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.indigo,
              size: 28,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  // গ্রিটিংস কার্ড
  Widget _headerGreeting() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to NUBTK 👋',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Digital Campus Pilot',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // কুইক অ্যাকশন গ্রিড
  Widget _buildQuickActionGrid(String lang, BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.2,
      children: [
        _actionCard(
          Icons.school_rounded,
          "Result Portal",
          Colors.orange,
          () => _launchURL("https://nubtkhulna.ac.bd/ter/"),
        ),
        _actionCard(
          Icons.facebook_rounded,
          "Notice Feed",
          Colors.blue,
          () => _launchURL("https://www.facebook.com/groups/2141673572851512"),
        ),
        _actionCard(
          Icons.language_rounded,
          "Website",
          Colors.green,
          () => _launchURL("https://nubtkhulna.ac.bd/"),
        ),
        _actionCard(
          Icons.event_available_rounded,
          "Social Media",
          Colors.purple,
          () => _launchURL("https://www.facebook.com/nubtkofficial"),
        ),
      ],
    );
  }

  Widget _actionCard(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // AI Assistant Button
  Widget _aiAssistantButton(String languageCode, BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AiBotScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 22),
            const SizedBox(width: 12),
            Text(
              AppStrings.askAIBot[languageCode]!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // নোটিশ সেকশন
  Widget _noticeSection() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: const [
          _NoticeCard(
            title: 'Admission',
            subtitle: 'Spring 2026',
            icon: Icons.campaign_rounded,
            color: Colors.blue,
          ),
          _NoticeCard(
            title: 'Exams',
            subtitle: 'Mid-term Start',
            icon: Icons.event_note_rounded,
            color: Colors.red,
          ),
          _NoticeCard(
            title: 'Holiday',
            subtitle: 'Eid-ul-Fitr',
            icon: Icons.celebration_rounded,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  // লগইন ও রেজিস্ট্রেশন বাটন
  Widget _authButtons(String languageCode, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _modernButton(
            title: AppStrings.login[languageCode]!,
            isFilled: false,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _modernButton(
            title: AppStrings.register[languageCode]!,
            isFilled: true,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _modernButton({
    required String title,
    required bool isFilled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isFilled ? const Color(0xFF4F46E5) : Colors.white,
          foregroundColor: isFilled ? Colors.white : const Color(0xFF4F46E5),
          elevation: isFilled ? 4 : 0,
          shadowColor: Colors.indigo.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF4F46E5), width: 1),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _sectionTitle(String emoji, String title) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

// নোটিশ কার্ড কম্পোনেন্ট
class _NoticeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _NoticeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 15, bottom: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
