import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taxitaxi_driver/helpers/constants.dart';
import 'package:taxitaxi_driver/models/user.dart';

import '../helpers/methods.dart';

class UserServices {
  String collection = "drivers";

  Future createUser(
      {required String id,
      required String name,
      required String email,
      required String phone,
      required String token,
      required String type,
      required String car,
      required String plate,
      required XFile image,
      required XFile idProof,
      required XFile carIdProof,
      required Map position}) async {
    String url = await uploadImage(File(image.path), id);
    String idProofUrl = await uploadImage(File(idProof.path), "$id-ID-Proof");
    String carIdProof =
        await uploadImage(File(idProof.path), "$id-Vehicle-Proof");
    await firebaseFiretore.collection(collection).doc(id).set({
      "name": name,
      "id": id,
      "phone": phone,
      "email": email,
      "trips": [],
      "photo": url,
      "position": position,
      "car": car,
      "plate": plate,
      "type": type,
      "token": token,
      "online": false,
      "isActive": false,
      "idProof": idProofUrl,
      "vehicleProof": carIdProof
    });
  }

  void updateUserData(Map<String, dynamic> values) {
    if (FirebaseAuth.instance.currentUser != null) {
      firebaseFiretore
          .collection(collection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(values);
    }
  }

  void addDeviceToken({required String token, required String userId}) {
    firebaseFiretore
        .collection(collection)
        .doc(userId)
        .update({"token": token});
  }

  Future<UserModel> getUserById(String id) =>
      firebaseFiretore.collection(collection).doc(id).get().then((doc) {
        return UserModel.fromSnapshot(doc);
      });
  Future<String?> changePassword(
      {required String currentPassword,
      required String newPassword,
      required BuildContext context}) async {
    final user = FirebaseAuth.instance.currentUser;
    final cred = EmailAuthProvider.credential(
        email: user!.email!, password: currentPassword);
    FocusScope.of(context).unfocus();
    try {
      await user.reauthenticateWithCredential(cred);
      try {
        await user
            .updatePassword(newPassword)
            .then((value) => Navigator.of(context).pop());

        showSnack(
            context: context,
            message: 'Password Changed Successfully.',
            color: Colors.green);
      } on FirebaseAuthException catch (e) {
        return e.toString();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "wrong-password") {
        return 'Invalid Password';
      } else {
        return e.toString();
      }
    }
    return null;
  }
}
