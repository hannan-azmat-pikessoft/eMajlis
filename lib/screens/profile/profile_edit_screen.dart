import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/models/city_model.dart';
import 'package:emajlis/models/country_model.dart';
import 'package:emajlis/models/profile_model.dart';
import 'package:emajlis/providers/common_provider.dart';
import 'package:emajlis/services/authentication_service.dart';
import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/progress.dart';
import 'package:emajlis/widgets/textinput.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class ProfileEditScreen extends StatefulWidget {
  final ProfileModel profileData;
  ProfileEditScreen({this.profileData});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  SharedPreferences pref;
  LoaderOverlay overlay;
  double screenHeight;
  double screenWidth;

  ProfileModel profileData;
  List<CountryModel> countryList = [];
  List<CityModel> cityList = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController introductionController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController countryCodeController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File _image;
  File _updateimage;

  String _phone;
  String _phonechange;
  int indexcode;
  int index;
  String uploadedImgUrl;

  bool isSaved = true;
  bool otpverified = true;

  bool isMobileNoChanged = false;
  bool picloading = false;

  int otpReviced;

  @override
  void initState() {
    super.initState();
    countryList = context.read<CommonProvider>().countryList;
    cityList = context.read<CommonProvider>().cityList;
    profileData = widget.profileData;
    nameController.text = profileData.firstname;
    introductionController.text = profileData.introduction;
    emailController.text = profileData.email;
    countryCodeController.text = profileData.dialcode;
    mobileNoController.text = profileData.phoneNumber;
    cityController.text = profileData.city;
    Future.delayed(Duration.zero, () {
      initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: appBodyGrey,
      appBar: simpleAppbar(
        context,
        titleText: "My Profile",
        onTap: () {
          isSaved ? Navigator.pop(context) : onBack();
        },
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(20, screenWidth / 4, 20, 20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: appwhite,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenWidth / 4),
                  fullnameField(),
                  introduction(),
                  emailField(),
                  mobileNo(),
                  buttonSendOTP(),
                  buttonVerifyOTP(),
                  residenceField(),
                  genderField(),
                  buttonSave(),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: profileImageSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget fullnameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldName("Full Name"),
        TextFormField(
          controller: nameController,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(color: appGrey2),
          cursorColor: appGrey2,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.text,
          decoration: inputDecoration2(hintText: 'Full Name'),
          onChanged: (value) {
            setState(() {
              isSaved = false;
            });
          },
          validator: (value) {
            if (value.trim().isEmpty) {
              return "Enter Full name";
            } else if ((value.length <= 2)) {
              return "Full name must be longer then 2 letters.";
            } else {
              return null;
            }
          },
        ),
      ],
    );
  }

  Widget introduction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldName("Introduction"),
        TextFormField(
          controller: introductionController,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 4,
          maxLength: 150,
          style: TextStyle(color: appGrey2),
          cursorColor: appGrey2,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.text,
          decoration: inputDecoration2(hintText: 'Introduction'),
          onChanged: (value) {
            setState(() {
              isSaved = false;
            });
          },
          validator: (value) {
            if (value.trim().isEmpty) {
              return "Enter Introduction";
            } else if ((value.length <= 20)) {
              return "Introduction must be between 20 to 150 letters.";
            } else {
              return null;
            }
          },
        ),
      ],
    );
  }

  Widget emailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldName("Email Address (Non-changeable)"),
        TextFormField(
          controller: emailController,
          readOnly: true,
          style: TextStyle(color: appGrey2),
          cursorColor: appGrey2,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.text,
          decoration: inputDecoration2(hintText: 'Email Address'),
          onChanged: (value) {
            setState(() {
              isSaved = false;
            });
          },
          validator: (value) {
            if (value.trim().isEmpty) {
              return "Email can not be empty";
            } else if ((value.length <= 2)) {
              return "Enter complete email";
            } else if (!RegExp(Common.EmailRegExp).hasMatch(value)) {
              return "Enter complete email@mail.com";
            } else {
              return null;
            }
          },
        ),
      ],
    );
  }

  Widget mobileNo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldName("Mobile Number"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: screenWidth * 0.18,
              child: TextFormField(
                readOnly: true,
                style: TextStyle(color: appGrey2),
                cursorColor: appGrey2,
                textInputAction: TextInputAction.done,
                controller: countryCodeController,
                keyboardType: TextInputType.text,
                onTap: () {
                  showCountryCodeDialog();
                },
                decoration: inputDecoration2(
                  hintText: "Code",
                  prefixtxt: "+",
                ),
              ),
            ),
            Container(
              width: screenWidth * .6,
              child: TextFormField(
                controller: mobileNoController,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: appGrey2),
                cursorColor: appGrey2,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                decoration: inputDecoration2(
                  hintText: 'Mobile Number',
                ),
                onChanged: (value) {
                  setState(() {
                    _phone = value;
                    isSaved = false;
                    otpController.clear();
                    otpReviced = null;
                    if (value == profileData.phoneNumber) {
                      setState(() {
                        isMobileNoChanged = false;
                        otpverified = true;
                      });
                    } else {
                      setState(() {
                        isMobileNoChanged = true;
                        otpverified = false;
                      });
                    }
                  });
                },
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return "Enter Mobile Number";
                  } else if (value.length < 8) {
                    return "Please enter valid Mobile Number";
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget residenceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldName("Emirate of Residence"),
        TextFormField(
          controller: cityController,
          textCapitalization: TextCapitalization.sentences,
          readOnly: true,
          style: TextStyle(color: appGrey2),
          cursorColor: appGrey2,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.text,
          decoration: inputDecoration2(hintText: 'country'),
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  titleTextStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: appBlack,
                  ),
                  title: new Text(
                    "Please select emirate of Residence",
                    style: b_14black(),
                  ),
                  content: StatefulBuilder(
                    builder: (context, StateSetter setState) {
                      return Container(
                        height: screenHeight * 0.35,
                        width: screenWidth / 1.1,
                        child: ListView.builder(
                          itemCount: cityList.length,
                          itemBuilder: (context, i) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      index = i;
                                      cityController.text = cityList[i].name;
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      cityList[i].name,
                                      style: TextStyle(
                                        color: index == i ? appBlack : appGrey2,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              isSaved = false;
                            });
                          },
                          child: Container(
                            height: screenHeight / 12,
                            width: screenWidth / 3,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: appBlack,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              'Select',
                              style: b_16white(),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: screenHeight / 12,
                            width: screenWidth / 3,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: appwhite,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              'Cancel',
                              style: b_16Black(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget genderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldName("Gender type"),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Radio(
              value: 0,
              activeColor: appBlack,
              groupValue: profileData.genderId,
              onChanged: (val) {
                setState(() {
                  profileData.genderId = 0;
                  isSaved = false;
                });
              },
            ),
            Text(
              'Male',
              style: TextStyle(
                fontSize: 16,
                color: appGrey3,
              ),
            ),
            Radio(
              value: 1,
              activeColor: appBlack,
              groupValue: profileData.genderId,
              onChanged: (val) {
                setState(() {
                  profileData.genderId = 1;
                  isSaved = false;
                });
              },
            ),
            Text(
              'Female',
              style: TextStyle(
                fontSize: 16,
                color: appGrey3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buttonSave() {
    return InkWell(
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        decoration: BoxDecoration(
          color: appBlack,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text('Save', style: b_16white()),
      ),
      onTap: () async {
        if (otpverified) {
          setState(() {
            isSaved = true;
          });
          FocusScope.of(context).requestFocus(new FocusNode());
          overlay.show();
          profileData.introduction = introductionController.text;
          profileData.firstname = nameController.text;
          profileData.email = emailController.text;
          profileData.phoneNumber =
              isMobileNoChanged ? _phonechange : mobileNoController.text;
          profileData.dialcode = countryCodeController.text;
          profileData.city = cityController.text;
          final isSuccess = await updateProfile(
            profileData,
          );
          overlay.hide();
          if (isSuccess) {
            Navigator.pop(context, profileData);
          } else {
            toastBuild('Something went wrong');
          }
        } else {
          FocusScope.of(context).requestFocus(new FocusNode());
          warning(context, "otp is not verified\nPlease try again.");
        }
      },
    );
  }

  Widget buttonSendOTP() {
    if (isMobileNoChanged) {
      return Container(
        margin: EdgeInsets.only(top: 10),
        child: Center(
          child: InkWell(
            onTap: () async {
              LoaderOverlay overlay = LoaderOverlay.of(context);
              final isExist = await overlay.during(
                verifyMobile(countryCodeController.text + _phone),
              );
              if (isExist == null) {
                somethingWentWrong(context);
              } else if (isExist) {
                warning(context, "Mobile is already used, Please login");
              } else {
                startOtpSend();
                otpverified = false;
              }
            },
            child: Container(
              width: screenWidth * .3,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                color: appBlack,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text('Send OTP', style: b_16white()),
            ),
          ),
        ),
      );
    }
    return Container();
  }

  Widget buttonVerifyOTP() {
    if (isMobileNoChanged) {
      return Column(
        children: [
          fieldName("OTP"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: screenWidth * .5,
                child: TextFormField(
                  controller: otpController,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(color: appGrey2),
                  cursorColor: appGrey2,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  decoration: inputDecoration2(hintText: 'OTP'),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    isSaved = false;
                    if (otpReviced.toString() == otpController.text) {
                      toastBuild("OTP verify\nPress save to make change.");
                      otpverified = true;
                      _phonechange = _phone;
                      FocusScope.of(context).requestFocus(new FocusNode());
                    } else {
                      toastBuild("OTP not verify");
                    }
                  });
                },
                child: Container(
                  width: screenWidth * .3,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  decoration: BoxDecoration(
                    color: appBlack,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('Verify', style: b_16white()),
                ),
              ),
            ],
          ),
        ],
      );
    }
    return Container();
  }

  Widget profileImageSection() {
    return Center(
      child: Container(
        height: screenWidth / 2,
        width: screenWidth / 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: appgreydate,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _updateimage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth / 2 * 2),
                    child: Image.file(
                      _image,
                      width: screenWidth / 2 * 2,
                      height: screenWidth / 2 * 2,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    child: profileData.imageUrl == null
                        ? Center(
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: appBlack,
                            ),
                          )
                        : CachedNetworkImage(
                            imageBuilder: (context, imageProvider) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      screenWidth / 2 * 2),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                            imageUrl: profileData.imageUrl,
                            width: screenWidth / 2 * 2,
                            height: screenWidth / 2 * 2,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) => Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                          ),
                  ),
            InkWell(
              onTap: () {
                if (picloading) {
                  toastBuild("Please wait...");
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              onTap: () {
                                Navigator.pop(context);
                                getImage(ImageSource.camera);
                              },
                              title: Text(
                                "Take a picture",
                                style: b_16Black(),
                              ),
                            ),
                            Divider(height: 0),
                            ListTile(
                              onTap: () {
                                Navigator.pop(context);
                                getImage(ImageSource.gallery);
                              },
                              title: Text(
                                "Select from Gallery",
                                style: b_16Black(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
              child: Container(
                height: screenWidth / 2,
                width: screenWidth / 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(.3),
                ),
                child: picloading
                    ? circularProgress(color: appwhite)
                    : Icon(
                        Icons.photo_camera_outlined,
                        color: appwhite,
                        size: 50,
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding fieldName(String name) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(name, style: b_14black()),
    );
  }

  void showCountryCodeDialog() {
    FocusScope.of(context).requestFocus(new FocusNode());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titleTextStyle: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: appBlack,
          ),
          title: new Text(
            "Please select Country code",
            style: b_14black(),
          ),
          content: StatefulBuilder(
            builder: (context, StateSetter setState) {
              return Container(
                height: screenHeight * 0.35,
                width: screenWidth / 1.1,
                child: ListView.builder(
                  itemCount: countryList.length,
                  itemBuilder: (context, i) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              indexcode = i;
                              countryCodeController.text =
                                  countryList[i].phonecode;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 45,
                                  child: Text(
                                    "+" + countryList[i].phonecode,
                                    style: TextStyle(
                                      color:
                                          indexcode == i ? appBlack : appGrey2,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    countryList[i].nicename,
                                    style: TextStyle(
                                      color:
                                          indexcode == i ? appBlack : appGrey2,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      isSaved = false;
                    });
                  },
                  child: Container(
                    height: screenHeight / 12,
                    width: screenWidth / 3,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: appBlack,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      'Select',
                      style: b_16white(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: screenHeight / 12,
                    width: screenWidth / 3,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: appwhite,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      'Cancel',
                      style: b_16Black(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> initialize() async {
    pref = await SharedPreferences.getInstance();
    overlay = LoaderOverlay.of(context);
  }

  Future<void> startOtpSend() async {
    final response = await overlay.during(
      sendOTP(
        "",
        countryCodeController.text + _phone,
      ),
    );
    setState(() {
      otpReviced = response;
    });
    success(context, 'OTP Sent');
  }

  Future<void> uploadProfileImage(File _image) async {
    final response = await overlay.during(
      saveProfileImage(_image),
    );
    if (response != '') {
      profileData.imageUrl = response;
      setState(() {
        _updateimage = _image;
        picloading = false;
        isSaved = true;
        success(context, "Profile Updated sucessfully");
      });
    } else {
      somethingWentWrong(context);
    }
  }

  dynamic getImageFromCamera() async {
    // ignore: deprecated_member_use
    final pickedFile = await _picker.getImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    setState(() async {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        await uploadProfileImage(_image);
        setState(() {
          picloading = true;
        });
      }
    });
  }

  dynamic getImageFromGallery() async {
    // ignore: deprecated_member_use
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        uploadProfileImage(_image);
        setState(() {
          picloading = true;
        });
      }
    });
  }

  dynamic onBack() {
    FocusScope.of(context).requestFocus(new FocusNode());
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Text(
                  "Do you want to go back without saving profile",
                  style: b_14black(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: appBlack,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Yes',
                        style: b_14white(),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      // save api call
                    },
                  ),
                  SizedBox(width: 15),
                  InkWell(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: appBlack),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'No',
                        style: b_14black(),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    final v = InputImage.fromFile(File(pickedFile.path));
    final faceDetector = GoogleMlKit.vision.faceDetector();
    List<Face> faces = await faceDetector.processImage(v);

    if (faces.isEmpty) {
      toastBuild("Upload only your photo");
      print("No faces detected");
    } else if (faces.length == 1) {
      print(" No faces detected ${faces.length}");
      if (mounted) {
        setState(() {
          _image = File(pickedFile.path);
          uploadProfileImage(_image);
          setState(() {
            picloading = true;
          });
        });
      }
    } else {
      toastBuild("Group photos are not allowed");
      print("No of faces detected ${faces.length}");
    }
  }
}
