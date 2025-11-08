import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxitaxi_driver/screens/registration.dart';

import '../helpers/screen_navigation.dart';
import '../helpers/style.dart';
import '../providers/user.dart';
import '../widgets/cab_button.dart';
import '../widgets/cab_text.dart';
import '../widgets/cab_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> loginFormKey = GlobalKey();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode emailNode = FocusNode();
  FocusNode passwordNode = FocusNode();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    UserProvider authProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
              padding: const EdgeInsets.only(bottom: 20, top: 30),
              child: Stack(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Hero(
                              tag: "logo-shift",
                              child: Image.asset("assets/logo-tb.png",
                                  width: double.infinity, height: 220)),
                          const SizedBox(height: 5),
                          const CabText(
                            "SIGN IN",
                            color: Colors.black,
                            size: 24,
                            weight: FontWeight.w300,
                          )
                        ],
                      )),
                  // Positioned(
                  //     right: 20,
                  //     top: 20,
                  //     child: GestureDetector(
                  //         onTap: () => Navigator.of(context)
                  //             .pushReplacementNamed(TabsScreen.routeName),
                  //         child: const CabText(
                  //           "SKIP",
                  //           size: 14,
                  //           color: Colors.white,
                  //         )))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Form(
                key: loginFormKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    CabTextField(
                        controller: emailController,
                        hintText: "EMAIL *",
                        isPassword: false,
                        action: TextInputAction.next,
                        node: emailNode,
                        nextNode: passwordNode,
                        type: TextInputType.emailAddress,
                        icon: const Icon(
                          Icons.email,
                          color: black,
                        )),
                    const SizedBox(height: 10),
                    CabTextField(
                        controller: passwordController,
                        isPassword: true,
                        node: passwordNode,
                        hintText: "PASSWORD *",
                        icon: const Icon(
                          Icons.lock,
                          color: black,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 20),
                      child: GestureDetector(
                        onTap: () {
                          // Navigator.of(context)
                          //     .pushNamed(ForgotPasswordScreen.routeName);
                        },
                        child: const Align(
                            alignment: Alignment.centerRight,
                            child: Text('Forgot Password?',
                                style: TextStyle(
                                    height: 1,
                                    fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                    fontSize: 14))),
                      ),
                    ),
                    CabButton(
                        isLoading: isLoading,
                        text: "SIGN IN",
                        func: () {
                          if (loginFormKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            try {
                              authProvider
                                  .signIn(emailController.text,
                                      passwordController.text, context)
                                  .whenComplete(() => setState(() {
                                        isLoading = false;
                                      }));
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }

                          //  if (!await authProvider.signIn()) {
                          //                       ScaffoldMessenger.of(context).showSnackBar(
                          //                           const SnackBar(content: Text("Login failed!")));
                          //                       return;
                          //                     }
                          //                     authProvider.clearController();
                          //                     changeScreenReplacement(context, const HomeScreen());
                        }),
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 80, color: Colors.grey, height: 1),
                          const Text(
                            "   OR   ",
                          ),
                          Container(width: 80, color: Colors.grey, height: 1)
                        ],
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextButton.icon(
                          onPressed: () =>
                              changeScreen(context, const RegistrationScreen()),
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 20,
                            color: Color(0xFF080808),
                          ),
                          label: const CabText(
                            "Create Account",
                          )),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
