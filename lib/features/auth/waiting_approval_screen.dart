import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/home_screen.dart';

class WaitingApprovalScreen extends StatelessWidget {
  const WaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      // অ্যাপবার যোগ করা হয়েছে ব্যাক বাটনের জন্য
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.indigo),
          onPressed: () => _goHome(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView( // এটিই হলুদ দাগ/ওভারফ্লো সমস্যার সমাধান
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                _buildIcon(),
                const SizedBox(height: 30),
                const Text(
                  "Application Submitted Successfully!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 25),
                _buildInfoCard(),
                const SizedBox(height: 40),
                _buildHomeButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goHome(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
    }
  }

  Widget _buildIcon() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.1), shape: BoxShape.circle),
    child: const Icon(Icons.mark_email_read_rounded, size: 70, color: Colors.indigo),
  );

  Widget _buildInfoCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
    child: Column(
      children: [
        const Text("What's Next?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
        const SizedBox(height: 15),
        Text(
          "Your application is now under review. Once approved, you will receive your User ID, Password, and Waiver details via Gmail.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
        ),
        const Divider(height: 25),
        _stepItem(Icons.verified_user, "Official User ID & Password"),
        _stepItem(Icons.card_giftcard, "Waiver & Results Evaluation"),
      ],
    ),
  );

  Widget _stepItem(IconData i, String t) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [Icon(i, size: 16, color: Colors.green), const SizedBox(width: 10), Text(t, style: const TextStyle(fontSize: 13))]),
  );

  Widget _buildHomeButton(context) => SizedBox(
    width: double.infinity, height: 50,
    child: ElevatedButton(
      onPressed: () => _goHome(context),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      child: const Text("BACK TO HOME", style: TextStyle(fontWeight: FontWeight.bold)),
    ),
  );
}