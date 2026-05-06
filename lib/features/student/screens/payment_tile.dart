// D:\projects\nubtk_pilot\lib\features\student\screens\payment_tile.dart

import 'package:flutter/material.dart';
// আপনার প্রজেক্টের ফোল্ডার স্ট্রাকচার অনুযায়ী সঠিক পাথটি ব্যবহার করুন
import '../student_services/payment_pdf_service.dart';

class PaymentTile extends StatelessWidget {
  final Map<String, dynamic> studentData;
  final Map<String, dynamic> paymentData;
  final VoidCallback onPay;

  const PaymentTile({
    super.key,
    required this.studentData,
    required this.paymentData,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    // পেমেন্ট স্ট্যাটাস চেক
    bool isPaid = paymentData['status'] == 'Paid';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Opacity(
        // পেইড হলে কার্ডের অপাসিটি কিছুটা কমিয়ে দেওয়া হয়েছে (০.৮)
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
            // এখানে 'month' কি-টি ব্যবহার করা হয়েছে যা 'Semester X (Session Y)' দেখাবে
            paymentData['month'] ?? paymentData['title'] ?? "Tuition Fee",
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
                      name: studentData['fullName'] ?? "Student",
                      digitalId: studentData['studentId'] ?? "N/A",
                      month: paymentData['month'] ?? "N/A",
                      percentage: paymentData['amount']?.toString() ?? "0",
                      date: DateTime.now().toString().split(' ')[0],
                    );
                  },
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text("Receipt"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              : ElevatedButton(
                  onPressed: onPay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Pay Now"),
                ),
        ),
      ),
    );
  }
}
