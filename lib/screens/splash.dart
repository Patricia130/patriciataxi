import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxitaxi_driver/screens/profile_inactive.dart';
import '../helpers/constants.dart';
import '../helpers/screen_navigation.dart';

import '../helpers/style.dart';
import 'home.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(authPref) && prefs.getString(authPref) != "") {
      if (prefs.getBool(profilePref) ?? true) {
        Future.delayed(const Duration(seconds: 3)).whenComplete(
            () => changeScreenReplacement(context, const HomeScreen()));
      } else {
        Future.delayed(const Duration(seconds: 3)).whenComplete(
            () => changeScreenReplacement(context, const ProfileInactive()));
      }
    } else {
      Future.delayed(const Duration(seconds: 3)).whenComplete(
          () => changeScreenReplacement(context, const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: primaryColor,
        body: Center(
          child: Hero(
              tag: "logo-shift",
              child: Image.asset(
                'assets/logo-tb.png',
                //color: Colors.white,
              )),
        ));
  }
}
