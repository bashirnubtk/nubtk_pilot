import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PaymentPdfService {
  /// এটি আপনার পেমেন্ট রিসিপ্ট জেনারেট এবং শেয়ার করার মেইন ফাংশন।
  static Future<void> generateReceipt({
    required String name,
    required String digitalId,
    required String month,
    required String percentage,
    required String date,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // হেডার সেকশন
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    "NUBTK - OFFICIAL MONEY RECEIPT",
                    style: pw.TextStyle(
                      color: PdfColors.indigo900,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // স্টুডেন্ট ইনফরমেশন
                pw.Text("Student Name: $name", style: pw.TextStyle(fontSize: 14)),
                pw.Text("Digital ID: $digitalId", style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 10),
                pw.Divider(color: PdfColors.grey),
                pw.SizedBox(height: 10),

                // পেমেন্ট ডিটেইলস
                pw.Bullet(text: "Payment For: Tuition Fee ($percentage)"),
                pw.Bullet(text: "Payment Month: $month"),
                pw.Bullet(text: "Payment Date: $date"),
                pw.SizedBox(height: 40),

                // পেমেন্ট স্ট্যাটাস বক্স
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.green100,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Text(
                    "STATUS: PAID SUCCESSFULLY",
                    style: pw.TextStyle(
                      color: PdfColors.green900,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                pw.Spacer(),

                // সিগনেচার এরিয়া
                pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        width: 150,
                        child: pw.Divider(color: PdfColors.black, thickness: 1),
                      ),
                      pw.Text(
                        "Authorized Signature\nNorthern University Business & Tech Khulna",
                        textAlign: pw.TextAlign.right,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // পিডিএফটি সেভ করে শেয়ার অপশন ওপেন করবে
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "Receipt_${name.replaceAll(' ', '_')}_$month.pdf",
    );
  }
}