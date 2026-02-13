class PaymentModel {
  final String studentId;
  final double totalCourseFee;
  final double waiverPercent;
  final double finalPayableAmount;
  final String paymentPlan;
  final int totalInstallments;
  final List<Installment> installments;

  PaymentModel({
    required this.studentId,
    required this.totalCourseFee,
    required this.waiverPercent,
    required this.finalPayableAmount,
    required this.paymentPlan,
    required this.totalInstallments,
    required this.installments,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'totalCourseFee': totalCourseFee,
      'waiverPercent': waiverPercent,
      'finalPayableAmount': finalPayableAmount,
      'paymentPlan': paymentPlan,
      'totalInstallments': totalInstallments,
      'installments': installments.map((e) => e.toMap()).toList(),
    };
  }
}

class Installment {
  final String id; // আইডি যোগ করা হয়েছে
  final int semester; // ড্যাশবোর্ডের টেক্সটের জন্য যোগ করা হয়েছে
  final double amount;
  final DateTime dueDate;
  final bool isPaid;

  Installment({
    required this.id,
    required this.semester,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
  });

  // এই factory মেথডটি Firebase থেকে ডাটা পড়তে সাহায্য করবে
  factory Installment.fromMap(Map<String, dynamic> map) {
    return Installment(
      id: map['id'] ?? '',
      semester: map['semester'] ?? map['installmentNumber'] ?? 0,
      amount: (map['amount'] ?? 0).toDouble(),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : DateTime.now(),
      isPaid: map['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'semester': semester,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'isPaid': isPaid,
    };
  }
}