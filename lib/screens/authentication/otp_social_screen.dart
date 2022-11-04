import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/environment.dart';
import 'package:emajlis/main.dart';
import 'package:emajlis/models/my_profile_model.dart';
import 'package:emajlis/providers/connection_provider.dart';
import 'package:emajlis/screens/home/dashboard_screen.dart';
import 'package:emajlis/screens/profile/profile_summary_checker_screen.dart';
import 'package:emajlis/services/authentication_service.dart';
import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/utlis/flutter_device_type.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/progress.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPSocialScreen extends StatefulWidget {
  final File imageFile;
  final String dialCode;
  final String phoneNo;
  final String password;
  final String email;
  final String cityId;
  final String fullName;
  final int genderId;
  final String role;
  final String deviceToken;
  final String deviceType;
  final String socialType;
  final String socialId;
  final String firebaseToken;

  const OTPSocialScreen(
      {Key key,
      @required this.imageFile,
      @required this.dialCode,
      @required this.phoneNo,
      @required this.password,
      @required this.email,
      @required this.cityId,
      @required this.fullName,
      @required this.genderId,
      @required this.role,
      @required this.deviceToken,
      @required this.deviceType,
      @required this.socialType,
      @required this.socialId,
      @required this.firebaseToken})
      : super(key: key);

  @override
  _OTPSocialScreenState createState() => _OTPSocialScreenState();
}

class _OTPSocialScreenState extends State<OTPSocialScreen> {
  TextEditingController otpcontroller = TextEditingController();

  bool isInputdone = false;
  bool isloading = false;
  int _start = 60;
  Timer _timer;
  bool showtimer = true;
  String otpInput;
  int otpReviced;

