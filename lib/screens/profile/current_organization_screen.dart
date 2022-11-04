import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/models/organization_model.dart';
import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/textinput.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CurrentOrganizationScreen extends StatefulWidget {
  final String currentOccupation;
  final String currentOrganization;

  const CurrentOrganizationScreen({
    this.currentOccupation,
    this.currentOrganization,
  });

  @override
  _CurrentOrganizationScreenState createState() =>
      _CurrentOrganizationScreenState();
}

class _CurrentOrganizationScreenState extends State<CurrentOrganizationScreen> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController currentOccupationC = TextEditingController();
  TextEditingController currentOrganizationC = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentOccupationC.text = widget.currentOccupation;
    currentOrganizationC.text = widget.currentOrganization;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBodyGrey,
      appBar: simpleAppbar(context, titleText: "Current Organisation"),
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
                  child: SvgPicture.asset(Common.OrganizationSvg),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      fieldName("Current Organisation"),
                      TextFormField(
                        style: TextStyle(color: appGrey2),
                        cursorColor: appGrey2,
                        textInputAction: TextInputAction.done,
                        controller: currentOccupationC,
                        keyboardType: TextInputType.text,
                        decoration: inputDecoration2(
                          labelText: 'Current occupation',
                        ),
                        validator: (value) {
                          if (value.trim().isEmpty) {
                            return "Enter Current occupation";
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        style: TextStyle(color: appGrey2),
                        cursorColor: appGrey2,
                        textInputAction: TextInputAction.done,
                        controller: currentOrganizationC,
                        keyboardType: TextInputType.text,
                        decoration: inputDecoration2(
                          labelText: 'Company or Organisation',
                        ),
                        validator: (value) {
                          if (value.trim().isEmpty) {
                            return "Enter Company or Organisation";
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
    if (formkey.currentState.validate()) {
      OrganizationModel request = new OrganizationModel();
      request.designation = currentOccupationC.text;
      request.organizationName = currentOrganizationC.text;
      final overlay = LoaderOverlay.of(context);
      final isSuccess = await overlay.during(
        saveCurrentOrganization(request),
      );
      if (isSuccess) {
        Navigator.pop(context, request);
      } else {
        toastBuild("Somthing went wrong, Try again later");
      }
    }
  }
}
