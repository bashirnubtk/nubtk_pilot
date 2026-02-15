import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class WaitingApprovalScreen extends StatelessWidget {
  const WaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // withOpacity এরর ফিক্স
                  color: Colors.indigo.withValues(alpha: 0.1),
                  shape: BoxShape.circle, // BoxCircle ফিক্স
                ),
                child: const Icon(Icons.mark_email_read_rounded, size: 80, color: Colors.indigo),
              ),
              const SizedBox(height: 40),
              const Text(
                "Application Submitted Successfully!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05), 
                      blurRadius: 10, 
                      offset: const Offset(0, 4)
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "What's Next?",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Your application is now under review. Once approved, you will receive your User ID, Password, and Waiver details via Gmail based on your SSC & HSC results.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                    ),
                    const SizedBox(height: 15),
                    _stepItem(Icons.verified_user, "Official User ID & Password"),
                    _stepItem(Icons.card_giftcard, "Waiver & Results Evaluation"),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (_) => const HomeScreen()), 
                    (route) => false
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("BACK TO HOME", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}