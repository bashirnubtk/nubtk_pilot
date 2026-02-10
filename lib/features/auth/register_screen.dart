import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../home/home_screen.dart';
import '../student/student_model.dart';
import '../student/data_service.dart';
import '../home/language/language_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _father = TextEditingController();
  final _mother = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _ssc = TextEditingController();
  final _hsc = TextEditingController();

  String? _selectedDept;
  String _photoPath = '';

  final List<String> departments = ['CSE', 'EEE', 'BBA', 'English', 'Law'];

  void _submit(String lang) {
    if (!_formKey.currentState!.validate()) return;

    final student = StudentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: _name.text,
      email: _email.text,
      phone: _phone.text,
      department: _selectedDept ?? 'General',
      sscGpa: double.tryParse(_ssc.text),
      hscGpa: double.tryParse(_hsc.text),
      photoUrl: _photoPath,
      status: 'pending',
      digitalId: '',
      createdAt: DateTime.now(),
    );

    StudentDataService.addStudent(student);

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
            Text(AppStrings.regSuccess[lang]!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(AppStrings.checkGmail[lang]!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
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

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).languageCode;

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
                _photoPicker(),
                const SizedBox(height: 25),
                _buildLabel("Personal Information"),
                _field(_name, AppStrings.name[lang]!, Icons.person_outline),
                _field(_father, "Father's Name", Icons.family_restroom_outlined),
                _field(_mother, "Mother's Name", Icons.family_restroom_outlined),
                _buildLabel("Contact Info"),
                _field(_email, AppStrings.email[lang]!, Icons.email_outlined, type: TextInputType.emailAddress),
                _field(_phone, AppStrings.phone[lang]!, Icons.phone_android_outlined, type: TextInputType.phone),
                _buildLabel("Academic Details"),
                _departmentDropdown(),
                Row(
                  children: [
                    Expanded(child: _field(_ssc, 'SSC GPA', Icons.school_outlined, type: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_hsc, 'HSC GPA', Icons.history_edu_outlined, type: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () => _submit(lang),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 5,
                    ),
                    child: const Text('Submit Application',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 10),
      child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo.shade300)),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: (v) => (v == null || v.isEmpty) && !label.contains('GPA') ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.indigo.shade300),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _departmentDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedDept,
        decoration: InputDecoration(
          labelText: 'Select Department',
          prefixIcon: Icon(Icons.apartment_rounded, color: Colors.indigo.shade300),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
        onChanged: (v) => setState(() => _selectedDept = v),
        validator: (v) => v == null ? 'Required' : null,
      ),
    );
  }

  Widget _photoPicker() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.indigo.withAlpha(15),
            child: _photoPath.isEmpty
                ? const Icon(Icons.camera_enhance_outlined, color: Colors.indigo, size: 35)
                : const Icon(Icons.check, color: Colors.green),
          ),
          TextButton(
            onPressed: () => setState(() => _photoPath = 'uploaded'),
            child: const Text('Upload Photo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          ),
        ],
      ),
    );
  }
}