  @override
  void initState() {
    super.initState();
    startOtpSend();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: appBlackBackground,
        body: Container(
          width: double.infinity,
          height: size.height,
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(height: 30),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 20),
                    child: Text(
                      "Verification Code",
                      style: bn_27white(),
                    ),
                  ),
                  SizedBox(height: 50),
                  Text(
                    "Please type the verification code send to",
                    style: n_15grey(),
                  ),
                  Text(
                    "${widget.email}",
                    style: n_15white(),
                  ),
                  Text(
                    " and ",
                    style: n_15grey(),
                  ),
                  Text(
                    "+${widget.dialCode}${widget.phoneNo}",
                    style: n_15white(),
                  ),
                  SizedBox(height: 30),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: PinPut(
                        controller: otpcontroller,
                        textStyle: n_16white(),
                        fieldsCount: 6,
                        followingFieldDecoration: BoxDecoration(
                          border: Border.all(color: appGrey3),
                          borderRadius: BorderRadius.circular(10),
                          color: appDarkGrey,
                        ),
                        selectedFieldDecoration: BoxDecoration(
                          border: Border.all(color: appwhite),
                          borderRadius: BorderRadius.circular(10),
                          color: appDarkGrey,
                        ),
                        submittedFieldDecoration: BoxDecoration(
                          border: Border.all(color: appGrey3),
                          borderRadius: BorderRadius.circular(10),
                          color: appDarkGrey,
                        ),
                        onSubmit: (pin) async {
                          setState(() {
                            isInputdone = true;
                            otpInput = pin;
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          });
                        },
                        onChanged: (value) {
                          if (value.length == 6) {
                            setState(() {
                              isInputdone = true;
                            });
                          } else {
                            setState(() {
                              isInputdone = false;
                              isloading = false;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  if (showtimer)
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        "Code Send in 0:" + "$_start",
                        style: b_16white(),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () {
                        setState(() {
                          otpcontroller.clear();
                          startOtpSend();
                          startTimer();
                          showtimer = true;
                          isInputdone = false;
                          isloading = false;
                        });
                      },
                      child: Text(
                        "Resend OTP",
                        style: b_16white(),
                      ),
                    ),

                ],
              ),
              Container(
                margin: EdgeInsets.only(
                  bottom: Device.get().isIphoneX ? 100 : 20,
                ),
                width: double.infinity,
                child: isloading
                    ? Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: appwhite,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: circularProgress(),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          onVerifyOTP();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: isInputdone ? appwhite : appGrey2,
                          elevation: 10,
                          padding: const EdgeInsets.all(20.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          "Verify",
                          style: b_16Black(),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onVerifyOTP() async {
    if (isInputdone) {
      if (otpReviced.toString() == otpInput) {
        setState(() {
          isloading = true;
        });
        registerSocialApi(
          image: widget.imageFile,
          fullName: widget.fullName,
          gender: widget.genderId.toString(),
          email: widget.email,
          phoneNo: widget.phoneNo,
          password: widget.password,
          dialCode: widget.dialCode,
          cityId: widget.cityId,
          role: widget.role,
          deviceToken: widget.firebaseToken,
          deviceType: widget.deviceType,
          socialType: widget.socialType,
          socialId: widget.socialId,
        ).then((res) async {
          final prefs = await SharedPreferences.getInstance();
          if (res.statusCode == 200 && res.data["status"] == true) {
            if (res.data["result"]["profile"]["id"] != null) {
              final memberId = res.data["result"]["profile"]["id"];
              final token = res.data["result"]["token"];
              final memberProfileImage = res.data["result"]["profile"]["image_url"];
              prefs.setString(StorageKeys.MemberId, memberId);
              prefs.setString(StorageKeys.MemberProfileImage, memberProfileImage);
              prefs.setString(StorageKeys.EncryptedToken, token);
              context.read<ConnectionProvider>().setMyMemberId(memberId);
              final MyProfile myProfile = await getMemberProfile(memberId);
              MyApp.setMyProfile(context, myProfile);
              setState(() {
                isloading = false;
              });
              goToProfileSummary();
             // goToDashboard();
            }
          } else {
            setState(() {
              isloading = false;
            });
            toastBuild(res.data["message"]);
          }
        }).onError((error, stackTrace) {
          toastBuild(error);
          setState(() {
            isloading = false;
          });
        });
      } else {
        warning(context, 'Invalid OTP');
      }
    }
  }

  void startTimer() {
    _start = 60;
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (_start > 0) {
          _start--;
          showtimer = true;
        } else {
          timer.cancel();
          showtimer = false;
        }
      });
    });
  }

  Future<void> startOtpSend() async {
    final response = await sendOTP(
      widget.email,
      widget.dialCode + widget.phoneNo,
    );
    setState(() {
      otpReviced = response;
    });
  }

  Future<Response> registerSocialApi({
    File image,
    String fullName,
    String cityId,
    String dialCode,
    String phoneNo,
    String role,
    String email,
    String password,
    String gender,
    String deviceType,
    String deviceToken,
    String socialId,
    String socialType,
  }) async {
    try {
      final fileName = image.path.split('/').last;
      final file = await MultipartFile.fromFile(image.path, filename: fileName);
      FormData formData = new FormData.fromMap({
        "firstname": fullName,
        "lastname": "",
        "email": email,
        "password": " ",
        "phone_no": phoneNo,
        "profession": role,
        "city": cityId,
        "gender": gender,
        "dialcode": dialCode,
        "device_type": deviceType,
        "device_token": deviceToken,
        "image": file,
        "social_id": socialId,
        "social_type": socialType,
        "lat": "0.2568",
        "lang": "0.3698",
      });
      Dio dio = new Dio();
      Response response = await dio.post(
        Environment.Host + 'social_register',
        data: formData,
        options: Options(
          headers: {
            "accept": "*/*",
            "Content-Type": "multipart/form-data",
            'AUTH_API_KEY': '524254'
          },
        ),
      );
      return response;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> goToDashboard() async {
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
  Future<void> goToProfileSummary() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileSummaryCheckerScreen(),
      ),
          (route) => false,
    );
  }
}
