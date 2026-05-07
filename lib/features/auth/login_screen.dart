// C:\projects\Flutter project\nubtk_pilot\lib\features\auth\login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import '../student/screens/student_dashboard_screen.dart';
import '../admin/admin_screen.dart';
import '../../features/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final AuthService _auth = AuthService();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _isAdminMode = false;

  /// লগইন হ্যান্ডলার লজিক
  void _handleLogin() async {
    final String emailInput = _email.text.trim();
    final String passInput = _password.text.trim();

    if (emailInput.isEmpty || passInput.isEmpty) {
      _showError("Please enter both ID/Email and password");
      return;
    }

    setState(() => _loading = true);

    try {
      // ১. মাস্টার অ্যাডমিন লগইন (আপনার ডিফল্ট পাসওয়ার্ড)
      if (_isAdminMode && emailInput == "admin" && passInput == "admin@123") {
        _navigateTo(const AdminDashboard());
        return;
      }

      // ২. ফায়ারবেস লগইন লজিক (স্টুডেন্ট এবং অন্যান্য অ্যাডমিনদের জন্য)
      Map<String, dynamic>? loginResult = await _auth.login(emailInput, passInput);

      if (loginResult != null) {
        // যদি লগইন ব্যর্থ হয় (ভুল ইমেইল বা পাসওয়ার্ড)
        _showError(loginResult as String);
      } else {
        // লগইন সফল হলে রোল চেক করা
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final role = await _auth.getRole(user.uid);
          
          if (!mounted) return;

          // রোল এবং মোড চেক
          if (role == 'student' && !_isAdminMode) {
            _navigateTo(const StudentDashboardScreen());
          } else if (role == 'admin' && _isAdminMode) {
            _navigateTo(const AdminDashboard());
          } else {
            // যদি স্টুডেন্ট মোডে অ্যাডমিন লগইন করতে চায় বা উল্টোটা হয়
            await FirebaseAuth.instance.signOut();
            _showError("Role mismatch! You are in ${_isAdminMode ? 'ADMIN' : 'STUDENT'} portal.");
          }
        }
      }
    } catch (e) {
      _showError(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // স্ক্রিন নেভিগেশনের জন্য হেল্পার ফাংশন
  void _navigateTo(Widget screen) {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  // এরর দেখানোর জন্য হেল্পার ফাংশন
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final Color primaryColor = _isAdminMode ? Colors.red.shade800 : const Color(0xFF4F46E5);

    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isAdminMode
                  ? [Colors.red.shade900, Colors.orange.shade800]
                  : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    // মোড সুইচার
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildModeButton("Student", !_isAdminMode),
                          _buildModeButton("Admin", _isAdminMode),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Icon(
                      _isAdminMode ? Icons.admin_panel_settings_rounded : Icons.school_rounded,
                      size: 70,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isAdminMode ? "ADMIN PORTAL" : "STUDENT PORTAL",
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 25),
                    
                    // লগইন কার্ড
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                          ]),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _email,
                            decoration: InputDecoration(
                              labelText: _isAdminMode ? "Admin ID" : "Email Address",
                              prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _password,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                          const SizedBox(height: 25),
                          _loading
                              ? CircularProgressIndicator(color: primaryColor)
                              : SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    ),
                                    child: const Text("LOGIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String title, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() {
        _isAdminMode = (title == "Admin");
        _email.clear();
        _password.clear();
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          title,
          style: TextStyle(color: isActive ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}