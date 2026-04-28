import 'package:flutter/material.dart';

class PaymentTile extends StatelessWidget {
  final Map<String, dynamic> paymentData;
  final VoidCallback onPay;

  const PaymentTile({
    super.key,
    required this.paymentData,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    bool isPaid = paymentData['status'] == 'Paid';

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // বাম পাশের আইকন (টাকার ব্যাগ বা চেক)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPaid ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                color: isPaid ? Colors.green : Colors.orange,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            
            // মাঝখানের টেক্সট (সেমিস্টার এবং টাকার পরিমাণ)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paymentData['month'] ?? "Semester Info",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Amount: ${paymentData['percentage']}",
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            ),

            // ডান পাশের বাটন বা স্ট্যাটাস
            isPaid
                ? const Chip(
                    label: Text("PAID"),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  )
                : ElevatedButton(
                    onPressed: onPay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[900],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Pay Now"),
                  ),
          ],
        ),
      ),
    );
  }
}