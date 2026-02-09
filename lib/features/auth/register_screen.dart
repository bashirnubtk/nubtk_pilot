import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/language/language_provider.dart'; 
import '../../core/constants/app_strings.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageProvider>(context).languageCode;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppStrings.register[languageCode]!, 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Create Account", 
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 8),
                Text("Join NUBTK Digital Campus today", 
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
                const SizedBox(height: 32),

                // Name Field
                _buildTextField(
                  controller: _nameController,
                  label: AppStrings.name[languageCode]!,
                  icon: Icons.person_outline_rounded,
                  validator: (val) => val!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 18),

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: AppStrings.email[languageCode]!,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => !val!.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 18),

                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  label: AppStrings.password[languageCode]!,
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (val) => val!.length < 6 ? 'Password too short' : null,
                ),
                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    child: Text(AppStrings.register[languageCode]!, 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                
                const SizedBox(height: 20),

                // Already have account? Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.alreadyHaveAccount[languageCode]!),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppStrings.login[languageCode]!, 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo.shade400),
        filled: true,
        fillColor: Colors.indigo.withAlpha(12), // modern soft background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.indigo.withAlpha(20)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}