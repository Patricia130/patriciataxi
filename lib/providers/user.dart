import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:taxitaxi_driver/helpers/constants.dart';
import 'package:taxitaxi_driver/models/user.dart';
import 'package:taxitaxi_driver/services/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/methods.dart';
import '../helpers/screen_navigation.dart';
import '../screens/home.dart';
import '../screens/profile_inactive.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  final UserServices _userServices = UserServices();
  UserModel? _userModel;

//  getter
  UserModel? get userModel => _userModel;

  User? get user => _user;

  // public variables
  final formkey = GlobalKey<FormState>();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();

  UserProvider.initialize() {
    _fireSetUp();
  }

  _fireSetUp() async {
    await initialization.then((value) {
      auth.authStateChanges().listen(_onStateChanged);
    });
  }

  Future signIn(String email, String password, BuildContext context) async {
    try {
      FocusScope.of(context).unfocus();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        await prefs.setString(authPref, value.user!.uid);
        await prefs.setBool(loggedInPref, true);
        await _userServices.getUserById(value.user!.uid).then((v) {
          _userModel = v;
          prefs.setBool(profilePref, v.isActive);
          changeScreenReplacement(context,
              v.isActive ? const HomeScreen() : const ProfileInactive());
        });
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnack(context: context, message: 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showSnack(
            context: context,
            message: 'Wrong password provided for that user.');
      } else {
        showSnack(context: context, message: e.message ?? "");
      }
    } catch (e) {
      showSnack(context: context, message: e.toString());
    }
    notifyListeners();
  }

  Future signUp(
      String email,
      String password,
      String name,
      String phone,
      XFile image,
      String type,
      String car,
      String plate,
      Position position,
      XFile idProof,
      XFile carIdProof,
      BuildContext context) async {
    try {
      FocusScope.of(context).unfocus();
      await auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((result) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String deviceToken = await fcm.getToken() ?? "";
        await _userServices.createUser(
            image: image,
            id: result.user!.uid,
            name: name,
            email: email,
            phone: phone,
            type: type,
            car: car,
            plate: plate,
            position: position.toJson(),
            token: deviceToken,
            carIdProof: carIdProof,
            idProof: idProof);
        await prefs.setString(authPref, result.user!.uid);
        await prefs.setBool(loggedInPref, true);

        await _userServices.getUserById(result.user!.uid).then((v) {
          _userModel = v;
          prefs.setBool(profilePref, v.isActive);
          changeScreenReplacement(context,
              v.isActive ? const HomeScreen() : const ProfileInactive());
          notifyListeners();
        });
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnack(
            context: context, message: 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showSnack(
            context: context,
            message: 'The account already exists for that email.');
      } else {
        showSnack(context: context, message: e.message ?? "");
      }
    } catch (e) {
      showSnack(context: context, message: e.toString());
    }
    notifyListeners();
  }

  Future signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    auth.signOut();

    await prefs.remove(requestIdPref);
    await prefs.remove(authPref);
    await prefs.setBool(loggedInPref, false);
  }

  void clearController() {
    name.text = "";
    password.text = "";
    email.text = "";
    phone.text = "";
  }

  Future<void> reloadUserModel() async {
    _userModel = await _userServices.getUserById(user!.uid);
    notifyListeners();
  }

  Future updateUserData(Map<String, dynamic> data) async {
    _userServices.updateUserData(data);
  }

  saveDeviceToken() async {
    String? deviceToken = await fcm.getToken();
    if (deviceToken != null) {
      _userServices.addDeviceToken(userId: user!.uid, token: deviceToken);
    }
  }

  _onStateChanged(User? firebaseUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (firebaseUser == null) {
    } else {
      _user = firebaseUser;
      await prefs.setString(authPref, firebaseUser.uid);

      _userModel = await _userServices.getUserById(user!.uid).then((value) {
        return value;
      });
    }
    notifyListeners();
  }
}
