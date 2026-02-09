import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../home/language/language_provider.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _sscController = TextEditingController();
  final _hscController = TextEditingController();

  String? _selectedDepartment;
  final List<String> _departments = [
    'Computer Science & Engineering',
    'Business Administration',
    'English',
    'Law',
    'EEE',
  ];

  void _submit(String lang) {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 70),
              const SizedBox(height: 20),
              Text(
                AppStrings.regSuccess[lang]!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.checkGmail[lang]!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(AppStrings.close[lang]!, style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(AppStrings.register[lang]!, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.indigo.shade900,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPhotoPlaceholder(),
                const SizedBox(height: 25),
                
                _buildLabel("Personal Details"),
                _inputField(_nameController, AppStrings.name[lang]!, Icons.person_outline),
                _inputField(_emailController, AppStrings.email[lang]!, Icons.email_outlined, keyboard: TextInputType.emailAddress),
                _inputField(_phoneController, AppStrings.phone[lang]!, Icons.phone_android_outlined, keyboard: TextInputType.phone),

                _buildLabel("Academic Selection"),
                _buildDropdown(),

                _buildLabel("Results (Optional)"),
                Row(
                  children: [
                    Expanded(child: _inputField(_sscController, 'SSC GPA', Icons.school_outlined, keyboard: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _inputField(_hscController, 'HSC GPA', Icons.history_edu_outlined, keyboard: TextInputType.number)),
                  ],
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _submit(lang),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 5,
                    ),
                    child: Text(
                      AppStrings.register[lang]!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Center(
      child: Stack(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.indigo.withAlpha(20),
              shape: BoxShape.circle, // ফিক্সড: BoxCircle এর বদলে BoxShape.circle
            ),
            child: const Icon(Icons.person, color: Colors.indigo, size: 50),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 10),
      child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo.shade300)),
    );
  }

  Widget _inputField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboard}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (v) => (label.contains('GPA') == false && (v == null || v.isEmpty)) ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.indigo.shade300),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedDepartment,
        decoration: InputDecoration(
          labelText: 'Select Department',
          prefixIcon: Icon(Icons.apartment_rounded, color: Colors.indigo.shade300),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: (v) => setState(() => _selectedDepartment = v),
        validator: (v) => v == null ? 'Required' : null,
      ),
    );
  }
}