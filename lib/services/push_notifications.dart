import 'dart:convert';

import 'package:http/http.dart' as http;

class PushNotificationServices {
  static Future sendNotification(
      {required String deviceToken,
      required String title,
      required String body}) async {
    print(deviceToken);
    print(title);
    print(body);
    http
        .post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
            headers: {
              "Content-Type": "application/json",
              "Authorization":
                  "key=AAAAGGBAWO0:APA91bG-YgUFWja5UNUF9l_oaUlmFRt7KZndy1VKvFjf9Mk9VxiHu72iwaY4wBCvi9jHoIzpoQhOqC3X8MtyV1c9F8WRp2W9cE2zbAibhwiONdbKEzuQ8CJcmBU3C699n4woiPJ8gJ7V"
            },
            body: jsonEncode({
              "to": deviceToken,
              "notification": {
                "title": title,
                "body": body,
              },
              // "data": {
              //   "click_action": "FLUTTER_NOTIFICATION_CLICK",
              // }
            }))
        .then((value) => print(value.body));
  }
}
