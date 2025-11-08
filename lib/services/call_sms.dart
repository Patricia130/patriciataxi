import 'package:url_launcher/url_launcher_string.dart';

class CallsAndMessagesService {
  void call(String number) => canLaunchUrlString("tel:$number");
  void sendSms(String number) => canLaunchUrlString("sms:$number");
  void sendEmail(String email) => canLaunchUrlString("mailto:$email");
}
