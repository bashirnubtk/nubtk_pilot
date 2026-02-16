import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static Future<void> sendDigitalID({
    required String recipientEmail,
    required String studentName,
    required String digitalId,
  }) async {
    // এখানে আপনার আসল জিমেইল এবং সেই ১৬ অক্ষরের অ্যাপ পাসওয়ার্ড দিন
    String username = 'alambashir257@gmail.com'; 
    String password = 'frox izll aucc xujm'; 

    final smtpServer = gmail(username, password);

    // ইমেইল কন্টেন্ট
    final message = Message()
      ..from = Address(username, 'NUBTK Admin')
      ..recipients.add(recipientEmail)
      ..subject = 'Congratulations! Your NUBTK Digital ID is ready'
      ..html = """
        <h3>Hello $studentName,</h3>
        <p>Your project analysis is complete and your Digital ID has been generated.</p>
        <p><b>Your Digital ID: $digitalId</b></p>
        <br>
        <p>Regards,<br>NUBTK Pilot Team</p>
      """;

    try {
      await send(message, smtpServer);
      print('Email sent successfully to $recipientEmail');
    } catch (e) {
      print('Error sending email: $e');
    }
  }
}