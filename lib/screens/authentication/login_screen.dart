import 'dart:io';
import 'package:apple_sign_in/apple_sign_in.dart' as io_sign;
import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/environment.dart';
import 'package:emajlis/main.dart';
import 'package:emajlis/models/my_profile_model.dart';
import 'package:emajlis/providers/connection_provider.dart';
import 'package:emajlis/screens/authentication/forgot_password_screen.dart';
import 'package:emajlis/screens/authentication/configure_profile_details_social.dart';
import 'package:emajlis/screens/authentication/register_screen.dart';
import 'package:emajlis/screens/home/dashboard_screen.dart';
import 'package:emajlis/screens/profile/profile_summary_checker_screen.dart';
import 'package:emajlis/services/apple_login.service.dart';
import 'package:emajlis/services/authentication_service.dart';
import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/progress.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:linkedin_login/linkedin_login.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  String _email;
  String _password;
  bool showpassword = false;
  bool loading = false;
  bool logoutUser = true;
  String firebaseToken;

  void registerNotification() async {
    // FirebaseMessaging.onMessage.listen((e) {
    //   if (e.notification != null) {
    //     print(e.notification.body);
    //   }
    //   NotificationService.display(e);
    // });

    // FirebaseMessaging.onMessageOpenedApp.listen((event) {
    //   if (event.notification != null) {
    //     final r = event.data['click_action'];
    //     print(r);
    //     Navigator.of(context).pushNamed(r);
    //   }
    // });
    // FirebaseMessaging.instance.getInitialMessage().then((event) {
    //   if (event != null) {
    //     final r = event.data['click_action'];
    //     print(r);
    //     Navigator.of(context).pushNamed(r);
    //   }
    // });
    FirebaseMessaging _messaging = FirebaseMessaging.instance;
    firebaseToken = await _messaging.getToken();
  }

  @override
  void initState() {
    //NotificationService.initialize(context);
    registerNotification();
    if (Platform.isIOS) {
      //check for ios if developing for both android & ios
      // apple_signin.AppleSignIn.onCredentialRevoked.listen((_) {
      // print("Credentials revoked");
      // });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: appBlackBackground,
      body: SafeArea(
        child: Container(
          color: appBlackBackground,
          child: Form(
            key: formkey,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                height: size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30),
                        Text(
                          'Let\'s sign you in.',
                          style: bn_27white(),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Welcome back!',
                          style: n_16white(),
                        ),
                        SizedBox(height: 40),
                        TextFormField(
                          style: TextStyle(
                            color: appGrey2,
                          ),
                          cursorColor: appGrey2,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value.trim().isEmpty) {
                              return "Email can not be empty";
                            } else if ((value.length <= 2)) {
                              return "Enter complete email";
                            } else if (!RegExp(Common.EmailRegExp)
                                .hasMatch(value)) {
                              return "Enter complete email@mail.com";
                            } else {
                              setState(() {
                                _email = value;
                              });
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: appDarkGrey,
                            labelText: 'Email Address',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              color: appGrey3,
                            ),
                            border: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: appGrey3,
                              ),
                            ),
                            enabledBorder: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: appGrey3,
                              ),
                            ),
                            focusedBorder: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: appGrey3,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          maxLength: 30,
                          style: TextStyle(
                            color: appGrey2,
                          ),
                          cursorColor: appGrey2,
                          obscureText: showpassword ? false : true,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value.trim().isEmpty) {
                              return "Enter password";
                            } else if (value.length < 8) {
                              return "Password must have 8 letter";
                            } else {
                              setState(() {
                                _password = value;
                              });
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  showpassword = !showpassword;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.only(right: 10, left: 10),
                                child: showpassword
                                    ? Icon(
                                        Icons.visibility_off_rounded,
                                        color: appGrey2,
                                        size: 30,
                                      )
                                    : SvgPicture.asset(
                                        'assets/images/graphics/hide.svg',
                                      ),
                              ),
                            ),
                            counterText: '',
                            filled: true,
                            fillColor: appDarkGrey,
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              color: appGrey3,
                            ),
                            border: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: appGrey3,
                              ),
                            ),
                            enabledBorder: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: appGrey3,
                              ),
                            ),
                            focusedBorder: new OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: appGrey3,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPassword(),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: n_12white(),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            'or connect using',
                            style: n_12white(),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // InkWell(
                              //   onTap: () {
                              //     print("Microdoft btn tap");
                              //   },
                              //   child: Container(
                              //     padding: EdgeInsets.all(12),
                              //     color: appBlack,
                              //     child: SvgPicture.asset(
                              //         'assets/images/graphics/microsoft.svg'),
                              //   ),
                              // ),
                              // SizedBox(width: 20),
                              InkWell(
                                onTap: () {
                                  logingApple();
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 12, right: 12, top: 10, bottom: 10),
                                  color: appBlack,
                                  child: SvgPicture.asset(
                                    Common.AppleSvg,
                                    width: 20,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),

                              InkWell(
                                onTap: () async {
                                  logingGoogle();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  color: appBlack,
                                  child: SvgPicture.asset(Common.GoogleSvg),
                                ),
                              ),
                              SizedBox(width: 20),
                              InkWell(
                                onTap: () {
                                  loginLinkedIn();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  color: appBlack,
                                  child: SvgPicture.asset(Common.LinkedinSvg2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        // Platform.isIOS
                        //     ? apple_signin.AppleSignInButton(
                        //         style: apple_signin.ButtonStyle.black,
                        //         type: apple_signin.ButtonType.continueButton,
                        //         onPressed: appleLogIn,
                        //       )
                        //     : Container()
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: n_16grey(),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            ' Register',
                            style: b_16white(),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                      child: connectButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget connectButton() {
    return GestureDetector(
      onTap: () async {
        if (formkey.currentState.validate()) {
          setState(() {
            loading = true;
          });
          final isSuccess = await login(_email, _password, firebaseToken);
          setState(() {
            loading = false;
          });
          if (isSuccess == null) {
            somethingWentWrong(context);
          } else if (!isSuccess) {
            warning(context, "Username or Password Incorrect");
          } else if (isSuccess) {
            checkProfileCompletion();
          }
        }
      },
      child: loading
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
                'Connect',
                style: b_16Black(),
              ),
            ),
    );
  }

  dynamic logingGoogle() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ["email"]);
    _googleSignIn.signOut().whenComplete(() async {
      await _googleSignIn.signIn().then((value) {}).whenComplete(() async {
        await checkLogin(
          "2",
          _googleSignIn.currentUser.id,
          _googleSignIn.currentUser.email,
          _googleSignIn.currentUser.photoUrl.replaceAll("s96-c", "s192-c"),
          _googleSignIn.currentUser.displayName,
        );
      });
    });
  }

  dynamic logingApple() async {
    final io_sign.AuthorizationResult result =
        await io_sign.AppleSignIn.performRequests([
      io_sign.AppleIdRequest(requestedScopes: [
        io_sign.Scope.email,
        io_sign.Scope.fullName,
      ])
    ]);
    try {
      final res = await checkAppleLogin(
        result.credential.user,
        result.credential.email,
        (result.credential.fullName.givenName).toString() +
            " " +
            (result.credential.fullName.familyName).toString(),
      );
      if (res != false) {
        checkLogin(
          '3',
          res['userId'],
          res['emailId'],
          '',
          res['fullname'],
        );
      }
    } catch (e) {
      print(e);
    }
  }

  dynamic loginLinkedIn() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => LinkedInUserWidget(
          appBar: AppBar(
            backgroundColor: appBodyGrey,
            centerTitle: true,
            iconTheme: IconThemeData(color: appBlack),
            titleTextStyle: TextStyle(color: appBlack),
            title: Text('eMajlis', style: TextStyle(color: appBlack)),
          ),
          destroySession: logoutUser,
          redirectUrl: Environment.LinkedInRedirectUrl,
          clientId: Environment.LinkedInClientId,
          clientSecret: Environment.LinkedInClientSecret,
          projection: [
            ProjectionParameters.id,
            ProjectionParameters.localizedFirstName,
            ProjectionParameters.localizedLastName,
            ProjectionParameters.firstName,
            ProjectionParameters.lastName,
            ProjectionParameters.profilePicture,
          ],
          onError: (UserFailedAction e) {
            print('Error: ${e.toString()}');
            print('Error: ${e.stackTrace.toString()}');
          },
          onGetUserProfile: (UserSucceededAction linkedInUser) async {
            final linkId = linkedInUser.user.userId.toString();
            final firstName = linkedInUser?.user?.firstName?.localized?.label;
            final lastName = linkedInUser?.user?.lastName?.localized?.label;
            final email = linkedInUser
                ?.user?.email?.elements[0]?.handleDeep?.emailAddress;
            String imageUrl = linkedInUser?.user?.profilePicture
                ?.displayImageContent?.elements[3]?.identifiers[0]?.identifier;
            if (imageUrl == null || imageUrl == '') {
              imageUrl = linkedInUser?.user?.profilePicture?.displayImageContent
                  ?.elements[2]?.identifiers[0]?.identifier;
            }
            if (imageUrl == null || imageUrl == '') {
              imageUrl = linkedInUser?.user?.profilePicture?.displayImageContent
                  ?.elements[1]?.identifiers[0]?.identifier;
            }
            if (imageUrl == null || imageUrl == '') {
              imageUrl = linkedInUser?.user?.profilePicture?.displayImageContent
                  ?.elements[0]?.identifiers[0]?.identifier;
            }
            setState(() {
              logoutUser = false;
            });

            await checkLogin(
              "1",
              linkId,
              email,
              imageUrl,
              firstName + " " + lastName,
            );
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> checkLogin(
    String socialType,
    String socialId,
    String email,
    String imageUrl,
    String fullName,
  ) async {
    final response = await socialLogin(
      email: email,
      socialType: socialType,
      socialId: socialId,
      firebaseToken: firebaseToken,
    );
    if (response.status) {
      if (response.hasAccount) {
        toastBuildsec(msg: "Login you In please wait.", sec: 3);
        checkProfileCompletion();
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDetailsSocial(
              email: email,
              imageUrl: imageUrl,
              fullName: fullName,
              socialType: socialType,
              socialId: socialId,
              firebaseToken: firebaseToken,
            ),
          ),
        );
      }
    } else {
      toastBuild(response.message);
    }
  }

  Future<void> checkProfileCompletion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String memberId = prefs.getString(StorageKeys.MemberId);
    context.read<ConnectionProvider>().setMyMemberId(memberId);
    final MyProfile myProfile = await getMemberProfile(memberId);
    MyApp.setMyProfile(context, myProfile);
    if (myProfile.profilePercentage < 100) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileSummaryCheckerScreen(),
        ),
        (route) => false,
      );
    } else {
      await context.read<ConnectionProvider>().loadConnections();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
            screenIndex: 0,
            id: -1,
          ),
        ),
        (route) => false,
      );
    }
  }
}
