import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/screens/home/quick_connect_screen.dart';
import 'package:emajlis/screens/home/notification_screen.dart';
import 'package:emajlis/providers/home_provider.dart';
import 'package:emajlis/screens/home/search_screen.dart';
import 'package:emajlis/screens/profile/profile_information_screen.dart';
import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:emajlis/widgets/progress.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
  playSound: true,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomeScreen extends StatefulWidget {
  final Function triggerPanel;
  final SlidingUpPanelController panelController;

  HomeScreen({
    this.triggerPanel,
    this.panelController,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  double height;
  double width;
  ScrollController scrollController;
  SharedPreferences prefs;

  int unRead = 0;
  int curr = 0;
  bool isReject = false;
  bool isAccept = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    context.read<HomeProvider>().discover();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    CardController controller; //Use this to trigger swap.

    return Scaffold(
      body: Consumer<HomeProvider>(builder: (context, pHome, child) {
        return SafeArea(
          child: Stack(
            children: [
              Container(
                height: height,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (pHome.isLoadingConnections) circularProgress(),
                    if (!pHome.isLoadingConnections &&
                        pHome.profilesLength == 0)
                      Text(
                        "Oops! No more connections.\nTry again, later.",
                        style: TextStyle(
                          color: appBlack,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (!pHome.isLoadingConnections &&
                        pHome.profilesLength == 0)
                      InkWell(
                        onTap: () {
                          context.read<HomeProvider>().discover();
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
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  child: Image.asset(
                    "assets/images/graphics/elog.png",
                    scale: 1.7,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchScreen(),
                            ),
                          );
                        },
                        child: Container(
                          child: Icon(
                            Icons.search,
                            size: 25,
                            color: appGrey,
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      InkWell(
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                color: Colors.grey,
                                size: 25,
                              ),
                              StreamBuilder<RemoteMessage>(
                                  stream: FirebaseMessaging.onMessage,
                                  builder: (ctx,
                                      AsyncSnapshot<RemoteMessage> snapshots) {
                                    print("onMessage ${snapshots.hasData}");
                                    print(
                                        "onMessage ${snapshots.connectionState}");
                                    print("onMessage ${snapshots.data}");

                                    int un = prefs != null
                                        ? prefs.getInt('unRead')
                                        : 0;
                                    print("unRead in home $un");

                                    if (snapshots.hasData) {
                                      return Icon(
                                        Icons.circle,
                                        color: Colors.red,
                                        size: 10,
                                      );
                                    } else {
                                      return Container();
                                    }
                                  }),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            NotificationScreen()))
                                .then((value) => FirebaseMessaging.onMessage);
                          })
                    ],
                  ),
                ),
              ),
              Stack(
                children: [
                  if (pHome.profilesLength > 0 && pHome.homelist.length != 0)
                    Container(
                      margin: EdgeInsets.only(bottom: height * 0.1),
                      //margin: EdgeInsets.only(bottom: 55),
                      height: height * 8.0,
                      child: new TinderSwapCard(
                        allowVerticalMovement: false,
                        swipeUp: false,
                        swipeDown: false,
                        orientation: AmassOrientation.BOTTOM,
                        totalNum: pHome.homelist.length,
                        stackNum: 3,
                        swipeEdge: 2.0,
                        maxWidth: MediaQuery.of(context).size.width,
                        maxHeight: height * 0.62,
                        minWidth: MediaQuery.of(context).size.width * 0.69,
                        minHeight: height * 0.60,
                        cardBuilder: (context, index) {
                          curr = index;
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 2,
                            shadowColor: Colors.grey[100],
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 5.0,
                                right: 5,
                                top: 5,
                                bottom: 25,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      pHome.homelist[index].image,
                                    ),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xffFFCD07),
                                              Color(0xffE97A18),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                                Common.SecuritySvg),
                                            SizedBox(width: 5),
                                            Text(
                                              pHome.homelist[index].svc +
                                                  ' SVC',
                                              style: TextStyle(
                                                color: appBlack,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 15,
                                      right: 10,
                                      child: Row(
                                        children: [
                                          shareButton(pHome.homelist[index]),
                                          SizedBox(width: 10),
                                          bookmarkButton(pHome.homelist[index]),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      left: 0,
                                      right: 0,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileInformationScreen(
                                                    memberId: pHome
                                                        .homelist[index]
                                                        .usermemberid,
                                                    isFromChatScreen: false,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: 150,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color:
                                                    appBlack.withOpacity(0.8),
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              child: Material(
                                                type: MaterialType.transparency,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'View Profile',
                                                      style: TextStyle(
                                                        color: appwhite,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                          } else if (orientation == CardSwipeOrientation.LEFT) {
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
              if (pHome.profilesLength > 0 && pHome.homelist.length != 0)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    height: height * 0.17,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isReject
                            ? [Colors.white10, appRedShadow]
                            : isAccept
                                ? [Colors.white10, appGreenShadow]
                                : [Colors.transparent, Colors.transparent],
                      ),
                    ),
                  ),
                ),
              if (pHome.profilesLength > 0 && pHome.homelist.length != 0)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, height * 0.032),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: width * 0.55,
                          padding: EdgeInsets.only(right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Material(
                                type: MaterialType.transparency,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        pHome.homelist[curr].name,
                                        style: TextStyle(
                                          color: appBlack,
                                          fontSize: Platform.isIOS ? 17 : 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                pHome.homelist[curr].job,
                                style: TextStyle(
                                  color: appGrey4,
                                  fontSize: Platform.isIOS ? 16 : 14,
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: width / 4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    controller.triggerLeft();
                                  });
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isReject ? appRed : appLightGrey,
                                      width: 2,
                                    ),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/images/icons/clear.svg',
                                    color: isReject ? appRed : appLightGrey,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  controller.triggerRight();
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isAccept ? appGreen : appBlack,
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/images/icons/thumbs-up.svg',
                                    color: appwhite,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
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
        if (item.isSaved == 1) {
          setState(() {
            item.isSaved = 0;
          });
          await removeSavedProfileForLater(item.usermemberid);
        } else {
          setState(() {
            item.isSaved = 1;
          });
          await saveProfileForLater(item.usermemberid);
        }
      },
      child: Container(
        width: 23,
        height: 23,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.zero,
          child: Center(
            child: Icon(
              item.isSaved == 1 ? Icons.bookmark : Icons.bookmark_border,
              size: 21,
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

  initialize() async {
    prefs = await SharedPreferences.getInstance();
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
}
