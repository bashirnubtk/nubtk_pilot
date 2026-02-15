import '../models/student_model.dart';

class StudentDataService {
  static final List<StudentModel> _students = [];

  static void addStudent(StudentModel student) {
    _students.add(student);
  }

  static List<StudentModel> getPendingStudents() {
    return _students.where((s) => s.status == 'pending').toList();
  }

  // লগইন চেক করার মেথড
  static StudentModel? loginStudent(String email, String digitalId) {
    try {
      return _students.firstWhere(
        (s) => s.email.trim() == email.trim() && s.digitalId.trim() == digitalId.trim(),
      );
    } catch (_) {
      return null;
    }
  }

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

  static String _generateDigitalId(StudentModel student) {
    final year = DateTime.now().year;
    final last4 = student.phone.length >= 4 
        ? student.phone.substring(student.phone.length - 4) 
        : student.phone;
    return 'NUBTK-$year-$last4';
  }
}