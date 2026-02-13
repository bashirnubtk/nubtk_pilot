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
      DateTime dueDate = currentDate.add(Duration(days: 60 * i));

      installments.add(
        Installment(
          id: 'INST_$i', // ইউনিক আইডি যোগ করা হলো
          semester: i,    // আপনার লজিক অনুযায়ী কিস্তি নম্বরই সেমিস্টার হিসেবে গেল
          amount: double.parse(installmentAmount.toStringAsFixed(2)),
          dueDate: dueDate,
          isPaid: false,
        ),
      );
    }
    return installments;
  }
}