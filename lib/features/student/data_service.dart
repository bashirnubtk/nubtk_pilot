import 'student_model.dart';

class StudentDataService {
  /// 🔹 Temporary local database
  static final List<StudentModel> _students = [];

  /// 🔹 Submit admission / registration
  static void addStudent(StudentModel student) {
    _students.add(student);
  }

  /// 🔹 Get all students (Admin side)
  static List<StudentModel> getAllStudents() {
    return _students;
  }

  /// 🔹 Approve student (Admin action)
  static void approveStudent(String studentId) {
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
        status: 'approved',
        digitalId: _generateDigitalId(old),
        createdAt: old.createdAt,
      );
    }
  }

  /// 🔹 Reject student
  static void rejectStudent(String studentId) {
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
        status: 'rejected',
        digitalId: '',
        createdAt: old.createdAt,
      );
    }
  }

  /// 🔹 Digital ID Generator
  static String _generateDigitalId(StudentModel student) {
    final year = DateTime.now().year;
    final last4 = student.phone.substring(student.phone.length - 4);
    return 'NUBTK-$year-$last4';
  }
}
