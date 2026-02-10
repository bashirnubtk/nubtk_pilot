import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ নতুন ইমপোর্ট
import 'package:file_picker/file_picker.dart';
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
  bool isLoading = false; // ✅ লোডিং স্টেট যোগ করা হয়েছে

  // Controllers
  final _name = TextEditingController();
  final _father = TextEditingController();
  final _mother = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _ssc = TextEditingController();
  final _hsc = TextEditingController();

  String? _selectedDept;
  String _photoPath = '';
  String _sscPath = '';
  String _hscPath = '';

  final List<String> departments = ['CSE', 'EEE', 'BBA', 'English', 'Law'];

  Future<void> _pickFile(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type == 'photo' ? FileType.image : FileType.custom,
        allowedExtensions: type == 'photo' ? null : ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          if (type == 'photo') {
            _photoPath = result.files.single.path!;
          } else if (type == 'ssc') {
            _sscPath = result.files.single.path!;
          } else if (type == 'hsc') {
            _hscPath = result.files.single.path!;
          }
        });
      }
    } catch (e) {
      debugPrint("File picking error: $e");
    }
  }

  // ✅ আপডেট করা সাবমিট লজিক
  void _submit(String lang) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => isLoading = true); // লোডিং শুরু

    try {
      // ১. জিপিটির শর্ত অনুযায়ী: আগে FirebaseAuth-এ অ্যাকাউন্ট তৈরি করা
      // পাসওয়ার্ড হিসেবে সাময়িকভাবে ফোন নম্বর ব্যবহার করছি
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _phone.text.trim(), 
      );

      final String uid = userCredential.user!.uid; // ফায়ারবেস থেকে পাওয়া আসল UID
      String digitalId = "NUBTK-${DateTime.now().millisecondsSinceEpoch}";

      final student = StudentModel(
        id: uid, // ✅ এখন থেকে UID-ই হবে স্টুডেন্ট আইডি
        fullName: _name.text,
        email: _email.text,
        phone: _phone.text,
        department: _selectedDept ?? 'General',
        sscGpa: double.tryParse(_ssc.text),
        hscGpa: double.tryParse(_hsc.text),
        photoUrl: _photoPath,
        status: 'pending',
        digitalId: digitalId, 
        createdAt: DateTime.now(),
      );

      // ২. লোকাল সার্ভিস কল (ঐচ্ছিক)
      StudentDataService.addStudent(student);

      // ৩. ফায়ারবেস ফায়ারস্টোরে ডাটা সেভ করা (UID কে ডকুমেন্ট আইডি হিসেবে ব্যবহার করে)
      await FirebaseFirestore.instance.collection('students').doc(uid).set({
        'id': uid,
        'fullName': student.fullName,
        'email': student.email,
        'phone': student.phone,
        'department': student.department,
        'sscGpa': student.sscGpa,
        'hscGpa': student.hscGpa,
        'photoUrl': student.photoUrl,
        'sscMarksheetPath': _sscPath, 
        'hscMarksheetPath': _hscPath, 
        'status': 'pending',
        'digitalId': digitalId,
        'createdAt': student.createdAt,
      });

      if (!mounted) return;
      setState(() => isLoading = false);
      _showSuccessDialog(lang, digitalId);

    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);
      _showError(e.message ?? "Authentication failed");
    } catch (e) {
      setState(() => isLoading = false);
      _showError("Error: $e");
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  // --- বাকি UI ডিজাইন একই থাকবে ---
  // (স্মরণ করিয়ে দিচ্ছি: লিন্ট এরর এড়াতে withOpacity এর জায়গায় .withValues(alpha: ...) ব্যবহার করবেন)
  
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
      backgroundColor: const Color(0xFFF8F9FE),
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
                _photoPicker(lang),
                const SizedBox(height: 20),
                
                _sectionHeader(Icons.person_pin_rounded, "Personal Information"),
                _field(_name, AppStrings.name[lang]!, Icons.person_outline),
                _field(_father, "Father's Name", Icons.family_restroom_outlined),
                _field(_mother, "Mother's Name", Icons.family_restroom_outlined),
                
                const SizedBox(height: 10),
                _sectionHeader(Icons.contact_mail_rounded, "Contact Info"),
                _field(_email, AppStrings.email[lang]!, Icons.email_outlined, type: TextInputType.emailAddress),
                _field(_phone, AppStrings.phone[lang]!, Icons.phone_android_outlined, type: TextInputType.phone),
                
                const SizedBox(height: 10),
                _sectionHeader(Icons.school_rounded, "Academic Details"),
                _departmentDropdown(),
                Row(
                  children: [
                    Expanded(child: _field(_ssc, 'SSC GPA', Icons.grade_outlined, type: TextInputType.number)),
                    const SizedBox(width: 15),
                    Expanded(child: _field(_hsc, 'HSC GPA', Icons.grade_outlined, type: TextInputType.number)),
                  ],
                ),

                const SizedBox(height: 10),
                _sectionHeader(Icons.file_copy_rounded, "Academic Documents (Optional)"),
                _uploadBox(AppStrings.sscMarksheet[lang]!, _sscPath, () => _pickFile('ssc')),
                const SizedBox(height: 10),
                _uploadBox(AppStrings.hscMarksheet[lang]!, _hscPath, () => _pickFile('hsc')),
                
                const SizedBox(height: 15),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      AppStrings.optionalNote[lang]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    ),
                  ),
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
                        color: Colors.indigo.withValues(alpha: 0.3), // ✅ fixed deprecated lint
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _submit(lang), // ✅ লোডিং থাকলে বাটন ডিজেবল
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Application',
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

  // --- Helper Widgets (আগের মতোই থাকবে) ---
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

  Widget _uploadBox(String label, String path, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: path.isEmpty ? Colors.grey.shade200 : Colors.green.shade300, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)], // ✅ fixed lint
        ),
        child: Row(
          children: [
            Icon(path.isEmpty ? Icons.upload_file : Icons.check_circle, 
                 color: path.isEmpty ? Colors.indigo.shade300 : Colors.green),
            const SizedBox(width: 15),
            Expanded(child: Text(label, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500))),
            if (path.isNotEmpty) const Icon(Icons.attach_file, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5))], // ✅ fixed lint
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5))], // ✅ fixed lint
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

  Widget _photoPicker(String lang) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.indigo.shade100, width: 3),
                  boxShadow: [BoxShadow(color: Colors.indigo.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 2)], // ✅ fixed lint
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
            onPressed: () => _pickFile('photo'),
            icon: const Icon(Icons.upload_file, size: 18),
            label: Text(AppStrings.uploadPhoto[lang]!, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            style: TextButton.styleFrom(foregroundColor: Colors.indigo),
          ),
        ],
      ),
    );
  }
}