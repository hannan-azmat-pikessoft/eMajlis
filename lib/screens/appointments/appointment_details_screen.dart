import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/models/my_profile_model.dart';
import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final String otherMemberId;
  const AppointmentDetailsScreen({
    Key key,
    @required this.otherMemberId,
  }) : super(key: key);

  @override
  _AppointmentDetailsScreenState createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  SharedPreferences pref;
  LoaderOverlay overlay;
  double height;
  double width;

  MyProfile myprofile;
  int svcId = 5;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: appBodyGrey,
        height: MediaQuery.of(context).size.height,
        child: myprofile != null
            ? Stack(
                children: [
                  Container(
                    height: height * 0.4,
                    decoration: BoxDecoration(
                      color: appBlack,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(myprofile.profile.imageUrl),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: width / 10,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            onShare();
                          },
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.share,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final response = await overlay.during(
                              saveProfileForLater(myprofile.profile.id),
                            );
                            if (response != '') {
                              success(context, response);
                            } else {
                              somethingWentWrong(context);
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.save_alt,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final isSuccess = await overlay.during(
                              blockUnblockMember(
                                myprofile.profile.id,
                                0,
                              ),
                            );
                            if (isSuccess) {
                              success(context, "Blocked");
                            } else {
                              somethingWentWrong(context);
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.block,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: height / 3.5,
                    left: 25,
                    right: 25,
                    child: Container(
                      alignment: Alignment.center,
                      width: width / 1.5,
                      decoration: BoxDecoration(
                        color: appwhite,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                myprofile.profile.firstname ?? '',
                                style: b_15Black(),
                              ),
                            ),
                            myprofile.profile.city == ''
                                ? Container()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Center(
                                      child: Text(
                                          '(' + myprofile.profile.city + ')'),
                                    ),
                                  ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xffFFCD07),
                                        Color(0xffE97A18),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(Common.SecuritySvg),
                                      SizedBox(width: 5),
                                      Text(
                                        '3 SVC',
                                        style: TextStyle(
                                          color: appBlack,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Introduction' ?? '',
                              style: b_15Black(),
                            ),
                            SizedBox(height: 5),
                            Text(
                              myprofile.profile.introduction ?? '',
                              style: n_12black(),
                            ),
                            SizedBox(height: 10),
                            goalsSection(),
                            voteSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(),
      ),
    );
  }

  Widget goalsSection() {
    return Column(
      children: [
        Text(
          'Goals & Objectives',
          style: b_15Black(),
        ),
        SizedBox(height: 5),
        myprofile.goalList.length > 0
            ? Wrap(
                children: [
                  for (var i = 0; i < myprofile.goalList.length; i++)
                    Container(
                      margin: EdgeInsets.all(3),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: appGrey6,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        myprofile.goalList[i].name,
                        style: n_10white(),
                      ),
                    ),
                ],
              )
            : Container(),
      ],
    );
  }

  Widget voteSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "If you have met with ${myprofile.profile.firstname ?? ''} and would like to apply a Social Value Credit(SVC) to their account please select one of the following reasons you think they deserve a SVC",
                  style: b_14black(),
                ),
                content: StatefulBuilder(
                  builder: (context, setState) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: width,
                            decoration: BoxDecoration(
                              color: appwhite,
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                              border: Border.all(color: appwhite),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: [
                                    Radio(
                                      value: 1,
                                      activeColor: appBlack,
                                      groupValue: svcId,
                                      onChanged: (val) async {
                                        setState(() {
                                          svcId = 1;
                                        });
                                      },
                                    ),
                                    Text(
                                      'Professional Attitude',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: appGrey4,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      value: 2,
                                      activeColor: appBlack,
                                      groupValue: svcId,
                                      onChanged: (val) async {
                                        setState(() {
                                          svcId = 2;
                                        });
                                      },
                                    ),
                                    Text(
                                      'Future Mentor',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: appGrey4,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      value: 3,
                                      activeColor: appBlack,
                                      groupValue: svcId,
                                      onChanged: (val) async {
                                        setState(() {
                                          svcId = 3;
                                        });
                                      },
                                    ),
                                    Text(
                                      'Visionary',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: appGrey4,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      value: 4,
                                      activeColor: appBlack,
                                      groupValue: svcId,
                                      onChanged: (val) async {
                                        setState(() {
                                          svcId = 4;
                                        });
                                      },
                                    ),
                                    Text(
                                      'Industry Knowledge',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: appGrey4,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            onApplySVC();
                          },
                          child: Container(
                            height: 40,
                            width: width * 0.3,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: appBlack,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'Apply SVC',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 40,
                            width: width * 0.3,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: appBlack),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: appBlack, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          );
        },
        child: Center(
          child: Container(
            alignment: Alignment.center,
            height: 40,
            width: 100,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: appBodyGrey,
              border: Border.all(color: appBlack),
              borderRadius: BorderRadius.circular(
                5,
              ),
            ),
            child: Text(
              'Vote',
              style: TextStyle(
                color: appBlack,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Future onShare() async {
    try {
      final imageId =
          await ImageDownloader.downloadImage(myprofile.profile.imageUrl);
      if (imageId == null) {
        return;
      }
      final path = await ImageDownloader.findPath(imageId);
      final RenderBox box = context.findRenderObject() as RenderBox;
      String text = Utility.getShareText(myprofile.profile.firstname);
      Share.shareFiles(['$path'],
          text: text,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } on PlatformException catch (error) {
      print(error);
    }
    return;
  }

  Future<void> onApplySVC() async {
    if (svcId == 5) {
      warning(context, "Please apply any SVC");
    } else {
      final isSuccess = await saveCreditScore(
        myprofile.profile.id,
        svcId.toString(),
      );
      if (isSuccess) {
        success(context, "Done");
      } else {
        somethingWentWrong(context);
      }

      Navigator.pop(context);
    }
  }

  Future<void> loadData() async {
    pref = await SharedPreferences.getInstance();
    overlay = LoaderOverlay.of(context);
    overlay.show();
    final response = await getMemberProfile(widget.otherMemberId);
    overlay.hide();
    if (response == null) {
      error(context, 'Member details not found');
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } else {
      setState(() {
        myprofile = response;
      });
    }
  }
}
