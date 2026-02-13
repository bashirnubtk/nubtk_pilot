import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../student/student_dashboard_screen.dart';
import '../admin/admin_screen.dart'; 

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
    final String emailInput = _email.text.trim();
    final String passInput = _password.text.trim();

    // ১. খালি ইনপুট চেক
    if (emailInput.isEmpty || passInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // ২. অ্যাডমিন হার্ডকোডেড লগইন (ফায়ারবেসকে বাইপাস করবে)
      if (_isAdminMode && emailInput == "admin" && passInput == "admin@123") {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
          (route) => false,
        );
        return; // এখানেই কাজ শেষ, নিচের ফায়ারবেস লজিক আর রান হবে না
      }

      // ৩. ফায়ারবেস অথেন্টিকেশন (স্টুডেন্ট বা অন্য ইউজারদের জন্য)
      final user = await _auth.login(
        email: emailInput,
        password: passInput,
      );

      if (user != null) {
        final role = await _auth.getRole(user.uid);
        if (!mounted) return;

        if (role == 'student' && !_isAdminMode) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
            (route) => false,
          );
        } else if (role == 'admin' && _isAdminMode) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminScreen()),
            (route) => false,
          );
        } else {
          throw Exception("Role mismatch! Please check your login mode.");
        }
      }
    } catch (e) {
      // ফায়ারবেস থেকে আসা এরর মেসেজ হ্যান্ডলিং
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final Color primaryColor = _isAdminMode ? Colors.red.shade800 : const Color(0xFF4F46E5);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // মোড সিলেকশন বাটন (Student/Admin)
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
                    color: Colors.white
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
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ]
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _email,
                          decoration: InputDecoration(
                            labelText: _isAdminMode ? "Username" : "Email Address",
                            prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                                    elevation: 2,
                                  ),
                                  child: const Text("LOGIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), 
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
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white, 
            fontWeight: FontWeight.bold, 
            fontSize: 13
          ),
        ),
      ),
    );
  }
}