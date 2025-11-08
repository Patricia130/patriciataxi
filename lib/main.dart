import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxitaxi_driver/notifications.dart';
import 'package:taxitaxi_driver/providers/app_provider.dart';
import 'package:taxitaxi_driver/providers/user.dart';
import 'package:taxitaxi_driver/screens/splash.dart';
import 'package:flutter/material.dart';
import 'locators/service_locator.dart';

import 'package:provider/provider.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
          Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  print(notificationAppLaunchDetails?.notificationResponse?.payload);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  NotificationController.init();

  await Geolocator.requestPermission();
  setupLocator();

  return runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AppStateProvider>.value(
        value: AppStateProvider(),
      ),
      ChangeNotifierProvider.value(value: UserProvider.initialize()),
    ],
    child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        title: "Flutter Taxi",
        home: const SplashScreen()),
  ));
}
