import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _isLoading = false;

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

  void _submit(String lang) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true); 

    try {
      // ১. FirebaseAuth-এ অ্যাকাউন্ট তৈরি (পাসওয়ার্ড হিসেবে ফোন নম্বর)
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _phone.text.trim(), 
      );

      final String uid = userCredential.user!.uid; 
      String digitalId = "NUBTK-${DateTime.now().millisecondsSinceEpoch}";

      final student = StudentModel(
        id: uid, 
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

      // ২. ফায়ারস্টোরে ডাটা সেভ (অবশ্যই await করতে হবে)
      await FirebaseFirestore.instance.collection('students').doc(uid).set({
        'id': uid,
        'fullName': student.fullName,
        'email': student.email,
        'phone': student.phone,
        'role': 'student', // এটি পরে অ্যাডমিন প্যানেলে ফিল্টার করতে সাহায্য করবে
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
      setState(() => _isLoading = false); // কাজ শেষ হলে লোডিং বন্ধ
      _showSuccessDialog(lang, digitalId);

    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showError(e.message ?? "Authentication failed");
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showError("Error: $e");
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).languageCode;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // কাস্টম অ্যাপ বার ডিজাইন
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "Registration",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 48), // ব্যালেন্সের জন্য
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FE),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _photoPicker(lang),
                          const SizedBox(height: 30),
                          _buildCardSection("Personal Information", [
                            _field(_name, "Full Name", Icons.person_outline),
                            _field(_father, "Father's Name", Icons.family_restroom_outlined),
                            _field(_mother, "Mother's Name", Icons.family_restroom_outlined),
                          ]),
                          const SizedBox(height: 20),
                          _buildCardSection("Contact & Academic", [
                            _field(_email, "Email Address", Icons.email_outlined, type: TextInputType.emailAddress),
                            _field(_phone, "Phone Number", Icons.phone_android_outlined, type: TextInputType.phone),
                            _departmentDropdown(),
                            Row(
                              children: [
                                Expanded(child: _field(_ssc, 'SSC GPA', Icons.grade_outlined, type: TextInputType.number)),
                                const SizedBox(width: 15),
                                Expanded(child: _field(_hsc, 'HSC GPA', Icons.grade_outlined, type: TextInputType.number)),
                              ],
                            ),
                          ]),
                          const SizedBox(height: 20),
                          _buildCardSection("Documents", [
                            _uploadBox("SSC Marksheet", _sscPath, () => _pickFile('ssc')),
                            const SizedBox(height: 12),
                            _uploadBox("HSC Marksheet", _hscPath, () => _pickFile('hsc')),
                          ]),
                          const SizedBox(height: 40),
                          // সাবমিট বাটন
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () => _submit(lang),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 4,
                              ),
                              child: _isLoading 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("SUBMIT APPLICATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ডিজাইন উন্নত করার জন্য কাস্টম কার্ড সেকশন
  Widget _buildCardSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 10),
          child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo.shade900)),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  // ইমপুট ফিল্ড ডিজাইন (Login এর সাথে সামঞ্জস্য রেখে)
  Widget _field(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.indigo.shade300),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _departmentDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: _selectedDept,
        decoration: InputDecoration(
          labelText: 'Department',
          prefixIcon: Icon(Icons.business, color: Colors.indigo.shade300),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
        onChanged: (v) => setState(() => _selectedDept = v),
        validator: (v) => v == null ? 'Required' : null,
      ),
    );
  }

  Widget _uploadBox(String label, String path, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          border: Border.all(color: path.isEmpty ? Colors.grey.shade300 : Colors.green),
          borderRadius: BorderRadius.circular(15),
          color: path.isEmpty ? Colors.transparent : Colors.green.withAlpha(10),
        ),
        child: Row(
          children: [
            Icon(path.isEmpty ? Icons.cloud_upload_outlined : Icons.check_circle, color: path.isEmpty ? Colors.grey : Colors.green),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: path.isEmpty ? Colors.grey.shade700 : Colors.green.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _photoPicker(String lang) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.indigo.shade50,
          backgroundImage: _photoPath.isNotEmpty ? AssetImage(_photoPath) : null,
          child: _photoPath.isEmpty ? Icon(Icons.add_a_photo, size: 40, color: Colors.indigo.shade200) : null,
        ),
        TextButton(
          onPressed: () => _pickFile('photo'),
          child: const Text("Upload Student Photo", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
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
            const Text("Application Submitted!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Text("Your Digital ID: $digitalId\nPlease wait for admin approval.", textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                },
                child: const Text("Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}