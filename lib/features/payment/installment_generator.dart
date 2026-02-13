import 'payment_model.dart';

class InstallmentGenerator {
  static List<Installment> generateSemesterInstallments({
    required double finalAmount,
  }) {
    const totalSemesters = 8;
    const installmentsPerSemester = 3;
    const totalInstallments = totalSemesters * installmentsPerSemester;

    final installmentAmount = finalAmount / totalInstallments;
    List<Installment> installments = [];
    DateTime currentDate = DateTime.now();

    for (int i = 1; i <= totalInstallments; i++) {
      // প্রতি ২ মাস অন্তর কিস্তির ডেট সেট করা হচ্ছে
      DateTime dueDate = currentDate.add(Duration(days: 60 * i));

      installments.add(
        Installment(
          installmentNumber: i,
          amount: double.parse(installmentAmount.toStringAsFixed(2)), // দশমিক ২ ঘর পর্যন্ত
          dueDate: dueDate,
          isPaid: false,
        ),
      );
    }
    return installments;
  }
}