import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:taxitaxi_driver/helpers/style.dart';
import 'package:flutter/material.dart';

import '../helpers/methods.dart';
import '../models/ride_fare.dart';
import '../providers/user.dart';
import '../services/ride_fare_service.dart';
import '../widgets/cab_button.dart';
import '../widgets/cab_text.dart';
import '../widgets/cab_text_field.dart';
import '../widgets/change_pass_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  List<RideFare>? rideFares = [];
  @override
  void initState() {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    type = userProvider.userModel!.type;
    emailController.text = userProvider.userModel!.email;
    carController.text = userProvider.userModel!.car;
    plateController.text = userProvider.userModel!.plate;
    nameController.text = userProvider.userModel!.name;
    phoneController.text = userProvider.userModel!.phone;
    RideFareService().fetchRideFare().then((value) => setState(() {
          rideFares = value;
          type =
              rideFares?.first.name.trim().toLowerCase().replaceAll(" ", "-");
        }));
    super.initState();
  }

  GlobalKey<FormState> registerFormKey = GlobalKey();

  TextEditingController emailController = TextEditingController();
  // TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController carController = TextEditingController();
  TextEditingController plateController = TextEditingController();
  String? type = "car";
  String imageUrl = "";
  FocusNode emailNode = FocusNode();
  FocusNode passwordNode = FocusNode();
  FocusNode nameNode = FocusNode();
  FocusNode phoneNode = FocusNode();
  XFile? image;
  FocusNode carNode = FocusNode();
  FocusNode plateNode = FocusNode();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: SingleChildScrollView(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 30, bottom: 10),
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
                    const SizedBox(width: 16),
                    const CabText(
                      "Edit Profile",
                      // color: Colors.white,
                      size: 20,
                      //   weight: FontWeight.w500,
                    )
                  ],
                ),
              ),

              GestureDetector(
                  onTap: () async {
                    image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      imageUrl = await uploadImage(
                          File(image!.path), userProvider.userModel!.id);
                    }
                    setState(() {});
                  },
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(bottom: 40, top: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(60),
                        image: userProvider.userModel!.photo == ""
                            ? image == null
                                ? null
                                : DecorationImage(
                                    fit: BoxFit.cover,
                                    image: FileImage(File(image!.path)))
                            : DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    userProvider.userModel!.photo))),
                    child: image == null && userProvider.userModel!.photo == ""
                        ? CabText(
                            userProvider.userModel!.name
                                .substring(0, 2)
                                .toUpperCase(),
                            color: Colors.white,
                            size: 26)
                        : null,
                  )),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                child: Form(
                  key: registerFormKey,
                  child: Column(
                    children: [
                      CabTextField(
                          controller: nameController,
                          hintText: "Name".toUpperCase(),
                          isPassword: false,
                          action: TextInputAction.next,
                          node: nameNode,
                          nextNode: phoneNode,
                          icon: const Icon(Icons.person, color: black)),
                      const SizedBox(height: 10),
                      CabTextField(
                          controller: phoneController,
                          hintText: "Phone Number".toUpperCase(),
                          isPassword: false,
                          action: TextInputAction.next,
                          node: phoneNode,
                          nextNode: emailNode,
                          icon: const Icon(Icons.call, color: black)),
                      const SizedBox(height: 10),
                      CabTextField(
                          controller: emailController,
                          hintText: "Email".toUpperCase(),
                          isPassword: false,
                          action: TextInputAction.next,
                          node: emailNode,
                          nextNode: passwordNode,
                          type: TextInputType.emailAddress,
                          icon: const Icon(Icons.email, color: black)),
                      const SizedBox(height: 10),
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
                                  padding: const EdgeInsets.only(
                                      top: 50, bottom: 30),
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
                                  itemCount: rideFares!.length,
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) =>
                                      RadioListTile(
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
                      CabTextField(
                          controller: carController,
                          hintText: "$type Company and Model".toUpperCase(),
                          isPassword: false,
                          action: TextInputAction.next,
                          node: carNode,
                          nextNode: plateNode,
                          icon: Icon(
                              type == "car"
                                  ? CupertinoIcons.car_detailed
                                  : Icons.motorcycle,
                              color: black)),
                      const SizedBox(height: 10),
                      CabTextField(
                          controller: plateController,
                          hintText: "$type Plate No.".toUpperCase(),
                          isPassword: false,
                          node: plateNode,
                          icon: const Icon(Icons.document_scanner_outlined,
                              color: black)),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                            onPressed: () => changePasswordSheet(context),
                            child: const CabText("Reset Password")),
                      ),
                      const SizedBox(height: 20),
                      CabButton(
                          isLoading: false,
                          height: 46,
                          text: "Save",
                          func: () async {
                            if (registerFormKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              //    String url = await uploadImage();
                              userProvider.updateUserData({
                                "photo": imageUrl,
                                "name": nameController.text.trim(),
                                "id": userProvider.userModel!.id,
                                "phone": phoneController.text.trim(),
                                "email": emailController.text.trim(),
                                "car": carController.text.trim(),
                                "plate": plateController.text.trim(),
                                "type": type,
                              }).whenComplete(() => userProvider
                                  .reloadUserModel()
                                  .whenComplete(() => showSnack(
                                      context: context,
                                      message: "Profile Data updated")));
                            }
                          }),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              )
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
