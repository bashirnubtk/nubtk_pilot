import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ফায়ারবেস ক্লাউড স্টোর ইম্পোর্ট
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

  // Controllers (আপনার অরিজিনাল কন্ট্রোলারগুলো)
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

  // ফায়ারবেস এবং লোকাল ডাটাবেজে সাবমিট করার লজিক
  void _submit(String lang) async {
    if (!_formKey.currentState!.validate()) return;

    // একটি ইউনিক ডিজিটাল আইডি জেনারেট করা
    String digitalId = "NUBTK-${DateTime.now().millisecondsSinceEpoch}";

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
      digitalId: digitalId, // ডিজিটাল আইডি সেট করা হলো
      createdAt: DateTime.now(),
    );

    try {
      // ১. আপনার তৈরি করা লোকাল সার্ভিস কল করা
      StudentDataService.addStudent(student);

      // ২. ফায়ারবেস ফায়ারস্টোরে ডাটা সেভ করা
      await FirebaseFirestore.instance.collection('students').doc(student.id).set({
        'id': student.id,
        'fullName': student.fullName,
        'email': student.email,
        'phone': student.phone,
        'department': student.department,
        'sscGpa': student.sscGpa,
        'hscGpa': student.hscGpa,
        'photoUrl': student.photoUrl,
        'status': 'pending',
        'digitalId': digitalId,
        'createdAt': student.createdAt,
      });

      // সাকসেস হলে ডায়ালগ দেখানো
      if (!mounted) return;
      _showSuccessDialog(lang, digitalId);

    } catch (e) {
      // এরর হ্যান্ডলিং
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessDialog(String lang, String digitalId) {
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
            Text("${AppStrings.checkGmail[lang]!}\nDigital ID: $digitalId",
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
      backgroundColor: const Color(0xFFF8F9FE), // হালকা নীলচে ব্যাকগ্রাউন্ড
      appBar: AppBar(
        title: Text(AppStrings.register[lang]!, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.indigo.shade900,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _photoPicker(),
                const SizedBox(height: 20),
                
                // Personal Info Section
                _sectionHeader(Icons.person_pin_rounded, "Personal Information"),
                _field(_name, AppStrings.name[lang]!, Icons.person_outline),
                _field(_father, "Father's Name", Icons.family_restroom_outlined),
                _field(_mother, "Mother's Name", Icons.family_restroom_outlined),
                
                const SizedBox(height: 10),
                // Contact Section
                _sectionHeader(Icons.contact_mail_rounded, "Contact Info"),
                _field(_email, AppStrings.email[lang]!, Icons.email_outlined, type: TextInputType.emailAddress),
                _field(_phone, AppStrings.phone[lang]!, Icons.phone_android_outlined, type: TextInputType.phone),
                
                const SizedBox(height: 10),
                // Academic Section
                _sectionHeader(Icons.school_rounded, "Academic Details"),
                _departmentDropdown(),
                Row(
                  children: [
                    Expanded(child: _field(_ssc, 'SSC GPA', Icons.grade_outlined, type: TextInputType.number)),
                    const SizedBox(width: 15),
                    Expanded(child: _field(_hsc, 'HSC GPA', Icons.grade_outlined, type: TextInputType.number)),
                  ],
                ),
                
                const SizedBox(height: 30),
                // Submit Button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Colors.indigo, Color(0xFF3F51B5)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _submit(lang),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Text('Submit Application',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // সেকশন হেডার উইজেট
  Widget _sectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 15),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.indigo.shade400),
          const SizedBox(width: 8),
          Text(title, 
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo.shade700, letterSpacing: 0.5)),
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

  Widget _field(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: (v) => (v == null || v.isEmpty) && !label.contains('GPA') ? 'Required' : null,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.indigo.shade300, size: 22),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _departmentDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedDept,
        decoration: InputDecoration(
          labelText: 'Select Department',
          labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(Icons.apartment_rounded, color: Colors.indigo.shade300, size: 22),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.indigo.shade100, width: 3),
                  boxShadow: [
                    BoxShadow(color: Colors.indigo.withOpacity(0.1), blurRadius: 20, spreadRadius: 2)
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: _photoPath.isEmpty
                      ? Icon(Icons.add_a_photo_outlined, color: Colors.indigo.shade200, size: 40)
                      : const Icon(Icons.check_circle, color: Colors.green, size: 50),
                ),
              ),
              if (_photoPath.isNotEmpty)
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 15,
                    child: Icon(Icons.check, color: Colors.green, size: 20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => setState(() => _photoPath = 'uploaded'),
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Upload Student Photo', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            style: TextButton.styleFrom(foregroundColor: Colors.indigo),
          ),
        ],
      ),
    );
  }
}