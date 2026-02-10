import 'student_model.dart';

class StudentDataService {
  static final List<StudentModel> _students = [];

  // আবেদন জমা দেওয়া
  static void addStudent(StudentModel student) {
    _students.add(student);
  }

  // শুধুমাত্র পেন্ডিং স্টুডেন্টদের লিস্ট পাওয়া
  static List<StudentModel> getPendingStudents() {
    return _students.where((s) => s.status == 'pending').toList();
  }

  // স্ট্যাটাস আপডেট করা (Approve/Reject)
  static void updateStatus(String studentId, String newStatus) {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      final old = _students[index];
      _students[index] = StudentModel(
        id: old.id,
        fullName: old.fullName,
        email: old.email,
        phone: old.phone,
        department: old.department,
        sscGpa: old.sscGpa,
        hscGpa: old.hscGpa,
        photoUrl: old.photoUrl,
        status: newStatus,
        digitalId: newStatus == 'approved' ? _generateDigitalId(old) : '',
        createdAt: old.createdAt,
      );
    }
  }

  // ডিজিটাল আইডি জেনারেশন
  static String _generateDigitalId(StudentModel student) {
    final year = DateTime.now().year;
    final last4 = student.phone.length >= 4 
        ? student.phone.substring(student.phone.length - 4) 
        : student.phone;
    return 'NUBTK-$year-$last4';
  }
}