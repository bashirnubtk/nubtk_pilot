import 'package:flutter/material.dart';

class PaymentTile extends StatelessWidget {
  final Map<String, dynamic> paymentData; // আমরা সরাসরি ফায়ারস্টোর ম্যাপ ব্যবহার করছি
  final VoidCallback? onDownload; // রিসিট ডাউনলোডের জন্য
  final VoidCallback? onPay;

  const PaymentTile({
    super.key, 
    required this.paymentData, 
    this.onDownload, 
    this.onPay
  });

  @override
  Widget build(BuildContext context) {
    bool isPaid = paymentData['status'] == 'Paid';
    String percentage = paymentData['percentage'] ?? '0%';
    String month = paymentData['month'] ?? 'N/A';

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isPaid ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
          child: Icon(
            isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
            color: isPaid ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(
          'Tuition Fee - $percentage', 
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Month: $month\nStatus: ${isPaid ? "Received" : "Due"}',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        trailing: isPaid
            ? IconButton(
                icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
                onPressed: onDownload, // এখানে ক্লিক করলে পিডিএফ ডাউনলোড হবে
                tooltip: "Download Receipt",
              )
            : ElevatedButton(
                onPressed: onPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Pay'),
              ),
      ),
    );
  }
}