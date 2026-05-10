//D:\projects\nubtk_pilot\lib\features\auth\email_service.dart
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static Future<void> sendApprovalEmail({
    required String recipientEmail,
    required String studentName,
    required String digitalId,
    required String password, // এটি মূলত ফোন নম্বর
    required double totalFee,
    required double waiver,
    required double netPayable,
  }) async {
    // আপনার জিমেইল অ্যাপ পাসওয়ার্ড এখানে ব্যবহার করা হয়েছে
    String username = 'alambashir257@gmail.com'; 
    String smtpPassword = 'frox izll aucc xujm'; 

    final smtpServer = gmail(username, smtpPassword);

    final message = Message()
      ..from = Address(username, 'NUBTK Admission Department')
      ..recipients.add(recipientEmail)
      ..subject = 'Admission Confirmed - Welcome to NUBTK'
      ..html = """
        <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; padding: 30px; color: #333; line-height: 1.6; max-width: 600px; margin: auto; border: 1px solid #e0e0e0; border-radius: 12px;">
          <div style="text-align: center; margin-bottom: 20px;">
            <h1 style="color: #1a237e; margin-bottom: 5px;">Congratulations!</h1>
            <p style="font-size: 18px; color: #555;">Welcome to the NUBTK Family, <strong>$studentName</strong></p>
          </div>
          
          <p>We are pleased to inform you that your admission application has been approved. You can now access the <b>NUBTK Pilot App</b> using the following credentials:</p>
          
          <div style="background: #f0f2ff; padding: 20px; border-radius: 10px; border-left: 5px solid #1a237e; margin: 20px 0;">
            <p style="margin: 5px 0;"><strong>Digital ID:</strong> <span style="color: #1a237e; font-family: monospace; font-size: 16px;">$digitalId</span></p>
            <p style="margin: 5px 0;"><strong>Login Password:</strong> <span style="color: #d32f2f;">$password (Your Mobile Number)</span></p>
          </div>

          <h3 style="color: #1a237e; border-bottom: 2px solid #f4f4f4; padding-bottom: 8px;">Financial Summary (Full Course)</h3>
          <table style="width: 100%; margin-top: 10px; border-collapse: collapse;">
            <tr>
              <td style="padding: 8px 0; color: #666;">Total Course Fee:</td>
              <td style="text-align: right; font-weight: 500;">TK ${totalFee.toStringAsFixed(0)}</td>
            </tr>
            <tr>
              <td style="padding: 8px 0; color: #666;">Academic Waiver:</td>
              <td style="text-align: right; color: #2e7d32; font-weight: 500;">- TK ${waiver.toStringAsFixed(0)}</td>
            </tr>
            <tr style="border-top: 2px solid #1a237e;">
              <td style="padding: 12px 0; font-weight: bold; font-size: 16px;">Net Payable Amount:</td>
              <td style="text-align: right; font-weight: bold; font-size: 16px; color: #1a237e;">TK ${netPayable.toStringAsFixed(0)}</td>
            </tr>
          </table>
          
          <div style="margin-top: 30px; padding: 15px; background: #fff9c4; border-radius: 8px; font-size: 13px; color: #856404;">
            <strong>Security Tip:</strong> For your security, please do not share your login credentials with others. You can update your profile information through the app.
          </div>

          <p style="margin-top: 30px;">If you have any questions, feel free to contact our support team.</p>
          <p>Best Regards,<br><strong>NUBTK Admission Team</strong></p>
        </div>
      """;

    try {
      await send(message, smtpServer);
      print('Email sent successfully to $recipientEmail');
    } catch (e) {
      print('Mailer Error: $e');
      rethrow; // এররটি হ্যান্ডেল করার জন্য রিথ্রো করা ভালো
    }
  }
}