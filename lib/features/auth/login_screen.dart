import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth ইমপোর্ট করা হয়েছে
import 'auth_service.dart';
import '../student/screens/student_dashboard_screen.dart';
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

  /// লগইন হ্যান্ডলার লজিক
  void _handleLogin() async {
    final String emailInput = _email.text.trim();
    final String passInput = _password.text.trim();

    // ভ্যালিডেশন চেক
    if (emailInput.isEmpty || passInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // ১. স্পেশাল অ্যাডমিন লগইন (আপনার হার্ডকোডেড লজিক বজায় রাখা হয়েছে)
      if (_isAdminMode && emailInput == "admin" && passInput == "admin@123") {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
          (route) => false,
        );
        return; 
      }

      // ২. আসল ফায়ারবেস লগইন লজিক
      // স্টুডেন্ট বা অ্যাডমিন উভয়েই তাদের ইমেইল এবং সিস্টেম জেনারেটেড পাসওয়ার্ড দিয়ে লগইন করবে
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailInput,
        password: passInput,
      );

      final user = userCredential.user;

      if (user != null) {
        // ফায়ারস্টোর থেকে ইউজারের রোল (student/admin) চেক করা
        final role = await _auth.getRole(user.uid);
        if (!mounted) return;

        // মোড অনুযায়ী সঠিক স্ক্রিনে পাঠানো
        if (role == 'student' && !_isAdminMode) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
            (route) => false,
          );
        } else if (role == 'admin' && _isAdminMode) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
            (route) => false,
          );
        } else {
          // যদি অ্যাডমিন মোডে স্টুডেন্ট লগইন করতে চায় বা উল্টোটা হয়
          await FirebaseAuth.instance.signOut(); // ভুল লগইন সেশন আউট করা
          throw Exception("Role mismatch! You are trying to log in as ${role.toUpperCase()} in ${_isAdminMode ? 'ADMIN' : 'STUDENT'} portal.");
        }
      }
    } on FirebaseAuthException catch (authError) {
      // ফায়ারবেস রিলেটেড এরর মেসেজ হ্যান্ডলিং
      String errorMessage = "Login failed. Please check your credentials.";
      if (authError.code == 'user-not-found') errorMessage = "No user found for this email.";
      if (authError.code == 'wrong-password') errorMessage = "Incorrect password. Check your email for the system-generated password.";
      if (authError.code == 'invalid-email') errorMessage = "The email address is badly formatted.";

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      // অন্যান্য সাধারণ এরর
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
      }
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // মোড সুইচার বাটন
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
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
                  // লগইন ফর্ম কার্ড
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ]
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Digital ID / Email Address",
                            hintText: 'e.g. NUBTK-BBA-2026-0003',
                            prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'আপনার ডিজিটাল আইডি বা ইমেইল লিখুন';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _password,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password (Your Digital ID)", 
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
    );
  }

  /// মোড বাটন (Student/Admin) তৈরির হেল্পার মেথড
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