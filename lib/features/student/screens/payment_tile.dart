// D:\projects\nubtk_pilot\lib\features\student\screens\payment_tile.dart

import 'package:flutter/material.dart';
import '../student_services/payment_pdf_service.dart';

class PaymentTile extends StatelessWidget {
  final Map<String, dynamic> paymentData;
  final VoidCallback onPay;
  final Map<String, dynamic>? studentData;

  const PaymentTile({
    super.key,
    required this.paymentData,
    required this.onPay,
    this.studentData,
  });

  @override
  Widget build(BuildContext context) {
    // ডাটাবেজ থেকে আসা স্ট্যাটাস চেক
    bool isPaid = paymentData['status'] == 'Paid';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Opacity(
        // পেইড হলে কার্ডের অপাসিটি কিছুটা কমিয়ে দেওয়া হয়েছে
        opacity: isPaid ? 0.8 : 1.0,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          leading: CircleAvatar(
            backgroundColor: isPaid
                ? Colors.green.withOpacity(0.2)
                : Colors.orange.withOpacity(0.2),
            child: Icon(
              isPaid ? Icons.check_circle : Icons.pending_actions,
              color: isPaid ? Colors.green : Colors.orange,
            ),
          ),
          title: Text(
            paymentData['title'] ?? "Tuition Fee",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: isPaid ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text("Amount: ${paymentData['amount']}"),
          trailing: isPaid
              ? ElevatedButton.icon(
                  onPressed: () {
                    // পিডিএফ রিসিট জেনারেশন সার্ভিস কল
                    PaymentPdfService.generateReceipt(
                      name: studentData?['fullName'] ?? "Student",
                      digitalId: studentData?['studentId'] ?? "N/A",
                      month: paymentData['title'] ?? "N/A",
                      percentage: paymentData['amount'] ?? "0",
                      date: DateTime.now().toString().split(' ')[0],
                    );
                  },
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text("Receipt"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                  ),
                )
              : ElevatedButton(
                  onPressed: onPay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Pay Now"),
                ),
        ),
      ),
    );
  }
}
