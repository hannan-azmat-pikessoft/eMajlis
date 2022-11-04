
import 'package:emajlis/main.dart';
import 'package:emajlis/models/my_profile_model.dart';
import 'package:emajlis/models/upvotes_model.dart';
import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/services/svc_service.dart';
import 'package:emajlis/utlis/flutter_device_type.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';

class SVCScreen extends StatefulWidget {
  final String givenToImage;
  final String givenToId;
  final String givenById;
  final String givenToName;
  final String meetingId;

  const SVCScreen({Key key,
    this.givenToImage,
    this.givenToId,
    this.givenById,
    this.givenToName,
    this.meetingId})
      : super(key: key);

  @override
  _SVCScreenState createState() => _SVCScreenState();
}

class _SVCScreenState extends State<SVCScreen> {
  var initialize;
  int currentSVC = 0;
  List<String> selectedItem = [];
  MyProfile myprofile;
  LoaderOverlay overlay;

  @override
  void initState() {
    loadMyProfile();
    initialize = SVCService.getUpvotesDetails();
    overlay = LoaderOverlay.of(context);
    super.initState();
  }

  Future<void> loadMyProfile() async {
    final response = await getMyProfile();
    setState(() {
      myprofile = response;
      MyApp.setMyProfile(context, myprofile);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppbar(context, isAppTitle: true, titleText: "SVC"),
      backgroundColor: appBodyGrey,
      body: FutureBuilder(
        future: initialize,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.black),
              ),
            );
          } else if (snapshot.hasData) {
            UpvotesModelClass details = snapshot.data;
            return SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: ('You recently met '),
                                  style: b_14black(),
                                ),
                                TextSpan(
                                  text: (widget.givenToName),
                                  style: b_16Black(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                           openBottomModal(context);
                          },
                          child: Text(
                            'Learn more',
                            style: n_14greyU(),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40.0,
                            backgroundImage: NetworkImage(widget.givenToImage),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 44.0,
                              top: 16.0,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: CircleAvatar(
                                radius: 40.0,
                                backgroundImage: myprofile != null
                                    ? NetworkImage(myprofile.profile.imageUrl)
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                            ('Share your experience with ${widget
                                .givenToName} by giving '),
                            style: b_16black(),
                          ),
                          TextSpan(
                            text: ('SVC'),
                            style: b_16Black(),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                    ),
                    Text(
                      'Max 4 Allowed',
                      textAlign: TextAlign.center,
                      style: b_14black4(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: details.result
                            .asMap()
                            .map((key, value) =>
                            MapEntry(
                                key,
                                GestureDetector(
                                  onTap: () {
                                    if (!selectedItem.contains(value.id)) {
                                      if (selectedItem.length <= 4) {
                                        setState(() {
                                          selectedItem.add(value.id);
                                          currentSVC++;
                                        });
                                      } else {
                                        warning(context, 'Max 4 Allowed');
                                      }
                                    } else {
                                      setState(() {
                                        selectedItem.remove(value.id);
                                        currentSVC--;
                                      });
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 4.0, vertical: 4.0),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 14.0),
                                    decoration: BoxDecoration(
                                        color: selectedItem.contains(value.id)
                                            ? appBlack
                                            : Colors.white,
                                        border: Border.all(
                                            color: appBlack, width: 2.0),
                                        borderRadius:
                                        BorderRadius.circular(30.0)),
                                    child: !selectedItem.contains(value.id)
                                        ? Text(value.levelNameEn,
                                        style: b_12black())
                                        : Text(value.levelNameEn,
                                        style: b_12white()),
                                  ),
                                )))
                            .values
                            .toList(),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      margin: EdgeInsets.only(bottom: 20),
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
                      child: Text(
                        '$currentSVC SVC',
                        style: TextStyle(
                          color: appBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        primary: Colors.black,
                        padding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 41),
                      ),
                      onPressed: () async {
                        if (selectedItem.length > 0) {
                          if (currentSVC != 0) {
                            overlay = LoaderOverlay.of(context);
                            overlay.show();
                            final isSuccess = await SVCService.saveUpvoteScore(
                                widget.givenToId,
                                widget.givenById,
                                selectedItem,
                                currentSVC.toString(),
                                widget.meetingId);
                            overlay.hide();
                            if (isSuccess == null) {
                              somethingWentWrong(context);
                            } else if (isSuccess) {
                              Navigator.pop(context, true);
                            } else {
                              warning(context, "Please try again");
                            }
                          } else {
                            warning(context, "Add SVC to vote");
                          }
                        } else {
                          warning(context, "Select atleast one");
                        }
                      },
                      child: Text(
                        'Vote',
                        style: TextStyle(
                          fontSize: 12,
                          color: appwhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            return Center(
              child: Text('snapshot.error'),
            );
          }
        },
      ),
    );
  }

  Future<dynamic> openBottomModal(context) {
    return showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
            padding: EdgeInsets.only(
            bottom:30,
              top: 20,right: 20,left: 20

            ),
          child: RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              text: 'Every meet brings value',
              style:  b_15Black(),
              children: <TextSpan>[
                TextSpan(
                    text: '\n \nSocial Value Credit (SVC) is one of our most unique features which helps users grab the limelight.\n\nIt is a premium feature which allows users to share their reviews about the professionals and the experience of their meet-ups.\n\nThese reviews will improve the perceived value of your profile and gives your profile a good ranking.',
                    style:  b_14black4()
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
