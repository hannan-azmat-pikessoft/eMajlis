import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/models/education_model.dart';
import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/textinput.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EducationScreen extends StatefulWidget {
  final EducationModel education;
  EducationScreen({this.education});

  @override
  _EducationScreenState createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  EducationModel education;
  TextEditingController degreeC = TextEditingController();
  TextEditingController cityC = TextEditingController();
  TextEditingController schoolC = TextEditingController();

  @override
  void initState() {
    super.initState();
    education = widget.education;
    if (education == null) {
      education = new EducationModel();
    }
    degreeC.text = education.degree ?? "";
    cityC.text = education.city ?? "";
    schoolC.text = education.school ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBodyGrey,
      appBar: simpleAppbar(context, titleText: "Education"),
      body: Form(
        key: formkey,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            padding: EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: appwhite,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: SvgPicture.asset(Common.EducationSvg),
                ),
                Text(
                  "Your Qualifications",
                  style: b_14black(),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      fieldName("Qualification"),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(color: appGrey2),
                        cursorColor: appGrey2,
                        textInputAction: TextInputAction.done,
                        controller: degreeC,
                        keyboardType: TextInputType.text,
                        decoration: inputDecoration2(
                          labelText: 'Highest Qualification',
                        ),
                        validator: (value) {
                          if (value.trim().isEmpty) {
                            return "Enter Highest Qualification";
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(color: appGrey2),
                        cursorColor: appGrey2,
                        textInputAction: TextInputAction.done,
                        controller: schoolC,
                        keyboardType: TextInputType.text,
                        decoration: inputDecoration2(
                          labelText: 'Educational Institute',
                        ),
                        validator: (value) {
                          if (value.trim().isEmpty) {
                            return "Enter Educational Institute";
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(color: appGrey2),
                        cursorColor: appGrey2,
                        textInputAction: TextInputAction.done,
                        controller: cityC,
                        keyboardType: TextInputType.text,
                        decoration: inputDecoration2(
                          labelText: 'City/State',
                        ),
                        validator: (value) {
                          if (value.trim().isEmpty) {
                            return "Enter City/State";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    onSave();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: appBlack,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    width: double.infinity,
                    height: 60,
                    child: Text(
                      "Save",
                      style: b_14white(),
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  Future<void> onSave() async {
    education.degree = degreeC.text;
    education.city = cityC.text;
    education.school = schoolC.text;

    if (formkey.currentState.validate()) {
      final overlay = LoaderOverlay.of(context);
      final response = await overlay.during(
        saveEducation(education),
      );

      if (response.status) {
        Navigator.pop(context, education);
      } else {
        toastBuild(response.message);
      }
    }
  }
}
