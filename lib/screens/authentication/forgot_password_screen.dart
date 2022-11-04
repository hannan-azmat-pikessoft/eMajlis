import 'dart:convert';

import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/environment.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/progress.dart';
import 'package:emajlis/widgets/textinput.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  String radioButtonItem = 'Male';
  int id = 1;
  String selectedText = "Emirates of residence";
  List list = ["Abu Dhabi", "Dubai", "Sharjah", "Ajman"];
  int index;
  TextEditingController emailC = TextEditingController();
  String email;
  bool btnLoading = false;

  Future<Response> forgotPasswordApi() async {
    var response = await http.post(
      Uri.parse(Environment.Host + 'forgot_password'),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "54765",
      },
      body: jsonEncode(<String, String>{
        "email": email,
      }),
    );
    print(response);
    print(response.body.toString());

    return response;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: appBlackBackground,
        body: Form(
          key: formkey,
          child: SingleChildScrollView(
            child: Container(
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
                height: screenHeight,
                width: screenWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    Text(
                      'Forgot Password',
                      style: bn_27white(),
                    ),
                    SizedBox(height: 30),
                    Container(
                      child: Center(
                        child: Image.asset("assets/images/graphics/forget.png"),
                        // child: Icon(
                        //   Icons.lock_clock,
                        //   color: appwhite,
                        //   size: screenHeight / 4.5,
                        // ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Center(
                        child: Container(
                          height: screenHeight / 5,
                          width: screenWidth / 1.1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Seems like you forget your password!!!",
                                // "Not to worry, we got you! Let's get you a password.",
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: appwhite,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Drop in your registered email address in the box below and we’ll send you a password reset link.",
                                // "Enter your email address you're using for your account below and we will send you a password reset link.",
                                style: TextStyle(fontSize: 12, color: appGrey2),
                                softWrap: true,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      style: TextStyle(color: appGrey2),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      cursorColor: appGrey2,
                      controller: emailC,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      decoration: inputDecoration("Email address"),
                      validator: (value) {
                        if (value.trim().isEmpty) {
                          return "Email can not be empty";
                        } else if ((value.length <= 2)) {
                          return "Enter complete email";
                        } else if (!RegExp(Common.EmailRegExp)
                            .hasMatch(value)) {
                          return "Enter complete email@mail.com";
                        } else {
                          email = value;
                          return null;
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (formkey.currentState.validate()) {
                          setState(() {
                            btnLoading = true;
                          });
                          print("reset valid");
                          forgotPasswordApi().then((res) {
                            if (res.statusCode == 200) {
                              if (jsonDecode(res.body)["result"] == true) {
                                toastBuild(jsonDecode(res.body)["message"]);
                                Navigator.pop(context);
                              } else {
                                toastBuild(jsonDecode(res.body)["message"]);
                              }
                            }
                          }).whenComplete(() {
                            setState(() {
                              btnLoading = false;
                            });
                          });
                        }
                        print("reset");
                      },
                      child: btnLoading
                          ? Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: appwhite,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Center(
                                child: circularProgress(),
                              ),
                            )
                          : Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 22),
                              decoration: BoxDecoration(
                                color: appwhite,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                'Reset Password',
                                style: b_16Black(),
                              ),
                            ),
                    ),
                  ],
                )),
          ),
        ));
  }
}
