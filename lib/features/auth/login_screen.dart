import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../student/student_dashboard_screen.dart';

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

  void _handleLogin() async {
    if (_email.text.trim().isEmpty || _password.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final user = await _auth.login(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      if (user != null) {
        final role = await _auth.getRole(user.uid);
        if (!mounted) return;

        if (role == 'student' && !_isAdminMode) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
          );
        } else if (role == 'admin' && _isAdminMode) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Welcome to Admin Panel!")),
          );
        } else {
          throw Exception("Role mismatch! Please check your login mode.");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ডাইনামিক কালার সিলেকশন যাতে গায়েব না হয়
    final Color primaryColor = _isAdminMode ? Colors.red.shade800 : const Color(0xFF4F46E5);
    final List<Color> gradientColors = _isAdminMode 
        ? [Colors.red.shade900, Colors.orange.shade800] 
        : [const Color(0xFF6366F1), const Color(0xFF4F46E5)];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // স্টুডেন্ট/এডমিন সুইচ বাটন
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
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
                  const SizedBox(height: 40),
                  
                  // আইকন পরিবর্তন লজিক
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      _isAdminMode ? Icons.admin_panel_settings_rounded : Icons.school_rounded,
                      key: ValueKey(_isAdminMode),
                      size: 90, 
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _isAdminMode ? "ADMIN PORTAL" : "STUDENT PORTAL",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // লগইন কার্ড (আকর্ষণীয় ডিজাইন)
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(40),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _email,
                          decoration: InputDecoration(
                            labelText: _isAdminMode ? "Admin Email" : "Student Email",
                            prefixIcon: Icon(_isAdminMode ? Icons.security : Icons.email_outlined, color: primaryColor),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _password,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock_open_rounded, color: primaryColor),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _loading
                            ? CircularProgressIndicator(color: primaryColor)
                            : SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: const Text("LOGIN NOW", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _buildModeButton(String title, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _isAdminMode = (title == "Admin")),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}