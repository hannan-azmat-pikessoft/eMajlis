import 'dart:io';
import 'package:emajlis/models/city_model.dart';
import 'package:emajlis/models/country_model.dart';
import 'package:emajlis/providers/common_provider.dart';
import 'package:emajlis/screens/authentication/otp_social_screen.dart';
import 'package:emajlis/services/authentication_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/textinput.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileDetailsSocial extends StatefulWidget {
  final String email;
  final String imageUrl;
  final String fullName;
  final String socialId;
  final String socialType;
  final String firebaseToken;

  const ProfileDetailsSocial({
    Key key,
    @required this.email,
    this.imageUrl,
    this.fullName,
    this.socialId,
    this.socialType,
    this.firebaseToken,
  }) : super(key: key);
  @override
  _ProfileDetailsSocialState createState() => _ProfileDetailsSocialState();
}

class _ProfileDetailsSocialState extends State<ProfileDetailsSocial> {
  final formkey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  double screenHeight;
  double screenWidth;

  List<CountryModel> countryList = [];
  List<CityModel> cityList = [];

  File imageFile;
  int genderId = 2;
  String gender = 'Male';
  String cityId = '';
  String dialCode = '';
  int countryIndex;
  int cityIndex;

  TextEditingController fullNameController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController cityNameController = TextEditingController();
  TextEditingController countryCodeController = TextEditingController();
  TextEditingController professionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    countryList = context.read<CommonProvider>().countryList;
    cityList = context.read<CommonProvider>().cityList;
    countryCodeController.text = "+" + countryList[0].phonecode;
    dialCode = countryList[0].phonecode;
    fullNameController.text = widget.fullName;
    _onImagDownloadButtonPressed(widget.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    this.screenHeight = MediaQuery.of(context).size.height;
    this.screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: appBlackBackground,
      body: SafeArea(
        child: Form(
          key: formkey,
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Profile Details',
                      style: bn_27white(),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    alignment: Alignment.center,
                    width: screenWidth / 4.7 * 2,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: screenWidth * 0.2,
                          backgroundColor: appwhite,
                          foregroundColor: appGrey3,
                          child: imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.2 * 2,
                                  ),
                                  child: Image.file(
                                    imageFile,
                                    width: screenWidth * 0.19 * 2,
                                    height: screenWidth * 0.19 * 2,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: appGrey3,
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.19 * 2),
                                  ),
                                  width: screenWidth * 0.19 * 2,
                                  height: screenWidth * 0.19 * 2,
                                  child: Icon(
                                    Icons.person,
                                    size: 100,
                                    color: appBlack,
                                  ),
                                ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            backgroundColor: appwhite,
                            radius: screenHeight / 40,
                            child: Center(
                              child: IconButton(
                                icon: Icon(
                                  Icons.camera_alt_outlined,
                                  size: screenHeight / 35,
                                  color: appBlack,
                                ),
                                onPressed: () {
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
                                                getImageCamera();
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
                                                getImageGallery();
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
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return "Enter Full name";
                      } else if ((value.length <= 2)) {
                        return "Full name must be longer then 2 letters.";
                      } else {
                        return null;
                      }
                    },
                    style: TextStyle(
                      color: appGrey2,
                    ),
                    cursorColor: appGrey2,
                    textInputAction: TextInputAction.done,
                    controller: fullNameController,
                    keyboardType: TextInputType.text,
                    decoration: inputDecoration('Full Name'),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: cityNameController,
                    readOnly: true,
                    style: TextStyle(
                      color: appGrey2,
                    ),
                    cursorColor: appGrey2,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    decoration: inputDecoration('Emirates of residence'),
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
                            content:
                                StatefulBuilder(builder: (context, setState) {
                              return Wrap(
                                children: cityList
                                    .asMap()
                                    .map((i, e) => MapEntry(
                                        i,
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              cityIndex = i;
                                              cityId = e.id;
                                              cityNameController.text = e.name;
                                            });
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Text(
                                              e.name,
                                              style: TextStyle(
                                                color: cityIndex == i
                                                    ? appBlack
                                                    : appGrey2,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        )))
                                    .values
                                    .toList(),
                              );
                            }),
                            actions: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      height: screenHeight / 12,
                                      width: screenWidth / 3,
                                      alignment: Alignment.center,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
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
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
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
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: screenWidth / 5.5,
                        child: TextFormField(
                          controller: countryCodeController,
                          textCapitalization: TextCapitalization.sentences,
                          readOnly: true,
                          decoration: inputDecoration("Code"),
                          style: TextStyle(
                            color: appGrey2,
                          ),
                          cursorColor: appGrey2,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          onTap: () {
                            showCountryCodeDialog();
                          },
                        ),
                      ),
                      Container(
                        width: screenWidth / 1.5,
                        child: TextFormField(
                          controller: mobileNoController,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                            color: appGrey2,
                          ),
                          validator: (value) {
                            if (value.trim().isEmpty) {
                              return "Enter Mobile Number";
                            } else if (value.length < 8) {
                              return "Please enter valid Mobile Number";
                            } else {
                              return null;
                            }
                          },
                          cursorColor: appGrey2,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          decoration: inputDecoration('Mobile Number'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return "Enter role";
                      } else if ((value.length < 2)) {
                        return "Role must be longer then 2 letters.";
                      } else {
                        return null;
                      }
                    },
                    style: TextStyle(
                      color: appGrey2,
                    ),
                    cursorColor: appGrey2,
                    textInputAction: TextInputAction.done,
                    controller: professionController,
                    keyboardType: TextInputType.text,
                    decoration: inputDecoration('Profession / Designation'),
                  ),
                  SizedBox(height: 20),
                  /* Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 16,
                        color: appGrey3,
                      ),
                    ),
                  ), */
                  /* Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Radio(
                        value: 0,
                        activeColor: appwhite,
                        groupValue: genderId,
                        onChanged: (val) {
                          setState(() {
                            gender = 'Male';
                            genderId = 0;
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
                        activeColor: appwhite,
                        groupValue: genderId,
                        onChanged: (val) {
                          setState(() {
                            gender = 'Female';
                            genderId = 1;
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
                  ), */
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      onDone();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 22),
                      decoration: BoxDecoration(
                        color: appwhite,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        'Done',
                        style: b_16Black(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
                              countryIndex = i;
                              dialCode = countryList[i].phonecode;
                              countryCodeController.text =
                                  "+" + countryList[i].phonecode;
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
                                      color: countryIndex == i
                                          ? appBlack
                                          : appGrey2,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    countryList[i].nicename,
                                    style: TextStyle(
                                      color: countryIndex == i
                                          ? appBlack
                                          : appGrey2,
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

  void _onImagDownloadButtonPressed(String url) async {
    try {
      if (url != "") {
        var imageId = await ImageDownloader.downloadImage(url);
        if (imageId == null) {
          return;
        }
        var path = await ImageDownloader.findPath(imageId);
        setState(() {
          imageFile = File(path);
        });
      } else {
        return;
      }
    } on PlatformException catch (error) {
      print(error);
    }
  }

  Future<void> getImageCamera() async {
    // ignore: deprecated_member_use
    final pickedFile = await _picker.getImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> getImageGallery() async {
    // ignore: deprecated_member_use
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        print("file when pick : " + imageFile.toString());
      } else {
        print('No image selected.');
      }
    });
  }

  onDone() async {
    if (imageFile == null) {
      warning(context, "Please add image");
    } else if (!formkey.currentState.validate()) {
      warning(context, "Please enter all fields");
    } else if (cityId == '') {
      warning(context, "Please select Emirate of Residence");
    } else {
      LoaderOverlay overlay = LoaderOverlay.of(context);
      final isExist = await overlay.during(
        verifyMobile(dialCode + mobileNoController.text),
      );
      if (isExist == null) {
        somethingWentWrong(context);
      } else if (isExist) {
        warning(context, "Mobile No is already used, Please login");
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPSocialScreen(
              imageFile: imageFile,
              dialCode: dialCode,
              phoneNo: mobileNoController.text,
              password: " ",
              email: widget.email,
              cityId: cityId,
              fullName: fullNameController.text,
              genderId: genderId,
              role: professionController.text,
              deviceType: "web",
              deviceToken: widget.firebaseToken,
              socialType: widget.socialType,
              socialId: widget.socialId,
              firebaseToken: widget.firebaseToken,
            ),
          ),
        );
      }
    }
  }
}
