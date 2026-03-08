import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import '../home/languages/language_provider.dart';
// নতুন ইম্পোর্টটি যুক্ত করা হয়েছে
import 'waiting_approval_screen.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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

  // আপডেট করা সাবমিট মেথড
  void _submit(String lang) async {
    if (!_formKey.currentState!.validate()) return;
    
    // ফাইল চেক
    if (_photoPath.isEmpty || _sscPath.isEmpty || _hscPath.isEmpty) {
      _showError("Please upload your photo and all marksheets.");
      return;
    }

    setState(() => _isLoading = true); 

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _phone.text.trim(), 
      );

      final String uid = userCredential.user!.uid; 
      
      // ডাটাবেজে ডাটা সেভ (কালেকশন নাম 'users' হিসেবে আপডেট করা হয়েছে আপনার চাহিদা অনুযায়ী)
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'id': uid,
        'fullName': _name.text,
        'email': _email.text,
        'phone': _phone.text,
        'role': 'student',
        'department': _selectedDept ?? 'General',
        'sscGpa': double.tryParse(_ssc.text),
        'hscGpa': double.tryParse(_hsc.text),
        'photoUrl': _photoPath,
        'sscMarksheetPath': _sscPath, 
        'hscMarksheetPath': _hscPath, 
        'status': 'pending',
        'createdAt': DateTime.now(),
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      // সরাসরি ওয়েটিং স্ক্রিনে চলে যাবে
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (_) => const WaitingApprovalScreen()),
        (route) => false
      );

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
      body: Stack(
        children: [
          Container(
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
                        const SizedBox(width: 48),
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
                                const Padding(
                                  padding: EdgeInsets.only(top: 10, left: 5),
                                  child: Text(
                                    "* Please upload files in PDF or Image format only.",
                                    style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 40),
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
                                  child: const Text("SUBMIT APPLICATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
          // ওয়েটিং পেজ ওভারলে
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      "Processing Your Application...",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Text(
                        "Please wait a moment while we set up your profile.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // নিচের ডিজাইন উইজেটগুলো অপরিবর্তিত রাখা হয়েছে
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
        initialValue: _selectedDept,
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
            Expanded(child: Text(label, style: TextStyle(color: path.isEmpty ? Colors.grey.shade700 : Colors.green.shade700), overflow: TextOverflow.ellipsis)),
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
          // বাস্তব অ্যাপে এখানে FileImage ব্যবহার করতে হবে যদি লোকাল পাথ থাকে
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
}