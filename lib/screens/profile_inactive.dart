import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxitaxi_driver/helpers/constants.dart';
import 'package:taxitaxi_driver/helpers/screen_navigation.dart';
import 'package:taxitaxi_driver/screens/home.dart';
import 'package:taxitaxi_driver/widgets/cab_button.dart';
import 'package:taxitaxi_driver/widgets/cab_text.dart';

class ProfileInactive extends StatefulWidget {
  const ProfileInactive({super.key});

  @override
  State<ProfileInactive> createState() => _ProfileInactiveState();
}

class _ProfileInactiveState extends State<ProfileInactive> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CabText(
                "Profile is sent to the Admin, He will verify your profile and then Active it.",
                align: TextAlign.center,
                size: 18,
              ),
              const SizedBox(height: 40),
              CabButton(
                  text: "Refresh Status",
                  func: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    setState(() {
                      isLoading = true;
                    });
                    DocumentSnapshot snap = await FirebaseFirestore.instance
                        .collection("drivers")
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .get();
                    if ((snap.data() as Map)["isActive"]) {
                      setState(() {
                        isLoading = false;
                        prefs.setBool(profilePref, true);
                        changeScreenReplacement(context, const HomeScreen());
                      });
                    }
                    setState(() {
                      isLoading = false;
                    });
                  },
                  isLoading: isLoading)
            ],
          ),
        ),
      ),
    );
  }
}
