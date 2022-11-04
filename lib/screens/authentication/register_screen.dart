import 'dart:io';
import 'package:apple_sign_in/apple_sign_in.dart' as io_sign;
import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/environment.dart';
import 'package:emajlis/main.dart';
import 'package:emajlis/models/my_profile_model.dart';
import 'package:emajlis/providers/connection_provider.dart';
import 'package:emajlis/screens/authentication/configure_profile_details.dart';
import 'package:emajlis/screens/authentication/configure_profile_details_social.dart';
import 'package:emajlis/screens/authentication/login_screen.dart';
import 'package:emajlis/screens/home/dashboard_screen.dart';
import 'package:emajlis/screens/profile/profile_summary_checker_screen.dart';
import 'package:emajlis/services/apple_login.service.dart';
import 'package:emajlis/services/authentication_service.dart';
import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/utlis/flutter_device_type.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/progress.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:linkedin_login/linkedin_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<RegisterScreen> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  bool isLogoutUser = true;
  bool isChecked = false;
  bool showPassword = false;
  bool isSocialLoading = false;

  String _password;
  String _confirmPassword;
  String _email;
  String firebaseToken;

  @override
  void initState() {
    isChecked = false;
    //NotificationService.initialize(context);
    registerNotification();

    io_sign.AppleSignIn.onCredentialRevoked.listen((_) {
      print("Credentials revoked");
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: appBlackBackground,
      body: SafeArea(
        child: Form(
          key: formkey,
          child: Container(
            color: appBlackBackground,
            width: double.infinity,
            height: Device.screenHeight,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Text(
                    'Let\'s get started!',
                    style: bn_27white(),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Create your account and get connected',
                    style: n_16white(),
                  ),
                  SizedBox(height: size.height * 0.06),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                      } else if (!RegExp(Common.EmailRegExp).hasMatch(value)) {
                        return "Enter complete email@mail.com";
                      } else {
                        _email = value;
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: appDarkGrey,
                      labelText: 'Enter your email',
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: TextStyle(color: appGrey2),
                    cursorColor: appGrey2,
                    obscureText: showPassword ? false : true,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      Pattern pattern =
                          r"^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&^_+=<>.,/:|`~;'])[A-Za-z\d@$!%*#?&^_+=<>.,/:|`~;']{8,}$";
                      RegExp regex = new RegExp(pattern);
                      if (value.trim().isEmpty) {
                        return "Enter password";
                      } else if (value.length < 8) {
                        return "Password must have 8 letter";
                      } else if (!regex.hasMatch(value))
                        return 'At least 1 letter, 1+ number and ` @\$!%*#?&^_+=<>.,/:~;|.';
                      else {
                        _password = value;
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.only(right: 10, left: 10),
                          child: showPassword
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
                  SizedBox(height: 20),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: TextStyle(color: appGrey2),
                    obscureText: true,
                    cursorColor: appGrey2,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return "Password can not be empty";
                      } else if (value != _password) {
                        return "Password must be same as above";
                      } else {
                        _confirmPassword = value;
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: appDarkGrey,
                      labelText: 'Confirm Password',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Theme(
                          data: ThemeData(
                            unselectedWidgetColor: appGrey,
                          ),
                          child: Container(
                            width: 20,
                            child: Checkbox(
                              onChanged: (value) {
                                setState(() {
                                  isChecked = !isChecked;
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                });
                              },
                              value: isChecked,
                              checkColor: appwhite,
                              activeColor: appGrey3,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "I accept ",
                        style: n_12white(),
                      ),
                      InkWell(
                        onTap: () {
                          url("https://emajlis.com/privacy.html");
                        },
                        child: Text(
                          "Privacy Policy",
                          style: b_12white(),
                        ),
                      ),
                      Text(
                        " and ",
                        style: n_12white(),
                      ),
                      InkWell(
                        onTap: () {
                          url("https://emajlis.com/terms.html");
                        },
                        child: Text(
                          "Terms & Conditions",
                          style: b_12white(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.05),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      'or connect using',
                      style: n_12white(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    alignment: Alignment.center,
                    child: isSocialLoading
                        ? circularProgress(color: appwhite)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (Platform.isIOS) ...[
                                InkWell(
                                  onTap: () {
                                    appleSignIn();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                      top: 10,
                                      bottom: 10,
                                    ),
                                    color: appBlack,
                                    child: SvgPicture.asset(
                                      Common.AppleSvg,
                                      width: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20)
                              ],
                              InkWell(
                                onTap: () {
                                  googleSignIn();
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
                                  linkedInSignIn();
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
                  SizedBox(height: size.height * 0.06),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: n_16grey(),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          ' Connect',
                          style: b_16white(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  buttonCreate(),
                  SizedBox(height: Device.get().isIphoneX ? 100 : 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buttonCreate() {
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: appwhite,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          'Create',
          style: b_16Black(),
        ),
      ),
      onTap: () async {
        if (formkey.currentState.validate()) {
          if (isChecked != false) {
            LoaderOverlay overlay = LoaderOverlay.of(context);
            final isValidate = await overlay.during(verifyEmail(_email));
            if (isValidate == null) {
              somethingWentWrong(context);
            } else if (isValidate) {
              warning(context, "Email is already used, Please login");
            } else if (!isValidate) {
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ProfileSummaryCheckerScreen(),
              //   ),
              //   (route) => false,
              // );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileDetails(
                    email: _email,
                    password: _confirmPassword,
                    firebaseToken: firebaseToken,
                  ),
                ),
              );
            }
          } else {
            warning(context, "Check the Private policy");
          }
        }
      },
    );
  }

  dynamic googleSignIn() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
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

  void appleSignIn() async {
    final io_sign.AuthorizationResult result =
        await io_sign.AppleSignIn.performRequests([
      io_sign.AppleIdRequest(
        requestedScopes: [
          io_sign.Scope.email,
          io_sign.Scope.fullName,
        ],
      )
    ]);

    try {
      final res = await checkAppleLogin(
          result.credential.user,
          result.credential.email,
          (result.credential.fullName.givenName).toString() +
              " " +
              (result.credential.fullName.familyName).toString());

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

  dynamic linkedInSignIn() async {
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
          destroySession: isLogoutUser,
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
              isLogoutUser = false;
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

  url(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      error(context, "Invalid link");
    }
  }

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
    //     Navigator.of(context).pushNamed(r);
    //   }
    // });
    // FirebaseMessaging.instance.getInitialMessage().then((event) {
    //   if (event != null) {
    //     final r = event.data['click_action'];
    //     Navigator.of(context).pushNamed(r);
    //   }
    // });
    FirebaseMessaging _messaging = FirebaseMessaging.instance;
    firebaseToken = await _messaging.getToken();
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
              socialId: socialId,
              socialType: socialType,
              firebaseToken: firebaseToken,
            ),
          ),
        );
      }
    } else {
      setState(() {
        isSocialLoading = false;
      });
      toastBuild(response.message);
    }
  }

  Future<void> checkProfileCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getString(StorageKeys.MemberId);
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
