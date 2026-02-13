import 'package:flutter/material.dart';
import '../student_services/digital_id_pdf_service.dart';

class DigitalIdCardPreview extends StatelessWidget {
  final String name;
  final String department;
  final String digitalId;
  final String status;

  const DigitalIdCardPreview({
    super.key,
    required this.name,
    required this.department,
    required this.digitalId,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    if (status != 'approved') {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.indigo, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Digital Student ID",
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "VERIFIED",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Text(department,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ID: $digitalId",
                    style: const TextStyle(
                        color: Colors.white,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500),
                  ),
                  const Icon(Icons.qr_code_2, color: Colors.white54, size: 32),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // PDF ডাউনলোড বাটন
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              DigitalIdPdfService.generateAndDownload(
                name: name,
                department: department,
                digitalId: digitalId,
              );
            },
            icon: const Icon(Icons.download),
            label: const Text("Download ID as PDF"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade50,
              foregroundColor: Colors.indigo,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.indigo),
              ),
            ),
          ),
        ),
      ],
    );
  }
}