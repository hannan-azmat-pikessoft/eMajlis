import 'dart:io';
import 'package:emajlis/environment.dart';
import 'package:emajlis/models/city_model.dart';
import 'package:emajlis/models/country_model.dart';
import 'package:emajlis/providers/common_provider.dart';
import 'package:emajlis/screens/authentication/otp_screen.dart';
import 'package:emajlis/services/authentication_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/textinput.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

class ProfileDetails extends StatefulWidget {
  final String email;
  final String password;
  final String firebaseToken;

  const ProfileDetails({
    Key key,
    @required this.email,
    @required this.password,
    @required this.firebaseToken,
  }) : super(key: key);
  @override
  _ProfileDetailsState createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  final formkey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  double screenHeight;
  double screenWidth;

  TextEditingController _nameC = TextEditingController();
  TextEditingController _mobileC = TextEditingController();
  TextEditingController _cityName = TextEditingController();
  TextEditingController countryCodeController = TextEditingController();
  TextEditingController _roleC = TextEditingController();

  Dio dio = new Dio();
  int id = 2;
  int index;
  int indexcode;
  String _phone = '';
  String cityname;
  String dialCode;
  String gender = 'Male';

  List<CountryModel> countryList = [];
  List<CityModel> cityList = [];

  // List<Face> _faces;
  File _imageFile;
  ui.Image _image;

  @override
  void initState() {
    super.initState();
    countryList = context.read<CommonProvider>().countryList;
    cityList = context.read<CommonProvider>().cityList;
    countryCodeController.text = "+" + countryList[0].phonecode;
    dialCode = countryList[0].phonecode;
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
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                          child: _image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      screenWidth * 0.2 * 2),
                                  child: Image.file(
                                    _imageFile,
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
                                                    getImage(
                                                        ImageSource.camera);
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

                                                    getImage(
                                                        ImageSource.gallery);
                                                  },
                                                  title: Text(
                                                    "Select from Gallery",
                                                    style: b_16Black(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                  }),
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
                    controller: _nameC,
                    keyboardType: TextInputType.text,
                    decoration: inputDecoration('Full Name'),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    readOnly: true,
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
                            title: Column(
                              children: [
                                new Text(
                                  "Please select emirate of Residence",
                                  style: b_14black(),
                                ),
                                StatefulBuilder(builder: (context, setState) {
                                  return Wrap(
                                    children: cityList
                                        .asMap()
                                        .map((i, e) => MapEntry(
                                            i,
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  index = i;
                                                  cityname = e.id;
                                                  _cityName.text = e.name;
                                                  print(e.name);
                                                });
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child: Text(
                                                  e.name,
                                                  style: TextStyle(
                                                    color: index == i
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: appBlack,
                                          borderRadius:
                                              BorderRadius.circular(7),
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
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: appwhite,
                                          borderRadius:
                                              BorderRadius.circular(7),
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
                            ),
                          );
                        },
                      );
                    },
                    style: TextStyle(
                      color: appGrey2,
                    ),
                    cursorColor: appGrey2,
                    textInputAction: TextInputAction.done,
                    controller: _cityName,
                    keyboardType: TextInputType.text,
                    decoration: inputDecoration('Emirates of residence'),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: screenWidth / 5.5,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          readOnly: true,
                          decoration: inputDecoration("Code"),
                          style: TextStyle(
                            color: appGrey2,
                          ),
                          cursorColor: appGrey2,
                          textInputAction: TextInputAction.done,
                          controller: countryCodeController,
                          keyboardType: TextInputType.text,
                          onTap: () {
                            showCountryCodeDialog();
                          },
                        ),
                      ),
                      Container(
                        width: screenWidth / 1.5,
                        child: TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                            color: appGrey2,
                          ),
                          controller: _mobileC,
                          onChanged: (value) {
                            setState(() {
                              _phone = value;
                            });
                          },
                          validator: (value) {
                            if (value.trim().isEmpty) {
                              return "Enter phone number";
                            } else if (value.length < 8) {
                              return "Please valid enter phone number";
                            } else {
                              setState(() {
                                _phone = value;
                              });
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
                        // setState(() {
                        //   _role = value;
                        // });

                        return null;
                      }
                    },
                    style: TextStyle(
                      color: appGrey2,
                    ),
                    cursorColor: appGrey2,
                    textInputAction: TextInputAction.done,
                    controller: _roleC,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      // setState(() {
                      //   _role = value;
                      // });
                    },
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
                        groupValue: id,
                        onChanged: (val) {
                          setState(() {
                            gender = 'Male';
                            id = 0;
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
                        groupValue: id,
                        onChanged: (val) {
                          setState(() {
                            gender = 'Female';
                            id = 1;
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
                              indexcode = i;
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
                                  width: 50,
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
          _imageFile = File(pickedFile.path);
          _loadImage(File(pickedFile.path));
        });
      }
    } else {
      toastBuild("Group photos are not allowed");
      print("No of faces detected ${faces.length}");
    }
  }

  dynamic _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then((value) => setState(() {
          _image = value;
        }));
  }

  onDone() async {
    if (formkey.currentState.validate()) {
      if (_image == null) {
        warning(context, "Please add image");
      } else {
        LoaderOverlay overlay = LoaderOverlay.of(context);
        final isExist = await overlay.during(
          verifyMobile(dialCode + _phone),
        );
        if (isExist == null) {
          somethingWentWrong(context);
        } else if (isExist) {
          warning(context, "Mobile is already used, Please login");
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                phoneNumber: _phone,
                code: dialCode,
                password: widget.password,
                email: widget.email,
                cityName: cityname,
                fullName: _nameC.text,
                gender: id.toString(),
                role: _roleC.text,
                image: _imageFile,
                firebaseToken: widget.firebaseToken,
              ),
            ),
          );
        }
      }
    } else {
      warning(context, "Please enter all fields");
    }
  }

  Future<dynamic> registerSocialApi(
    File _image, {
    String fullName,
    String cityName,
    String code,
    String phoneNumber,
    String role,
    String email,
    String password,
    String gender,
    String deviceType,
    String deviceToken,
    String socialid,
    String socialType,
  }) async {
    try {
      String fileName = _image.path.split('/').last;
      FormData formData = new FormData.fromMap({
        "firstname": fullName,
        "lastname": "",
        "email": email,
        "password": " ",
        "phone_no": phoneNumber,
        "profession": role,
        "country_id": cityName,
        "gender": gender,
        "dialcode": code,
        "device_type": deviceType,
        "device_token": deviceToken,
        "social_id": socialid,
        "social_type": socialType,
        "lat": "0.2568",
        "lang": "0.3698",
        "image": await http.MultipartFile.fromPath(
          fileName,
          _image.path,
        ),
      });
      dynamic response = await dio.post(
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
  }
}
