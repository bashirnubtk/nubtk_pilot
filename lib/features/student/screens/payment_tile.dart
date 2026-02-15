import 'package:flutter/material.dart';
import '../../payment/payment_model.dart'; // এই ইমপোর্টটি নিশ্চিত করুন

class PaymentTile extends StatelessWidget {
  final Installment installment;
  final VoidCallback? onPay;

  const PaymentTile({super.key, required this.installment, this.onPay});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: installment.isPaid ? Colors.green.withAlpha(30) : Colors.orange.withAlpha(30),
          child: Icon(
            installment.isPaid ? Icons.check_circle : Icons.pending_actions,
            color: installment.isPaid ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(
          'Installment ${installment.semester}', // এখানে 'semester' এখন মডেলে আছে
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Amount: ৳${installment.amount.toStringAsFixed(0)}\nDue Date: ${installment.dueDate.toLocal().toString().split(' ')[0]}',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        trailing: installment.isPaid
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("Paid", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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