import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/models/meeting_preference_model.dart';
import 'package:emajlis/models/my_profile_model.dart';
import 'package:emajlis/screens/chat/message_screen.dart';
import 'package:emajlis/screens/home/quick_connect_screen.dart';
import 'package:emajlis/screens/home/notification_screen.dart';
import 'package:emajlis/providers/home_provider.dart';
import 'package:emajlis/screens/profile/profile_screen.dart';
import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/progress.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
  playSound: true,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NewHomeScreen extends StatefulWidget {
  final Function triggerPanel;
  final SlidingUpPanelController panelController;

  NewHomeScreen({
    this.triggerPanel,
    this.panelController,
  });

  @override
  _NewHomeScreenState createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen>
    with TickerProviderStateMixin {
  double height;
  double width;
  SharedPreferences prefs;
  ScrollController scrollController;

  int unRead = 0;
  int curr = 0;
  bool isReject = false;
  bool isAccept = false;
  String memberImage = '';
  bool isBottom = false;
  int profileCompletionPercentage = 0;
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _userLocation;
  String lat = '';
  String lang = '';

  @override
  void initState() {
    super.initState();
    // getProfileImage();
    getProfile();
    scrollController = ScrollController();
    _getUserLocation().then(
        (value) => context.read<HomeProvider>().discover(lat: lat, lang: lang));
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    CardController controller; //Use this to trigger swap.
    return Scaffold(
      backgroundColor: appBodyGrey,
      body: Consumer<HomeProvider>(builder: (context, pHome, child) {
        return SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: height * 0.015,
              ),
              appBar(pHome),
              Expanded(
                child:
                    //NestedScrollView(
                    // floatHeaderSlivers: false,
                    // headerSliverBuilder:
                    //     (BuildContext context, bool innerBoxIsScrolled) {
                    //   return <Widget>[
                    //     SliverAppBar(
                    //       title: appBar(pHome),
                    //       backgroundColor: appBodyGrey,
                    //       pinned: false,
                    //       floating: false,
                    //       stretch: false,
                    //     ),
                    //   ];
                    // },
                    //body:
                    Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: height * 0.015,
                    ),
                    if (pHome.isLoadingConnections && pHome.profilesLength == 0)
                      Center(child: circularProgressBig()),
                    if (!pHome.isLoadingConnections &&
                        pHome.profilesLength == 0)
                      Center(
                        child: Text(
                          "Oops! No more connections.\nTry again, later.",
                          style: TextStyle(
                            color: appBlack,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (!pHome.isLoadingConnections &&
                        pHome.profilesLength == 0)
                      Center(
                        child: InkWell(
                          onTap: () {
                            context
                                .read<HomeProvider>()
                                .discover(lat: lat, lang: lang);
                            isReject = false;
                            isAccept = false;
                            curr = 0;
                          },
                          child: Container(
                            margin: EdgeInsets.all(20),
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: appBlack,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'Get New Match',
                              style: TextStyle(
                                color: appwhite,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (pHome.profilesLength > 0 && pHome.homelist.length != 0)
                      Expanded(
                        child: TinderSwapCard(
                          swipeEdgeVertical: 10,
                          allowVerticalMovement: false,
                          swipeUp: false,
                          swipeDown: false,
                          //animDuration: 0,
                          orientation: AmassOrientation.BOTTOM,
                          totalNum: pHome.homelist.length,
                          stackNum: 2,
                          swipeEdge: 4,
                          maxWidth: MediaQuery.of(context).size.width,
                          maxHeight: height,
                          minWidth: MediaQuery.of(context).size.width * 0.8,
                          minHeight: height * 0.9,
                          cardBuilder: (context, index) {
                            curr = index;
                            return SingleChildScrollView(
                              physics: ClampingScrollPhysics(),
                              child: Column(
                                children: [
                                  Card(
                                    margin: EdgeInsets.only(
                                        top: 0, bottom: 0, left: 0, right: 0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15)
                                        // borderRadius: BorderRadius.only(
                                        //     topLeft: Radius.circular(15),
                                        //     topRight: Radius.circular(15)),
                                        ),
                                    elevation: 0,
                                    shadowColor: Colors.grey[100],
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomRight,
                                          colors: isReject
                                              ? [
                                                  Colors.white10,
                                                  Colors.white10,
                                                  appRedShadow,
                                                  appRedShadow
                                                ]
                                              : isAccept
                                                  ? [
                                                      Colors.white10,
                                                      Colors.white10,
                                                      appGreenShadow,
                                                      appGreenShadow
                                                    ]
                                                  : [
                                                      Colors.transparent,
                                                      Colors.transparent
                                                    ],
                                        ),
                                      ),
                                      child: Column(
                                        // mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Stack(
                                            children: [
                                              imageBottom(4, height * 0.419),
                                              imageBottom(0, height * 0.409),
                                              //  imageBottom(4, height * 0.41),
                                              Container(
                                                height: height * 0.4,
                                                // width: MediaQuery.of(context).size.width,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image:
                                                          CachedNetworkImageProvider(
                                                              pHome
                                                                  .homelist[
                                                                      index]
                                                                  .image)
                                                      // NetworkImage(
                                                      //   pHome.homelist[index].image,
                                                      //
                                                      // ),
                                                      ),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    // SvgPicture.asset("assets/images/icons/svgIcon.svg",
                                                    //   width:
                                                    //   11,
                                                    //   height:
                                                    //   11,
                                                    //     ),
                                                    //   SizedBox(width: 5),
                                                    Positioned(
                                                        top: 8,
                                                        left: 8,
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            Image.asset(
                                                              "assets/images/icons/svc.png",
                                                            ),
                                                            Text(
                                                              pHome
                                                                          .homelist[
                                                                              index]
                                                                          .svc ==
                                                                      null
                                                                  ? "0"
                                                                  : pHome
                                                                      .homelist[
                                                                          index]
                                                                      .svc
                                                                      .toString(),
                                                              style: TextStyle(
                                                                color:
                                                                    svgTextColor,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                    //FittedBox(fit: BoxFit.fill,child: Image.asset("assets/images/icons/svc.png",))),
                                                    // Row(
                                                    //   children: [
                                                    //
                                                    //     // SvgPicture.asset(
                                                    //     //     Common.SecuritySvg),
                                                    //     // SizedBox(width: 5),
                                                    //     Positioned(
                                                    //       top: 15,
                                                    //       left: 18,
                                                    //       child: Text(
                                                    //         pHome.homelist[index]
                                                    //                     .svc ==
                                                    //                 null
                                                    //             ? "0"
                                                    //             : pHome
                                                    //                 .homelist[
                                                    //                     index]
                                                    //                 .svc
                                                    //                 .toString(),
                                                    //         style: TextStyle(
                                                    //           color: svgTextColor,
                                                    //           fontSize: 18,
                                                    //           fontWeight:
                                                    //               FontWeight.bold,
                                                    //         ),
                                                    //       ),
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                    Positioned(
                                                      top: 8,
                                                      right: 10,
                                                      child: Row(
                                                        children: [
                                                          // shareButton(pHome
                                                          //     .homelist[index]),
                                                          // SizedBox(width: 10),
                                                          bookmarkButton(pHome
                                                              .homelist[index]),
                                                        ],
                                                      ),
                                                    ),
                                                    pHome.homelist[index]
                                                                .nearToMe !=
                                                            null
                                                        ? Positioned(
                                                            bottom: 10,
                                                            left: 0,
                                                            right: 0,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    // Navigator.push(
                                                                    //   context,
                                                                    //   MaterialPageRoute(
                                                                    //     builder: (context) =>
                                                                    //         ProfileInformationScreen(
                                                                    //       memberId: pHome
                                                                    //           .homelist[
                                                                    //               index]
                                                                    //           .usermemberid,
                                                                    //       isFromChatScreen:
                                                                    //           false,
                                                                    //     ),
                                                                    //   ),
                                                                    // );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding: EdgeInsets.only(
                                                                        top: 7,
                                                                        bottom:
                                                                            7,
                                                                        right:
                                                                            13,
                                                                        left:
                                                                            13),
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    //width: 130,
                                                                    // height: 30,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: appBlack
                                                                          .withOpacity(
                                                                              0.7),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              25),
                                                                    ),
                                                                    child:
                                                                        Material(
                                                                      type: MaterialType
                                                                          .transparency,
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              pHome.homelist[index].nearToMe != null
                                                                                  ? Padding(
                                                                                      padding: const EdgeInsets.only(top: 3, bottom: 1),
                                                                                      child: SvgPicture.asset(
                                                                                        "assets/images/icons/location.svg",
                                                                                        width: 11,
                                                                                        height: 11,
                                                                                      ),
                                                                                    )
                                                                                  : Container(),
                                                                              SizedBox(
                                                                                width: 4,
                                                                              ),
                                                                              Text(
                                                                                pHome.homelist[index].nearToMe != null ? pHome.homelist[index].nearToMe.round().toString() + ' kms away' : '',
                                                                                style: TextStyle(
                                                                                  color: appwhite,
                                                                                  fontSize: 15,
                                                                                  fontWeight: FontWeight.w700,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          if (pHome.profilesLength > 0 &&
                                              pHome.homelist.length != 0)
                                            Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  15, 10, 15, 10),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      //  width: width * 0.50,
                                                      padding: EdgeInsets.only(
                                                          right: 10),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Material(
                                                            type: MaterialType
                                                                .transparency,
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    pHome
                                                                        .homelist[
                                                                            curr]
                                                                        .name,
                                                                    style:
                                                                        b_15Black(),
                                                                    //     TextStyle(
                                                                    //   color:
                                                                    //       appBlack,
                                                                    //   fontSize: Platform
                                                                    //           .isIOS
                                                                    //       ? 17
                                                                    //       : 15,
                                                                    //   fontWeight:
                                                                    //       FontWeight
                                                                    //           .w800,
                                                                    // ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    softWrap:
                                                                        true,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Text(
                                                            pHome.homelist[curr]
                                                                .job,
                                                            style: n_12grey(),
                                                            // TextStyle(
                                                            //   color: appGrey4,
                                                            //   fontSize:
                                                            //       Platform.isIOS
                                                            //           ? 16
                                                            //           : 14,
                                                            // ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      //width: width / 4,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                controller
                                                                    .triggerLeft();
                                                              });
                                                            },
                                                            child: Container(
                                                              height: 40,
                                                              width: 40,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8),
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border:
                                                                    Border.all(
                                                                  color:
                                                                      // isReject
                                                                      //     ? appRed
                                                                      //     :
                                                                      appLightGrey,
                                                                  width: 2,
                                                                ),
                                                              ),
                                                              child: SvgPicture
                                                                  .asset(
                                                                'assets/images/icons/cancel.svg',
                                                                color:
                                                                    // isReject
                                                                    //     ? appRed
                                                                    //     :
                                                                    appLightGrey,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          GestureDetector(
                                                            onTap: () {
                                                              controller
                                                                  .triggerRight();
                                                            },
                                                            child: Container(
                                                              height: 40,
                                                              width: 40,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(10),
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color:
                                                                    //isAccept
                                                                    //  ? appGreen
                                                                    //:
                                                                    appBlack,
                                                              ),
                                                              child: SvgPicture
                                                                  .asset(
                                                                'assets/images/icons/connect.svg',
                                                                color: appwhite,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          // profileNameSection(pHome, controller),
                                          Divider(),
                                          Column(
                                            children: [
                                              goalsSection(pHome),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              introductionSection(pHome),
                                              Divider(),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              meetingPreferencesSection(pHome),
                                              Divider(),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              educationSection(pHome),
                                              Divider(),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              currentOrganizationSection(pHome),
                                              previousOrganizationSection(pHome)
                                            ],
                                          ),
                                          shareProfile(pHome)
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: width,
                                    height: 15,
                                    color: appBodyGrey,
                                  )
                                ],
                              ),
                            );
                          },
                          cardController: controller = CardController(),
                          swipeUpdateCallback:
                              (DragUpdateDetails details, Alignment align) {
                            /// Get swiping card's alignment
                            if (align.x < -2) {
                              //Card is LEFT swiping
                              setState(() {
                                isReject = true;
                                isAccept = false;
                              });
                            } else if (align.x > 2) {
                              //Card is RIGHT swiping
                              setState(() {
                                isReject = false;
                                isAccept = true;
                              });
                            }
                          },
                          swipeCompleteCallback:
                              (CardSwipeOrientation orientation,
                                  int index) async {
                            // Get orientation & index of swiped card!
                            curr = index;
                            if (orientation == CardSwipeOrientation.RECOVER) {
                              setState(() {
                                isReject = false;
                                isAccept = false;
                              });
                              return;
                            } else if (orientation ==
                                CardSwipeOrientation.RIGHT) {
                              curr = index;
                              final response = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuickConnectScreen(
                                    currentProfile: pHome.homelist[curr].image,
                                    currentName: pHome.homelist[curr].name,
                                    otherMemberId:
                                        pHome.homelist[curr].usermemberid,
                                  ),
                                ),
                              );
                              if (response != null && response) {
                                success(context, "Request Sent");
                              }
                            } else if (orientation ==
                                CardSwipeOrientation.LEFT) {
                              curr = index;
                              if (pHome.profilesLength == 0) {
                                return;
                              } else {
                                curr++;
                              }
                            }

                            setState(() {
                              pHome.profilesLength--;
                              isReject = false;
                              isAccept = false;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
              // ),
            ],
          ),
        );
      }),
    );
  }

  Widget shareButton(HomeModel item) {
    return InkWell(
      onTap: () {
        _share(item.name, item.image);
      },
      child: Container(
        width: 23,
        height: 23,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.5),
          child: SvgPicture.asset('assets/images/icons/share.svg'),
        ),
      ),
    );
  }

  Widget bookmarkButton(HomeModel item) {
    return InkWell(
      onTap: () async {
        if (item.isSaved == true) {
          setState(() {
            item.isSaved = false;
          });
          await removeSavedProfileForLater(item.usermemberid);
        } else {
          setState(() {
            item.isSaved = true;
          });
          await saveProfileForLater(item.usermemberid);
        }
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.zero,
          child: Center(
            child:
                // SvgPicture.asset('assets/images/icons/save.svg',
                //     width: 15, height: 15, color: Colors.white),
                Icon(
              item.isSaved == true ? Icons.bookmark : Icons.bookmark_border,
              size: 23,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  _share(String name, String url) async {
    LoaderOverlay overlay = LoaderOverlay.of(context);
    overlay.show();
    _onImagDownloadButtonPressed(url).then((res) {
      overlay.hide();
      final RenderBox box = context.findRenderObject() as RenderBox;
      String text = Utility.getShareText(name);
      Share.shareFiles(
        ['$res'],
        text: text,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      );
    });
  }

  Future<String> _onImagDownloadButtonPressed(String url) async {
    try {
      var imageId = await ImageDownloader.downloadImage(url);
      if (imageId == null) {
        return "";
      }
      var path = await ImageDownloader.findPath(imageId);
      return path;
    } on PlatformException catch (e) {
      print(e);
      error(context, "error while downloading");
    }
    return "";
  }

  getProfileImage() async {
    prefs = await SharedPreferences.getInstance();
    memberImage = prefs.getString(StorageKeys.MemberProfileImage);
  }

  initialize() async {
    prefs = await SharedPreferences.getInstance();
    memberImage = prefs.getString(StorageKeys.MemberProfileImage);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        int unRead = prefs.getInt('unRead') ?? 0;

        unRead++;

        prefs.setInt('unRead', unRead);
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
    });
    print("hello");
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    //   print('Message data: ${message.data}');

    //   SharedPreferences preferences = await SharedPreferences.getInstance();
    //   int unRead = preferences.getInt('unRead') ?? 0;

    //   unRead++;

    //   preferences.setInt('unRead', unRead);

    //   if (message.notification != null) {
    //     print('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  Widget appBar(HomeProvider pHome) {
    return Stack(
      children: [
        Container(
          //color: Colors.white,
          padding: EdgeInsets.only(left: 10, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  );
                },
                child: CachedNetworkImage(
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                    imageUrl: pHome.memberImage,
                    width: 60,
                    //width*0.15,
                    height: 55,
                    //height*0.09,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: Image.network(Common.DefaultProfileImage))),
              ),
              // Positioned(
              //   top: 0,
              //   right: -15,
              //   child: Container(
              //     height: 18,
              //     width: 18,
              //     margin: EdgeInsets.all(5.0),
              //     decoration: BoxDecoration(
              //         color: Colors.black,
              //         shape: BoxShape.circle
              //     ),
              //     child: Text("30%",style: TextStyle(color: Colors.white,fontSize: 8,fontWeight: FontWeight.w500,),),
              //   ),
              // )
              Container(
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessageScreen(),
                          ),
                        );
                      },
                      child: SvgPicture.asset('assets/images/icons/message.svg',
                          height: 22, width: 22, color: appBlack),
                    ),
                    SizedBox(width: 15),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NotificationScreen()))
                            .then((value) => FirebaseMessaging.onMessage);
                      },
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          SvgPicture.asset(
                              'assets/images/icons/notification.svg',
                              width: 20,
                              height: 20,
                              color: appBlack),
                          // Icon(
                          //   Icons.notifications_none,
                          //   color: Colors.grey.shade800,
                          //   size: 25,
                          // ),
                          StreamBuilder<RemoteMessage>(
                              stream: FirebaseMessaging.onMessage,
                              builder: (ctx,
                                  AsyncSnapshot<RemoteMessage> snapshots) {
                                print("onMessage ${snapshots.hasData}");
                                print("onMessage ${snapshots.connectionState}");
                                print("onMessage ${snapshots.data}");

                                int un =
                                    prefs != null ? prefs.getInt('unRead') : 0;
                                print("unRead in home $un");

                                if (snapshots.hasData) {
                                  return Icon(
                                    Icons.circle,
                                    color: Colors.red,
                                    size: 10,
                                  );
                                } else {
                                  return Icon(
                                    Icons.circle,
                                    color: Colors.transparent,
                                    size: 10,
                                  );
                                }
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        pHome.memberProfilePercentage != null
            ? Positioned(
                top: 8,
                left: 58,
                child: Container(
                  height: 25,
                  width: 25,
                  child: MaterialButton(
                    onPressed: () {},
                    color: Colors.black,
                    textColor: Colors.white,
                    child: pHome.memberProfilePercentage != null
                        ? RichText(
                            text: TextSpan(children: <TextSpan>[
                            TextSpan(
                              text: pHome.memberProfilePercentage.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "%",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ]))
                        : Container(
                            height: 0,
                            width: 0,
                          ),
                    padding: EdgeInsets.all(0),
                    shape: CircleBorder(),
                  ),
                ))
            : Container()
      ],
    );
  }

  Widget goalsSection(HomeProvider pHome) {
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Container(
        decoration: BoxDecoration(
          //    color: appwhite,
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Goals",
                  style: b_15Black(),
                ),
              ],
            ),
            SizedBox(height: 8),
            pHome.homelist[curr].goalList.length != null &&
                    pHome.homelist[curr].goalList.length > 0
                ? Wrap(
                    children: [
                      for (var i = 0;
                          i < pHome.homelist[curr].goalList.length ?? 1;
                          i++)
                        Container(
                          margin: EdgeInsets.all(3),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: appGrey6,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            pHome.homelist[curr].goalList[i].name ?? "",
                            style: bn_12white(),
                          ),
                        ),
                    ],
                  )
                : Text("--"),
          ],
        ),
      ),
    );
  }

  Widget introductionSection(HomeProvider pHome) {
    if (pHome.homelist[curr].introduction != null &&
        pHome.homelist[curr].introduction != '') {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // color: appwhite,
          borderRadius: BorderRadius.circular(5),
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: isReject
          //       ? [Colors.white10, appRedShadow]
          //       : isAccept
          //           ? [Colors.white10, appGreenShadow]
          //           : [Colors.transparent, Colors.transparent],
          // ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Introduction",
                  style: b_15Black(),
                ),
              ],
            ),
            SizedBox(height: 8),
            pHome.homelist[curr].introduction != null &&
                    pHome.homelist[curr].introduction != '' &&
                    pHome.homelist[curr].introduction != "null"
                ? Text(
                    pHome.homelist[curr].introduction.length > 150
                        ? pHome.homelist[curr].introduction.substring(0, 150) +
                            '...'
                        : pHome.homelist[curr].introduction,
                    style: n_12grey(),
                  )
                : Text('--'),
          ],
        ),
      );
    }

    return Container();
  }

  Widget meetingPreferencesSection(HomeProvider pHome) {
    return Container(
      // margin: EdgeInsets.only(top: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: isReject
        //       ? [appLightRed, appRedShadow]
        //       : isAccept
        //           ? [Colors.white10, appGreenShadow]
        //           : [Colors.transparent, Colors.transparent],
        // ),
        // color: appwhite,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        //mainAxisSize: MainAxisSize.min,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "How can we meet",
                style: b_15Black(),
              ),
            ],
          ),
          SizedBox(height: 8),
          pHome.homelist[curr].meetingPreferenceList.length != null &&
                  pHome.homelist[curr].meetingPreferenceList.length > 0
              ? Wrap(
                  spacing: 30,
                  children: List.generate(
                    pHome.homelist[curr].meetingPreferenceList.length,
                    (i) {
                      MeetingPreferenceModel item =
                          pHome.homelist[curr].meetingPreferenceList[i];
                      return Container(
                        margin: EdgeInsets.only(top: 5, bottom: 5),
                        //width: (width - 60) / 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              alignment: Alignment.center,
                              child: Image.network(
                                item.imageName ?? Common.NoImage40,
                                scale: 1.5,
                                color: appBlack,
                              ),
                            ),
                            Text(
                              item.preferenceTypeName,
                              style: n_12black(),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              : Text("--"),
        ],
      ),
    );
  }

  Widget educationSection(HomeProvider pHome) {
    return Container(
      //    margin: EdgeInsets.only(top: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: isReject
        //       ? [Colors.white10, appRedShadow]
        //       : isAccept
        //           ? [Colors.white10, appGreenShadow]
        //           : [Colors.transparent, Colors.transparent],
        // ),
        // color: appwhite,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Education",
                style: b_15Black(),
              ),
            ],
          ),
          pHome.homelist[curr].education != null
              ? Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pHome.homelist[curr].education.city ?? "no data3",
                        style: b_12black(),
                      ),
                      Text(
                        pHome.homelist[curr].education.degree ?? "no data4",
                        style: n_12black(),
                      ),
                      Text(
                        pHome.homelist[curr].education.school ?? "no data4 ",
                        style: n_12grey(),
                      ),
                    ],
                  ),
                )
              : Text("-"),
        ],
      ),
    );
  }

  Widget currentOrganizationSection(HomeProvider pHome) {
    return Container(
      //  margin: EdgeInsets.only(top: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: isReject
        //       ? [Colors.white10, appRedShadow]
        //       : isAccept
        //           ? [Colors.white10, appGreenShadow]
        //           : [Colors.transparent, Colors.transparent],
        // ),
        // color: appwhite,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Current Organization",
                style: b_15Black(),
              ),
            ],
          ),
          SizedBox(height: 8),
          pHome.homelist[curr].currentOrganization != null &&
                  pHome.homelist[curr].job != null
              ? Wrap(
                  children: [
                    Text(
                      pHome.homelist[curr].job,
                      style: n_12grey(),
                    ),
                    if (pHome.homelist[curr].job != '' &&
                        pHome.homelist[curr].currentOrganization != '')
                      Text(
                        " at ",
                        style: n_12grey(),
                      ),
                    Text(
                      pHome.homelist[curr].currentOrganization,
                      style: b_12black(),
                    ),
                  ],
                )
              : Text("--"),
        ],
      ),
    );
    return Container();
  }

  Widget previousOrganizationSection(HomeProvider pHome) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: isReject
        //       ? [Colors.white10, appRedShadow]
        //       : isAccept
        //           ? [Colors.white10, appGreenShadow]
        //           : [Colors.transparent, Colors.transparent],
        // ),
        // color: appwhite,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Previous Organisations",
                style: b_15Black(),
              ),
            ],
          ),
          SizedBox(height: 8),
          pHome.homelist[curr].previousOrganizationList.length > 0
              ? Wrap(
                  children: [
                    Text(
                      pHome.homelist[curr].previousOrganizationList[0]
                              .designation ??
                          "no data",
                      style: n_12grey(),
                    ),
                    if (pHome.homelist[curr].previousOrganizationList[0]
                                .designation !=
                            '' &&
                        pHome.homelist[curr].previousOrganizationList[0]
                                .organizationName !=
                            '')
                      Text(
                        " at ",
                        style: n_12grey(),
                      ),
                    Text(
                      pHome.homelist[curr].previousOrganizationList[0]
                              .organizationName ??
                          "no data2",
                      style: b_12black(),
                    ),
                  ],
                )
              : Text("--")
        ],
      ),
    );
  }

  Widget shareProfile(HomeProvider pHome) {
    return GestureDetector(
      onTap: () {
        _share(pHome.homelist[curr].name, pHome.homelist[curr].image);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Share profile",
                  style: b_15Black(),
                ),
                SizedBox(width: 7),
                Icon(
                  FontAwesomeIcons.share,
                  color: appBlack,
                  size: 20,
                ),
                // SvgPicture.asset(
                //   'assets/images/icons/share.svg',
                //   color: appBlack,
                //   height: 20,
                //   width: 20,
                // )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget imageBottom(double _padding, double _height) {
    return Card(
      elevation: _padding == 0 ? 1 : 2,
      shadowColor: Colors.grey.shade50,
      //color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white, width: 0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.only(left: _padding, right: _padding),
        margin: EdgeInsets.only(left: _padding, right: _padding),
        height: _height,
      ),
    );
  }

  Future<void> getProfile() async {
    prefs = await SharedPreferences.getInstance();
    String memberId = prefs.getString(StorageKeys.MemberId);
    final MyProfile myProfile = await getMemberProfile(memberId);
    profileCompletionPercentage = myProfile.profilePercentage;
    context.read<HomeProvider>().memberProfilePercentage =
        profileCompletionPercentage.toString();
    memberImage = myProfile.profile.imageUrl;
    context.read<HomeProvider>().memberImage = memberImage;
    setState(() {});
  }

  Future<void> _getUserLocation() async {
    Location location = Location();
    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final _locationData = await location.getLocation();
    setState(() {
      _userLocation = _locationData;
      lat = _locationData.latitude.toString();
      lang = _locationData.longitude.toString();
    });
  }
}
