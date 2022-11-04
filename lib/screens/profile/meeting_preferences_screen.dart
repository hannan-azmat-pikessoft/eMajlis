import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/models/meeting_preference_model.dart';
import 'package:emajlis/services/meeting_preference_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MeetingPreferencesScreen extends StatefulWidget {
  final List<MeetingPreferenceModel> myPreferenceList;
  MeetingPreferencesScreen({this.myPreferenceList});

  @override
  _MeetingPreferencesScreenState createState() =>
      _MeetingPreferencesScreenState();
}

class _MeetingPreferencesScreenState extends State<MeetingPreferencesScreen> {
  List<MeetingPreferenceModel> preferenceList = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: appBodyGrey,
      appBar: simpleAppbar(
        context,
        titleText: "Select Meeting Preferences",
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: EdgeInsets.all(10),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: appwhite,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SvgPicture.asset(Common.MeetingPreferencesSvg),
              ),
              Text("Meeting Preferences", style: b_14black()),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Tell your matches what are the most practical times or ways to get together for a first meeting",
                  style: n_12grey(),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                preferenceList
                        .where((element) => element.isSelected)
                        .toList()
                        .length
                        .toString() +
                    " out 4 max allowed",
                style: b_12black(),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: height * 0.5,
                child: GridView.builder(
                  itemCount: preferenceList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (BuildContext context, int i) {
                    return InkWell(
                      onTap: () {
                        if (preferenceList[i].isSelected) {
                          setState(() {
                            preferenceList[i].isSelected = false;
                          });
                        } else {
                          if (preferenceList
                                  .where((element) => element.isSelected)
                                  .toList()
                                  .length <
                              4) {
                            setState(() {
                              preferenceList[i].isSelected = true;
                            });
                          }
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: preferenceList[i].isSelected == true
                              ? appBlack
                              : appwhite,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 5,
                              offset: Offset(0, 5),
                              color: Colors.grey[300],
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              child: Image.network(
                                preferenceList[i].imageName,
                                color: preferenceList[i].isSelected == true
                                    ? appwhite
                                    : appBlack,
                              ),
                            ),
                            Text(
                              preferenceList[i].preferenceTypeName,
                              style: preferenceList[i].isSelected == true
                                  ? b_12white()
                                  : b_12black(),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
    );
  }

  Future<void> loadData() async {
    final overlay = LoaderOverlay.of(context);
    final response = await overlay.during(getMeetingPreferences());
    setState(() {
      preferenceList = response;
      for (var i = 0; i < preferenceList.length; i++) {
        if (widget.myPreferenceList.any((e) => e.id == preferenceList[i].id)) {
          preferenceList[i].isSelected = true;
        }
      }
    });
  }

  Future<void> onSave() async {
    final selected = preferenceList
        .where((element) => element.isSelected)
        .map((e) => e.id)
        .toList()
        .join(',');
    final overlay = LoaderOverlay.of(context);
    final isSuccess = await overlay.during(
      saveMeetingPreferences(selected),
    );
    if (isSuccess) {
      Navigator.pop(
          context, preferenceList.where((e) => e.isSelected).toList());
    } else {
      toastBuild("Somthing went wrong, Try again later");
    }
  }
}
