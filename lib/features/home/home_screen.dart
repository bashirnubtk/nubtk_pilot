import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NUBTK PILOT'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _noticeSection(),
            const SizedBox(height: 24),
            _quickLinksSection(),
            const SizedBox(height: 24),
            PrimaryButton(
              title: '🤖 Ask AI Bot (Guest)',
              onPressed: () {
                // future: navigate to AI bot
              },
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              title: 'Login',
              onPressed: () {
                // future: login
              },
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              title: 'Register',
              onPressed: () {
                // future: register
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _noticeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📢 Latest Notices',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            title: const Text('Spring Semester Admission Ongoing'),
            subtitle: const Text('Last date: 30 March'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Mid Term Exam Schedule Published'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _quickLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🔗 Quick Links',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.language),
            title: const Text('University Website'),
            onTap: () {},
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Result Portal'),
            onTap: () {},
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.app_registration),
            title: const Text('Online Admission'),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
