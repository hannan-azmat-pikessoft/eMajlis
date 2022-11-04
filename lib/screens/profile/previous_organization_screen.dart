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

class PreviousOrganizationScreen extends StatefulWidget {
  final OrganizationModel organization;
  const PreviousOrganizationScreen({this.organization});

  @override
  _PreviousOrganizationScreenState createState() =>
      _PreviousOrganizationScreenState();
}

class _PreviousOrganizationScreenState
    extends State<PreviousOrganizationScreen> {
  final formkey = GlobalKey<FormState>();
  TextEditingController organizationController = TextEditingController();
  TextEditingController occupationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    organizationController.text = widget.organization.organizationName;
    occupationController.text = widget.organization.designation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBodyGrey,
      appBar: simpleAppbar(context, titleText: "Previous Organisation"),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      fieldName("Previous Organisation"),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(color: appGrey2),
                        cursorColor: appGrey2,
                        textInputAction: TextInputAction.done,
                        controller: occupationController,
                        keyboardType: TextInputType.text,
                        decoration: inputDecoration2(
                          labelText: 'Previous occupation',
                        ),
                        validator: (value) {
                          if (value.trim().isEmpty) {
                            return "Enter Previous occupation";
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(color: appGrey2),
                        cursorColor: appGrey2,
                        textInputAction: TextInputAction.done,
                        controller: organizationController,
                        keyboardType: TextInputType.text,
                        decoration: inputDecoration2(
                          labelText: 'designation or Organisation',
                        ),
                        validator: (value) {
                          if (value.trim().isEmpty) {
                            return "Enter designation or Organisation";
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
                    height: 60,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: appBlack,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text("Save", style: b_14white()),
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
      request.id = widget.organization.id;
      request.designation = occupationController.text;
      request.organizationName = organizationController.text;
      final overlay = LoaderOverlay.of(context);
      final isSuccess = await overlay.during(
        savePreviousOrganization(request),
      );
      if (isSuccess) {
        Navigator.pop(context, request);
      } else {
        toastBuild("Somthing went wrong, Try again later");
      }
    }
  }
}
