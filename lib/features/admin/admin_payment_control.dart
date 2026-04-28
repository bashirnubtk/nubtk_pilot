import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPaymentControl extends StatefulWidget {
  final String studentId;
  const AdminPaymentControl({super.key, required this.studentId});

  @override
  State<AdminPaymentControl> createState() => _AdminPaymentControlState();
}

class _AdminPaymentControlState extends State<AdminPaymentControl> {
  String selectedPercent = "100%"; // ডিফল্ট সিলেকশন
  bool isCreating = false;

  final List<String> paymentOptions = ["30%", "40%", "70%", "100%"];

  // পেমেন্ট রিকোয়েস্ট তৈরির লজিক
  Future<void> _createPaymentRequest() async {
    setState(() => isCreating = true);

    try {
      final String month = "${DateTime.now().month}-${DateTime.now().year}";
      
      // ফায়ারস্টোরে পেমেন্ট ডাটা সেভ করা
      await FirebaseFirestore.instance.collection('payments').add({
        'studentId': widget.studentId,
        'percentage': selectedPercent,
        'status': 'Due', // শুরুতে বকেয়া থাকবে
        'month': month,
        'createdAt': FieldValue.serverTimestamp(),
        'isNotified': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$selectedPercent পেমেন্ট রিকোয়েস্ট সফলভাবে পাঠানো হয়েছে!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      setState(() => isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Generate Payment Plan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          const SizedBox(height: 15),
          
          // পার্সেন্টেজ চয়েস চিপস
          Wrap(
            spacing: 10,
            children: paymentOptions.map((option) {
              return ChoiceChip(
                label: Text(option),
                selected: selectedPercent == option,
                onSelected: (selected) {
                  setState(() => selectedPercent = option);
                },
                selectedColor: Colors.indigo,
                labelStyle: TextStyle(
                  color: selectedPercent == option ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 25),

          // পেমেন্ট ক্রিয়েট বাটন
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: isCreating 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.send_rounded),
              onPressed: isCreating ? null : _createPaymentRequest,
              label: Text(isCreating ? "Processing..." : "Create Payment Notification"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}