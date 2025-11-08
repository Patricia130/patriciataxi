import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taxitaxi_driver/helpers/methods.dart';
import 'package:taxitaxi_driver/helpers/style.dart';
import 'package:taxitaxi_driver/models/ride_fare.dart';
import 'package:taxitaxi_driver/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxitaxi_driver/services/ride_fare_service.dart';

import '../widgets/cab_button.dart';
import '../widgets/cab_text.dart';
import '../widgets/cab_text_field.dart';

class RegisterWorkScreen extends StatefulWidget {
  final Map args;
  const RegisterWorkScreen({super.key, required this.args});

  @override
  RegisterWorkScreenState createState() => RegisterWorkScreenState();
}

class RegisterWorkScreenState extends State<RegisterWorkScreen> {
  late Position position;
  List<RideFare>? rideFares = [];

  @override
  void initState() {
    RideFareService().fetchRideFare().then((value) => setState(() {
          rideFares = value;
          type =
              rideFares?.first.name.trim().toLowerCase().replaceAll(" ", "-");
        }));
    Geolocator.getCurrentPosition().then((value) => setState(() {
          position = value;
        }));
    super.initState();
  }

  GlobalKey<FormState> registerFormKey = GlobalKey();

  TextEditingController carController = TextEditingController();
  TextEditingController plateController = TextEditingController();
  XFile? image;
  XFile? idProof;
  XFile? carIdProof;
  String? type = "car";
  FocusNode carNode = FocusNode();
  FocusNode plateNode = FocusNode();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    UserProvider authProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          color: Colors.white,
        ),
        margin: const EdgeInsets.only(top: 36),
        padding: const EdgeInsets.only(left: 10, top: 10),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 24,
                            //color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const CabText(
                          "Vehicle Settings",
                          // color: Colors.white,
                          size: 18,
                          weight: FontWeight.w500,
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      setState(() {});
                    },
                    child: Container(
                        transform: Matrix4.translationValues(0, 0, 0),
                        height: 60,
                        width: 60,
                        margin: const EdgeInsets.only(bottom: 10, top: 5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(20),
                            image: image == null
                                ? null
                                : DecorationImage(
                                    fit: BoxFit.cover,
                                    image: FileImage(File(image!.path)))),
                        child: image != null
                            ? null
                            : const CabText(
                                "Your\nPhoto",
                                color: black,
                                size: 14,
                                align: TextAlign.center,
                              )),
                  ),
                ],
              ),
            ),

            Center(
              child: GestureDetector(
                onTap: () async {
                  idProof = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  setState(() {});
                },
                child: Container(
                    transform: Matrix4.translationValues(0, 0, 0),
                    height: 160,
                    width: 320,
                    margin: const EdgeInsets.only(bottom: 10, top: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        image: idProof == null
                            ? null
                            : DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(File(idProof!.path)))),
                    child: idProof != null
                        ? null
                        : const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: CabText(
                              "Your Identity Proof Document",
                              color: black,
                              size: 18,
                              align: TextAlign.center,
                            ))),
              ),
            ),

            Center(
              child: GestureDetector(
                onTap: () async {
                  carIdProof = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  setState(() {});
                },
                child: Container(
                    transform: Matrix4.translationValues(0, 0, 0),
                    height: 160,
                    width: 320,
                    margin: const EdgeInsets.only(bottom: 0, top: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        image: carIdProof == null
                            ? null
                            : DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(File(carIdProof!.path)))),
                    child: carIdProof != null
                        ? null
                        : const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: CabText(
                              "Vehicle Registration Document",
                              color: black,
                              size: 18,
                              align: TextAlign.center,
                            ),
                          )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Form(
                key: registerFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                      child: CabText("Select Vehicle",
                          color: primaryColor, weight: FontWeight.w500),
                    ),
                    rideFares == null
                        ? const Center(child: CircularProgressIndicator())
                        : rideFares!.isEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(top: 50, bottom: 30),
                                child: Center(
                                  child: Column(children: const [
                                    Icon(Icons.info_outline,
                                        size: 40, color: primaryColor),
                                    SizedBox(height: 12),
                                    Text(
                                        "No Activated Ride Types, Contact Admin to Add Ride Types.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 20, color: black)),
                                  ]),
                                ),
                              )
                            : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: rideFares!.length,
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemBuilder: (context, index) => RadioListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      title: CabText(rideFares![index].name,
                                          size: 16),
                                      value: rideFares![index]
                                          .name
                                          .trim()
                                          .toLowerCase()
                                          .replaceAll(" ", "-"),
                                      groupValue: type,
                                      onChanged: (value) {
                                        setState(() {
                                          type = value.toString();
                                        });
                                      },
                                    )),
                    const SizedBox(height: 10),
                    rideFares == null || rideFares!.isEmpty
                        ? const SizedBox()
                        : CabTextField(
                            controller: carController,
                            hintText: "Vehicle Company and Model".toUpperCase(),
                            isPassword: false,
                            action: TextInputAction.next,
                            node: carNode,
                            nextNode: plateNode,
                            icon: const Icon(CupertinoIcons.settings,
                                color: black)),
                    const SizedBox(height: 10),
                    rideFares == null || rideFares!.isEmpty
                        ? const SizedBox()
                        : CabTextField(
                            controller: plateController,
                            hintText: "Vehicle Plate No.".toUpperCase(),
                            isPassword: false,
                            node: plateNode,
                            icon: const Icon(Icons.document_scanner_outlined,
                                color: black)),
                    const SizedBox(height: 25),
                    rideFares == null || rideFares!.isEmpty
                        ? const SizedBox()
                        : CabButton(
                            isLoading: isLoading,
                            text: "REGISTER",
                            func: () {
                              if (image == null ||
                                  idProof == null ||
                                  carIdProof == null) {
                                showSnack(
                                    context: context,
                                    message: "All Images are required");
                                return;
                              }
                              if (registerFormKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                try {
                                  authProvider.signUp(
                                      widget.args["email"],
                                      widget.args["password"],
                                      widget.args["name"],
                                      widget.args["phone"],
                                      image!,
                                      type!,
                                      carController.text.trim(),
                                      plateController.text.trim(),
                                      widget.args["position"],
                                      idProof!,
                                      carIdProof!,
                                      context);
                                } catch (e) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            }),
                  ],
                ),
              ),
            )
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
