import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../widgets/cab_text.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase().replaceAll("*", '')}";
  }
}

showSnack(
    {required BuildContext context,
    required String message,
    Color? color,
    double? margin}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.only(bottom: margin ?? 30, left: 20, right: 20),
    content: CabText(
      message,
      size: 14,
      color: Colors.white,
    ),
    backgroundColor: color ?? const Color(0xFF080808),
  ));
}

Future<String> uploadImage(var imageFile, id) async {
  String url = "";
  Reference ref = FirebaseStorage.instance.ref("drivers/").child(id);
  UploadTask uploadTask = ref.putFile(imageFile);
  await uploadTask.then((res) async {
    url = await res.ref.getDownloadURL();
    return url;
  });

  return url;
}
