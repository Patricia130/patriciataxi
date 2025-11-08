// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';

// class NotificationController extends ChangeNotifier {
//   static final NotificationController _instance =
//       NotificationController._internal();

//   factory NotificationController() {
//     return _instance;
//   }

//   NotificationController._internal();

//   String _firebaseToken = '';
//   String get firebaseToken => _firebaseToken;

//   String _nativeToken = '';
//   String get nativeToken => _nativeToken;

//   ReceivedAction? initialAction;
//   static Future<void> initializeLocalNotifications() async {
//     await AwesomeNotifications().initialize(
//         null,
//         [
//           NotificationChannel(
//               channelKey: 'call_notification',
//               channelName: 'Alerts',
//               channelDescription: 'Notification tests as alerts',
//               playSound: true,
//               importance: NotificationImportance.High,
//               defaultPrivacy: NotificationPrivacy.Private,
//               defaultColor: Colors.deepPurple,
//               ledColor: Colors.deepPurple)
//         ],
//         debug: true);

//     // Get initial notification action is optional
//     await AwesomeNotifications()
//         .getInitialNotificationAction(removeFromActionEvents: false)
//         .then((value) => print("value ${value?.toMap() ?? ""}"));
//   }

//   static Future<void> initializeRemoteNotifications() async {
//     await Firebase.initializeApp();
//     await AwesomeNotificationsFcm().initialize(
//         onFcmSilentDataHandle: NotificationController.mySilentDataHandle,
//         onFcmTokenHandle: NotificationController.myFcmTokenHandle,
//         debug: true);

//   }

//   static Future<void> mySilentDataHandle(FcmSilentData silentData) async {
//     // Fluttertoast.showToast(
//     //     msg: 'Silent data received',
//     //     backgroundColor: Colors.blueAccent,
//     //     textColor: Colors.white,
//     //     fontSize: 16);

//     print('"SilentData": ${silentData.toString()}');

//     if (silentData.createdLifeCycle != NotificationLifeCycle.Foreground) {
//       print("bg");
//     } else {
//       print("FOREGROUND");
//     }

//     print('mySilentDataHandle received a FcmSilentData execution');
//     //  await executeLongTaskInBackground();
//   }

//   static Future<void> myFcmTokenHandle(String token) async {
//     debugPrint('Firebase Token:"$token"');

//     _instance._firebaseToken = token;
//     _instance.notifyListeners();
//   }

//   static Future<void> startListeningNotificationEvents() async {
//     AwesomeNotifications().setListeners(
//         onActionReceivedMethod: onActionReceivedMethod,
//         onNotificationCreatedMethod: onNotificationCreatedMethod,
//         onNotificationDisplayedMethod: onNotificationDisplayedMethod);
//   }

//   static Future<void> onNotificationCreatedMethod(
//       ReceivedNotification receivedNotification) async {
//     // AwesomeNotifications().createNotification(
//     //   content: NotificationContent(
//     //       id: 0, channelKey: receivedNotification.channelKey!),
//     //   actionButtons: [
//     //     NotificationActionButton(
//     //       key: 'accept',
//     //       label: 'Accept',
//     //     ),
//     //     NotificationActionButton(
//     //       key: 'cancel',
//     //       label: 'Cancel',
//     //     ),
//     //   ],
//     // );
//     print("yash " + receivedNotification.toMap().toString());
//     // MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
//     //     '/notification-page',
//     //     (route) =>
//     //         (route.settings.name != '/notification-page') || route.isFirst,
//     //     arguments: receivedAction);
//   }

//   static Future<void> onNotificationDisplayedMethod(
//       ReceivedNotification receivedNotification) async {
//     print("yash " + receivedNotification.toMap().toString());
//     // MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
//     //     '/notification-page',
//     //     (route) =>
//     //         (route.settings.name != '/notification-page') || route.isFirst,
//     //     arguments: receivedAction);
//   }

//   static Future<void> onActionReceivedMethod(
//       ReceivedAction receivedAction) async {
//     //  print("yash " + receivedAction.toMap().toString());
//     // MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
//     //     '/notification-page',
//     //     (route) =>
//     //         (route.settings.name != '/notification-page') || route.isFirst,
//     //     arguments: receivedAction);
//   }

//   static Future<void> getInitialNotificationAction() async {
//     ReceivedAction? receivedAction = await AwesomeNotifications()
//         .getInitialNotificationAction(removeFromActionEvents: true);
//     if (receivedAction == null) return;

//     // Fluttertoast.showToast(
//     //     msg: 'Notification action launched app: $receivedAction',
//     //   backgroundColor: Colors.deepPurple
//     // );
//     print('Notification action launched app: $receivedAction');
//   }
// }

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'call_channel', // title
  description: 'This channel is used for app notifications.', // description
  importance: Importance.high,
);
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(channel.id, channel.name,
              channelDescription: channel.description,
              icon: '@drawable/ic_stat_notifications'),
        ),
        payload: message.data.toString());
  }
}

class NotificationController extends ChangeNotifier {
  static final NotificationController _instance =
      NotificationController._internal();

  factory NotificationController() {
    return _instance;
  }

  NotificationController._internal();

  static init() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print("from inital ${message.data}");
        // notificationUrl = message.data.toString();
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      flutterLocalNotificationsPlugin.show(
          message.notification.hashCode,
          message.notification!.title,
          message.notification!.body,
          NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description,
                icon: '@drawable/ic_stat_notifications'),
          ),
          payload: message.data.toString());
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      print("from app opened ${event.data}");
    });

    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'call_channel', // title
        description:
            'This channel is used for app notifications.', // description
        importance: Importance.high,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      //Initialization Settings for Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings(
        '@drawable/ic_stat_notifications',
      );
//Initialization Settings for iOS
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
      );

      // selectNotification(String? payload) {
      //   //  urlHelper(payload.toString());
      // }

      //InitializationSettings for initializing settings for both platforms (Android & iOS)
      const InitializationSettings initializationSettings =
          InitializationSettings(
              android: initializationSettingsAndroid,
              iOS: initializationSettingsIOS);

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) {
          //  print(notificationResponse.toString());
        },
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}
