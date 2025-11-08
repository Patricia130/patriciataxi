import 'package:flutter/material.dart';

Future showCustomDialog(
    BuildContext context, double height, Widget dialogWidget) async {
  showGeneralDialog(
    context: context,
    barrierLabel: "Barrier",
    barrierDismissible: false,
    //   barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 700),
    pageBuilder: (_, __, ___) {
      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Center(
          child: Container(
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Material(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(child: dialogWidget),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return FadeTransition(opacity: anim, child: child);
    },
  );
}
