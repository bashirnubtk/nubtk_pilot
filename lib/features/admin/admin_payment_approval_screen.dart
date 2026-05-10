//C:\projects\Flutter project\nubtk_pilot\lib\features\admin\admin_payment_approval_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_student_controller.dart';

class AdminPaymentApprovalScreen extends StatefulWidget {
  const AdminPaymentApprovalScreen({super.key});

  @override
  State<AdminPaymentApprovalScreen> createState() => _AdminPaymentApprovalScreenState();
}

class _AdminPaymentApprovalScreenState extends State<AdminPaymentApprovalScreen> {
  final AdminStudentController controller = AdminStudentController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Payment Status", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 🔥 ফিক্স: arrayContainsAny বাদ দিয়ে শুধু approved স্টুডেন্ট আনছি
        stream: FirebaseFirestore.instance
           .collection('students')
           .where('status', isEqualTo: 'approved')
           .orderBy('approvalDate', descending: true)
           .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No approved students found.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String docId = docs[index].id;

              // কিস্তির হিসাব
              List<dynamic> installments = data['installments']?? [];
              double netPayable = (data['netPayable']?? 0).toDouble();
              double totalPaid = 0;
              // 🔥 ফিক্স: paidCount রিমুভ করলাম, কারণ ইউজ হয় নাই

              for (var inst in installments) {
                if (inst['isPaid'] == true) {
                  totalPaid += (inst['amount']?? 0).toDouble();
                }
              }

              double dueAmount = netPayable - totalPaid;
              double paymentPercent = netPayable > 0? (totalPaid / netPayable) * 100 : 0;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: dueAmount <= 0? Colors.green : Colors.orange,
                    child: Icon(
                      dueAmount <= 0? Icons.check : Icons.pending_actions,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    data['fullName']?? 'Unknown Student',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("ID: ${data['studentId']?? 'N/A'}",
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text("Paid: ৳${totalPaid.toStringAsFixed(0)} / ৳${netPayable.toStringAsFixed(0)}"),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: paymentPercent / 100,
                        backgroundColor: Colors.grey[300],
                        color: dueAmount <= 0? Colors.green : Colors.orange,
                      ),
                      Text("${paymentPercent.toStringAsFixed(1)}% Completed",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow("Total Payable:", "৳${netPayable.toStringAsFixed(0)}"),
                          _buildInfoRow("Total Paid:", "৳${totalPaid.toStringAsFixed(0)}", Colors.green),
                          _buildInfoRow("Due Amount:", "৳${dueAmount.toStringAsFixed(0)}",
                              dueAmount > 0? Colors.red : Colors.green),
                          _buildInfoRow("Waiver:", "৳${(data['waiverAmount']?? 0).toStringAsFixed(0)}"),
                          const Divider(height: 20),
                          const Text("Installment Details:",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 10),
                          // 🔥 ফিক্স: toList() রিমুভ করলাম
                         ...installments.asMap().entries.map((entry) {
                            int idx = entry.key;
                            var inst = entry.value;
                            bool isPaid = inst['isPaid']?? false;
                            // 🔥 ফিক্স: intl বাদ দিয়ে ম্যানুয়াল ডেট ফরম্যাট
                            String dueDateStr = inst['dueDate']?? '';
                            String formattedDate = 'N/A';
                            if (dueDateStr.isNotEmpty) {
                              try {
                                DateTime dueDate = DateTime.parse(dueDateStr);
                                formattedDate = "${dueDate.day}/${dueDate.month}/${dueDate.year}";
                              } catch (e) {
                                formattedDate = dueDateStr;
                              }
                            }

                            return Card(
                              color: isPaid? Colors.green[50] : Colors.orange[50],
                              child: ListTile(
                                dense: true,
                                leading: Icon(
                                  isPaid? Icons.check_circle : Icons.schedule,
                                  color: isPaid? Colors.green : Colors.orange,
                                ),
                                title: Text("${inst['semester']} - ৳${inst['amount']}"),
                                subtitle: Text("Due: $formattedDate"),
                                trailing: isPaid
                                   ? const Text("PAID",
                                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                                    : ElevatedButton(
                                        onPressed: () => _confirmPayment(docId, idx, inst['semester']),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                        child: const Text("Mark Paid",
                                            style: TextStyle(color: Colors.white, fontSize: 12)),
                                      ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor?? Colors.black87)),
        ],
      ),
    );
  }

  void _confirmPayment(String studentUid, int index, String semester) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Payment"),
        content: Text("Mark $semester as PAID?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await controller.makePayment(studentUid, index);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Payment marked as paid!"), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}