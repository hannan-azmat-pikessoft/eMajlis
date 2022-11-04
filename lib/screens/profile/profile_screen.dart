import 'package:cached_network_image/cached_network_image.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/main.dart';
import 'package:emajlis/models/my_profile_model.dart';
import 'package:emajlis/models/organization_model.dart';
import 'package:emajlis/models/svc_score_model.dart';
import 'package:emajlis/providers/appointment_provider.dart';
import 'package:emajlis/providers/connection_provider.dart';
import 'package:emajlis/screens/authentication/login_screen.dart';
import 'package:emajlis/screens/connections/only_connections_screen.dart';
import 'package:emajlis/screens/home/dashboard_screen.dart';
import 'package:emajlis/screens/profile/meeting_preferences_screen.dart';
import 'package:emajlis/screens/profile/current_organization_screen.dart';
import 'package:emajlis/screens/profile/education_screen.dart';
import 'package:emajlis/screens/profile/goals_screen.dart';
import 'package:emajlis/screens/profile/raise_an_issue_screen.dart';
import 'package:emajlis/screens/profile/work_industry_screen.dart';
import 'package:emajlis/screens/profile/interested_industry_screen.dart';
import 'package:emajlis/screens/profile/previous_organization_screen.dart';
import 'package:emajlis/screens/profile/profile_edit_screen.dart';
import 'package:emajlis/screens/profile/social_links_screen.dart';
import 'package:emajlis/services/authentication_service.dart';
import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/services/svc_service.dart';
import 'package:emajlis/utlis/animated_flip_counter.dart';
import 'package:emajlis/utlis/flutter_device_type.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/textinput.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'blocked_users_screen.dart';
import 'saved_profile_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:countup/countup.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

GoogleSignIn _googleSignIn = GoogleSignIn();

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TabController _tabController;
  SharedPreferences pref;
  LoaderOverlay overlay;
  double height;
  double width;

  List<Tab> profileTabs = <Tab>[
    Tab(child: Text("About")),
    Tab(child: Text("Goals")),
    Tab(child: Text("Education")),
    Tab(child: Text("Interests")),
    Tab(child: Text("Organization")),
  ];
  int currentIndex = 0;
  bool hideEditBtn = true;
  bool isPrivate = false;
  MyProfile myprofile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: profileTabs.length, vsync: this);
    Future.delayed(Duration.zero, () {
      initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    this.height = MediaQuery.of(context).size.height;
    this.width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: appBodyGrey,
      appBar: simpleAppbar(
        context,
        titleText: "Back",
        //"Profile",
        isNavBack: false,
        isBackText: true,
        //false,
        actions: [
          GestureDetector(
            onTap: () {
              openBottomModal(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset('assets/images/icons/menu.svg'),
            ),
          ),
          SizedBox(width: 30),
        ],
      ),
      body: RefreshIndicator(
        color: appBlack,
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: myprofile != null
                ? Column(
                    children: [
                      topProfileSection(),
                      peopleInNetworkSection(),
                      progressAndUpdate(),
                      progressBar(),
                      profileTabsHeader(),
                      profileTabsSection(),
                    ],
                  )
                : Container(),
          ),
        ),
      ),
    );
  }

  Widget topProfileSection() {
    return Container(
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 5 + (height * 0.11),
            ),
            decoration: BoxDecoration(
              color: appwhite,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 5 + (height * 0.11)),
                Text(
                  myprofile.profile.firstname == ""
                      ? 'No name'
                      : myprofile.profile.firstname,
                  style: TextStyle(
                    color: appBlack,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  myprofile.profile.profession == ""
                      ? "No Profession"
                      : myprofile.profile.profession,
                  style: TextStyle(
                    color: appGrey4,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: width / 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showSVCPopup();
                      },
                      child: Container(
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
                              myprofile.profile.svc + ' SVC',
                              style: TextStyle(
                                color: appBlack,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Tooltip(
                      message: "svc message",
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                        child: Icon(
                          Icons.info_outline,
                          size: 15,
                          color: appgreydate,
                        ),
                      ),
                      showDuration: Duration(seconds: 2),
                      verticalOffset: 20.0,
                    ),
                  ],
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
          Positioned(
            top: height * 0.19,
            right: 30,
            child: hideEditBtn
                ? Container()
                : InkWell(
                    onTap: () async {
                      final response = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileEditScreen(
                            profileData: myprofile.profile,
                          ),
                        ),
                      );
                      if (response != null) {
                        success(context, "Profile updated");
                        setState(() {
                          myprofile.profile = response;
                          onProfileUpdate();
                        });
                      }
                    },
                    child: Icon(Icons.edit_outlined),
                  ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 5,
            child: Center(
              child: Container(
                height: height * 0.22,
                width: height * 0.22,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(blurRadius: 5, color: Colors.grey[300])
                  ],
                  shape: BoxShape.circle,
                  color: appgreydate,
                ),
                child: CachedNetworkImage(
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(height / 5.6 * 2),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  imageUrl:
                      myprofile.profile.imageUrl ?? Common.DefaultProfileImage,
                  width: height / 5.6 * 2,
                  height: height / 5.6 * 2,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                    value: downloadProgress.progress,
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  showSVCPopup() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: FutureBuilder(
            future: SVCService.getSVCScore(myprofile.profile.id),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.black),
                  ),
                );
              } else if (snap.hasData) {
                SVCScoreModelClass score = snap.data;
                if (score != null && score.status)
                  return Column(
                    children: [
                      Row(
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
                                  score.result == null
                                      ? '0'
                                      : score.result.svc[0].creditScore +
                                          ' SVC',
                                  style: TextStyle(
                                    color: appBlack,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (score.status != false)
                        Wrap(
                          children: score.result.upvoteScore
                              .map((e) => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(e.levelNameEn, style: b_12black()),
                                      Container(
                                        alignment: Alignment.center,
                                        margin:
                                            EdgeInsets.symmetric(vertical: 6.0),
                                        padding: EdgeInsets.all(6.0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: appBlack,
                                        ),
                                        child: Center(
                                          child: Text(
                                            e.upvotes,
                                            style: b_12white(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ))
                              .toList(),
                        ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          primary: Colors.black,
                          padding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 41),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 12,
                            color: appwhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  );
                return Center(child: Text('No SVC score', style: b_12black()));
              } else {
                return Center(
                  child: Text('Please try again', style: b_12black()),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget peopleInNetworkSection() {
    return Consumer<ConnectionProvider>(builder: (context, connection, child) {
      return Container(
        margin: EdgeInsets.all(20),
        width: width,
        child: connection.friendList.isEmpty
            ? Center(
                child: InkWell(
                  onTap: () {
                    goToDashboardScreen();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: appwhite,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      "+ Add people to your network",
                      style: b_14black(),
                    ),
                  ),
                ),
              )
            : InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'People \nin network',
                      style: TextStyle(
                        color: appBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Wrap(
                      children: connection.friendList
                          .sublist(
                              0,
                              connection.friendList.length > 3
                                  ? 3
                                  : connection.friendList.length)
                          .map((e) => Container(
                                margin:
                                    const EdgeInsets.only(left: 5, right: 5),
                                height: 40,
                                width: 40,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Image.network(
                                  e.imageUrl ?? Common.NoImage150,
                                  fit: BoxFit.cover,
                                ),
                              ))
                          .toList(),
                    ),
                    if (connection.friendList.length > 3)
                      Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(left: 5, right: 10),
                        decoration: BoxDecoration(
                          color: appwhite,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          "+" + '${connection.friendList.length - 3}',
                          style: TextStyle(
                            color: appBlack,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OnlyConnectionsScreen(
                        memberId: pref.getString(StorageKeys.MemberId),
                        isFromMyProfile: true,
                        connectionList: connection.friendList,
                      ),
                    ),
                  ).then((value) async => {
                        await context
                            .read<ConnectionProvider>()
                            .loadConnections()
                      });
                },
              ),
      );
    });
  }

  Widget progressAndUpdate() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    child: Countup(
                      begin:myprofile.profilePercentage!=null &&myprofile.profilePercentage>=20? myprofile.profilePercentage.toDouble()-20:0,
                      end: myprofile.profilePercentage.toDouble(),
                      duration: Duration(seconds: 2),
                      curve: Curves.ease,
                      separator: ',',
                      style: TextStyle(
                        fontSize: 50,
                        color: appBlack,
                        fontFamily: 'Aeonik',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // child: AnimatedFlipCounter(
                    //   value: myprofile.profilePercentage.toDouble(),
                    //   duration: Duration(seconds: 2),
                    //   curve: Curves.ease,
                    //   textStyle: TextStyle(
                    //     fontSize: 51,
                    //     color: appBlack,
                    //     fontFamily: 'Aeonik',
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      "%",
                      style: TextStyle(
                        color: appBlack,
                        fontSize: 27,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Profile progress',
                    style: TextStyle(
                      color: appBlack,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Tooltip(
                    message: "svc message svc message",
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                      child: Icon(
                        Icons.info_outline,
                        size: 15,
                        color: appgreydate,
                      ),
                    ),
                    showDuration: Duration(seconds: 2),
                    verticalOffset: 20.0,
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                hideEditBtn = !hideEditBtn;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              decoration: BoxDecoration(
                color: appBlack,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'Update Profile',
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
    );
  }

  Widget progressBar() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: new LinearPercentIndicator(
          width: MediaQuery.of(context).size.width - 50,
          animation: true,
          lineHeight: 20.0,
          animationDuration: 2000,
          backgroundColor: Colors.transparent,
          percent: myprofile.profilePercentage / 100,
          linearStrokeCap: LinearStrokeCap.roundAll,
          linearGradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0.25, 0.6],
            colors: [appGrey, appMustard],
          ),
        ),
      ),
    );
  }

  Widget profileTabsHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      height: 35,
      decoration: BoxDecoration(
        color: appwhite,
        borderRadius: BorderRadius.circular(17),
      ),
      child: TabBar(
        isScrollable: true,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        labelStyle: TextStyle(
          color: appwhite,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          color: appGrey4,
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: new BubbleTabIndicator(
          indicatorRadius: 30,
          indicatorHeight: 30.0,
          indicatorColor: appBlack,
          tabBarIndicatorSize: TabBarIndicatorSize.tab,
        ),
        unselectedLabelColor: appGrey4,
        labelColor: appwhite,
        controller: _tabController,
        tabs: profileTabs,
      ),
    );
  }

  Widget profileTabsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: Container(
        height: width * 0.5,
        width: double.infinity,
        child: TabBarView(
          controller: _tabController,
          children: [
            socialLinksSection(),
            goalsSection(),
            educationSection(),
            interestsSection(),
            organizationSection(),
          ],
        ),
      ),
    );
  }

  Widget socialLinksSection() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Container(
          //   width: double.infinity,
          //   decoration: BoxDecoration(
          //     color: appwhite,
          //     borderRadius: BorderRadius.circular(5),
          //   ),
          //   padding: EdgeInsets.all(10),
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         "Introduction",
          //         style: b_14black(),
          //       ),
          //       SizedBox(height: 5),
          //       Text(
          //         myprofile.profile.introduction == null
          //             ? "Add your introduction, it will help other to connect with you."
          //             : myprofile.profile.introduction,
          //         style: n_12grey(),
          //       ),
          //     ],
          //   ),
          // ),
          SizedBox(height: 15),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: appwhite,
              borderRadius: BorderRadius.circular(5),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Website link",
                      style: b_14black(),
                    ),
                    if (!hideEditBtn)
                      InkWell(
                        onTap: () async {
                          final response = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SocialLinksScreen(
                                socialLinks: myprofile.socialLinks,
                              ),
                            ),
                          );
                          if (response != null) {
                            success(context, "Social Links Saved");
                            setState(() {
                              myprofile.socialLinks = response;
                            });
                          }
                        },
                        child: Icon(Icons.edit_outlined),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                (
                    // myprofile.socialLinks.twitter != "" ||
                    //     myprofile.socialLinks.instagram != "" ||
                    //     myprofile.socialLinks.linkedin != "" ||
                    //     myprofile.socialLinks.facebook != ""
                    myprofile.socialLinks.website != ""
                )
                    ? Row(
                        children: [
                          // socialItem(
                          //   myprofile.socialLinks.twitter,
                          //   Common.TwitterSvg,
                          //   "https://www.twitter.com/",
                          // ),
                          // socialItem(
                          //   myprofile.socialLinks.instagram,
                          //   Common.InstagramSvg,
                          //   "https://www.instagram.com/",
                          // ),
                          // socialItem(
                          //   myprofile.socialLinks.linkedin,
                          //   Common.LinkedinSvg,
                          //   "https://www.linkedin.com/in/",
                          // ),
                          // socialItem(
                          //   myprofile.socialLinks.facebook,
                          //   Common.FacebookSvg,
                          //   "https://www.facebook.com/",
                          // ),
                          socialItem(
                            myprofile.socialLinks.website,
                            "",
                            "https://",
                          ),
                        ],
                      )
                    : Text(
                        "Connect your social media links",
                        style: n_12grey(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget socialItem(String link, String imageUrl, String baseUrl) {
    final newLink = link.replaceAll("@", '');
    if (newLink != "") {
      return InkWell(
        onTap: () {
          openUrl(baseUrl + newLink + '/');
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 13, 5),
          child: imageUrl == ""
              ? Icon(Icons.language_sharp)
              : SvgPicture.asset(imageUrl),
        ),
      );
    }
    return Container();
  }

  Widget goalsSection() {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: appwhite,
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Goals & Objectives",
                  style: b_14black(),
                ),
                if (!hideEditBtn)
                  InkWell(
                    onTap: () async {
                      final response = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GoalsScreen(
                            myGoalList: myprofile.goalList,
                          ),
                        ),
                      );
                      if (response != null) {
                        success(context, 'Goals Saved');
                        setState(() {
                          myprofile.goalList = response;
                          onProfileUpdate();
                        });
                      }
                    },
                    child: Icon(Icons.edit_outlined),
                  ),
              ],
            ),
            SizedBox(height: 8),
            if (myprofile.goalList.length == 0)
              Text(
                "Add your goals & objectives",
                style: n_12grey(),
              )
            else
              Wrap(
                children: [
                  for (var i = 0; i < myprofile.goalList.length ?? 1; i++)
                    Container(
                      margin: EdgeInsets.all(3),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: appGrey6,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        myprofile.goalList[i].name ?? "",
                        style: n_10white(),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget educationSection() {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: appwhite,
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Education",
                  style: b_14black(),
                ),
                if (!hideEditBtn)
                  InkWell(
                    onTap: () async {
                      final response = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EducationScreen(
                            education: myprofile.education,
                          ),
                        ),
                      );
                      if (response != null) {
                        success(context, 'Education Saved');
                        setState(() {
                          myprofile.education = response;
                          onProfileUpdate();
                        });
                      }
                    },
                    child: Icon(Icons.edit_outlined),
                  ),
              ],
            ),
            if (myprofile.education == null)
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Add your education qualifications",
                  style: n_12grey(),
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      myprofile.education.city ?? " ",
                      style: b_12black(),
                    ),
                    Text(
                      myprofile.education.degree ?? " ",
                      style: n_12black(),
                    ),
                    Text(
                      myprofile.education.school ?? " ",
                      style: n_12grey(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget interestsSection() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: appwhite,
              borderRadius: BorderRadius.circular(5),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My Industry",
                      style: b_14black(),
                    ),
                    if (!hideEditBtn)
                      InkWell(
                        onTap: () async {
                          final response = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkIndustryScreen(
                                workIndustry: myprofile.workIndustry,
                              ),
                            ),
                          );
                          if (response != null) {
                            success(context, "Industry Saved");
                            setState(() {
                              myprofile.workIndustry = response;
                              onProfileUpdate();
                            });
                          }
                        },
                        child: Icon(Icons.edit_outlined),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  myprofile.workIndustry.name ?? "What's your field?",
                  style: n_12grey(),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          interestedIndustriesSection(),
          SizedBox(height: 15),
          meetingPreferencesSection(),
        ],
      ),
    );
  }

  Widget meetingPreferencesSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: appwhite,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Meeting Preferences",
                style: b_14black(),
              ),
              if (!hideEditBtn)
                InkWell(
                  onTap: () async {
                    final response = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MeetingPreferencesScreen(
                          myPreferenceList: myprofile.meetingPreferenceList,
                        ),
                      ),
                    );
                    if (response != null) {
                      success(context, "Favorite ways to meet saved");
                      setState(() {
                        myprofile.meetingPreferenceList = response;
                        onProfileUpdate();
                      });
                    }
                  },
                  child: Icon(Icons.edit_outlined),
                ),
            ],
          ),
          SizedBox(height: 8),
          if (myprofile.meetingPreferenceList.isEmpty)
            Text(
              "How & when do you like to meet?",
              style: n_12grey(),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                myprofile.meetingPreferenceList.length,
                (i) {
                  return Container(
                    margin: EdgeInsets.only(top: 5, bottom: 5),
                    width: (width - 80) / 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          child: Image.network(
                            myprofile.meetingPreferenceList[i].imageName ??
                                Common.NoImage40,
                            scale: 1.5,
                            color: appBlack,
                          ),
                        ),
                        Text(
                          myprofile.meetingPreferenceList[i]
                                  .preferenceTypeName ??
                              "",
                          style: b_12black(),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget interestedIndustriesSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: appwhite,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Interested Industries",
                style: b_14black(),
              ),
              if (!hideEditBtn)
                InkWell(
                  onTap: () async {
                    final response = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InterestedIndustryScreen(
                          myIndustryList: myprofile.interestedIndustryList,
                        ),
                      ),
                    );
                    if (response != null) {
                      success(context, "Interested Industries Saved");
                      myprofile.interestedIndustryList = response;
                      onProfileUpdate();
                    }
                  },
                  child: Icon(Icons.edit_outlined),
                ),
            ],
          ),
          SizedBox(height: 8),
          if (myprofile.interestedIndustryList.isEmpty)
            Text(
              "Your interested fields",
              style: n_12grey(),
            )
          else
            Wrap(
              children: [
                for (var i = 0;
                    i < myprofile.interestedIndustryList.length ?? 1;
                    i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      myprofile.interestedIndustryList[i].name,
                      style: n_12grey(),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget organizationSection() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: appwhite,
              borderRadius: BorderRadius.circular(5),
            ),
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Current Organisation",
                      style: b_14black(),
                    ),
                    if (!hideEditBtn)
                      InkWell(
                        onTap: () {
                          goToCurrentOrganizationScreen();
                        },
                        child: Icon(Icons.edit_outlined),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                if (myprofile.profile.currentOrganization != null &&
                    myprofile.profile.profession != null)
                  Wrap(
                    children: [
                      Text(
                        myprofile.profile.profession ?? "Add you Profession",
                        style: n_12grey(),
                      ),
                      Text(
                        " at ",
                        style: n_12grey(),
                      ),
                      if (myprofile.profile.currentOrganization == "")
                        InkWell(
                          onTap: () {
                            goToCurrentOrganizationScreen();
                          },
                          child: Text(
                            "Add you organization",
                            style: b_12black(),
                          ),
                        )
                      else
                        Text(
                          myprofile.profile.currentOrganization ?? "not added",
                          style: b_12black(),
                        ),
                    ],
                  )
                else
                  Text(
                    "Add your work history",
                    style: n_12grey(),
                  ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: appwhite,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Previous Organisation",
                      style: b_14black(),
                    ),
                    if (!hideEditBtn)
                      InkWell(
                        onTap: () async {
                          final response = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PreviousOrganizationScreen(
                                organization:
                                    myprofile.organizationList.length > 0
                                        ? myprofile.organizationList[0]
                                        : new OrganizationModel(
                                            id: 0,
                                            designation: '',
                                            organizationName: '',
                                          ),
                              ),
                            ),
                          );
                          if (response != null) {
                            success(context, "Previous Organisation Saved");
                            setState(() {
                              if (myprofile.organizationList.length > 0) {
                                myprofile.organizationList[0].designation =
                                    response.designation;
                                myprofile.organizationList[0].organizationName =
                                    response.organizationName;
                              } else {
                                myprofile.organizationList.add(response);
                              }
                              onProfileUpdate();
                            });
                          }
                        },
                        child: Icon(Icons.edit_outlined),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                if (myprofile.organizationList.length > 0)
                  Wrap(
                    children: [
                      Text(
                        myprofile.organizationList[0].designation ?? "",
                        style: n_12grey(),
                      ),
                      if (myprofile.organizationList[0].designation != '' &&
                          myprofile.organizationList[0].organizationName != '')
                        Text(
                          " at ",
                          style: n_12grey(),
                        ),
                      Text(
                        myprofile.organizationList[0].organizationName ?? "",
                        style: b_12black(),
                      ),
                    ],
                  )
                else
                  Text(
                    "add your work history",
                    style: n_12grey(),
                  ),
              ],
            ),
          ),
        ],
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
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: width,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: appBlack,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: width * 0.4),
                ),
                ListTile(
                  title: Text("Saved", style: b_15Black()),
                  leading: Icon(Icons.save_alt, color: appBlack, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SavedProfileScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 0.1,
                  child: Container(color: appBlack),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlockedUsersScreen(),
                      ),
                    );
                  },
                  title: Text("Blocked users", style: b_15Black()),
                  leading: Icon(
                    Icons.block_outlined,
                    color: appBlack,
                    size: 18,
                  ),
                ),
                SizedBox(
                  height: 0.1,
                  child: Container(color: appBlack),
                ),
                ListTile(
                  onTap: () async {
                    final response = await makeProfilePrivate(
                      isPrivate ? 0 : 1,
                    );
                    if (response != '') {
                      setState(() {
                        isPrivate = !isPrivate;
                      });
                      Navigator.pop(context);
                      success(context, response);
                    } else {
                      somethingWentWrong(context);
                    }
                  },
                  title: Row(
                    children: [
                      Text("Make profile ", style: b_15Black()),
                      Text(
                        isPrivate ? "public" : "private",
                        style: b_15Black(),
                      ),
                    ],
                  ),
                  leading: Icon(
                    Icons.privacy_tip_outlined,
                    color: appBlack,
                    size: 18,
                  ),
                ),
                SizedBox(
                  height: 0.1,
                  child: Container(color: appBlack),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RaiseAnIssueScreen(),
                      ),
                    );
                  },
                  title: Text("Raise an Issue", style: b_15Black()),
                  leading: Icon(
                    Icons.question_answer_outlined,
                    color: appBlack,
                    size: 18,
                  ),
                ),
                SizedBox(
                  height: 0.1,
                  child: Container(color: appBlack),
                ),
                ListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Form(
                          key: formkey,
                          child: StatefulBuilder(builder: (
                            context,
                            StateSetter setState,
                          ) {
                            return AlertDialog(
                              title: Text(
                                "Are you absolutely sure?",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "I understand the consequences of deleting this account.",
                                    style: n_14grey(),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        "Please type ",
                                        style: n_14grey(),
                                      ),
                                      Text(
                                        "DELETE",
                                        style: b_15Black(),
                                      ),
                                      Text(
                                        " to confirm.",
                                        style: n_14grey(),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  TextFormField(
                                    cursorColor: appBlack,
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp("[A-Z]")),
                                    ],
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: inputDecoration3(),
                                    validator: (val) {
                                      String d = "DELETE";
                                      if (val.trim().isEmpty) {
                                        return "Can't be empty";
                                      } else if (val.trim().toUpperCase() !=
                                          d.toUpperCase()) {
                                        return "Type 'DELETE'";
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          if (formkey.currentState.validate()) {
                                            final isSuccess =
                                                await deleteMember();
                                            if (isSuccess) {
                                              logout();
                                            } else {
                                              somethingWentWrong(context);
                                            }
                                          }
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 120,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: appBlack,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            'Delete',
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
                                          width: 120,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: appBlack),
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                                color: appBlack, fontSize: 14),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            );
                          }),
                        );
                      },
                    );
                  },
                  title: Text("Delete account", style: b_15Black()),
                  leading:
                      Icon(Icons.delete_forever, color: appBlack, size: 18),
                ),
                SizedBox(
                  height: 0.1,
                  child: Container(color: appBlack),
                ),
                ListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            "Do you want to log out ?",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          actions: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        FirebaseMessaging _messaging =
                                            FirebaseMessaging.instance;
                                        bool isLoggedOut = await logoutUser(
                                            await _messaging.getToken());
                                        if (isLoggedOut) {
                                          logout();
                                        }
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 120,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: appBlack,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          'Accept',
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
                                        width: 120,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: appBlack),
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: appBlack, fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ]),
                            )
                          ],
                        );
                      },
                    );
                  },
                  title: Text("Log out", style: b_15Black()),
                  leading: Icon(Icons.logout, color: appBlack, size: 18),
                ),
                if (Device.get().hasNotch) ...[
                  SizedBox(
                    height: 20,
                  )
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> initialize() async {
    pref = await SharedPreferences.getInstance();
    overlay = LoaderOverlay.of(context);
    final xProfile = MyApp.getMyProfile(context);
    if (xProfile != null) {
      setState(() {
        myprofile = xProfile;
      });
    }
    if (xProfile == null) {
      loadData(true);
    } else {
      loadData(false);
    }
  }

  Future<void> loadData(bool showLoader) async {
    if (showLoader) {
      overlay.show();
    }
    await loadMyProfile();
    if (showLoader) {
      overlay.hide();
    }
  }

  Future<void> onRefresh() async {
    await context.read<ConnectionProvider>().loadConnections();
    loadData(true);
  }

  Future<void> loadMyProfile() async {
    final response = await getMyProfile();
    setState(() {
      myprofile = response;
      MyApp.setMyProfile(context, myprofile);
    });
  }

  void logout() {
    pref.remove(StorageKeys.MemberId);
    pref.remove(StorageKeys.MemberProfileImage);
    pref.remove(StorageKeys.EncryptedToken);
    MyApp.setMyProfile(context, null);
    pref.clear();
    context.read<AppointmentProvider>().logout();
    _googleSignIn.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> openUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      error(context, "Invalid link");
    }
  }

  void goToDashboardScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          screenIndex: 0,
          id: -1,
        ),
      ),
      (route) => false,
    );
  }

  Future<void> goToCurrentOrganizationScreen() async {
    final response = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrentOrganizationScreen(
          currentOccupation: myprofile.profile.profession,
          currentOrganization: myprofile.profile.currentOrganization,
        ),
      ),
    );
    if (response != null) {
      success(context, "Current Organisation Saved");
      setState(() {
        myprofile.profile.profession = response.designation;
        myprofile.profile.currentOrganization = response.organizationName;
        onProfileUpdate();
      });
    }
  }

  void onProfileUpdate() {
    setState(() {
      myprofile = updateCompletionPercentage(myprofile);
      MyApp.setMyProfile(context, myprofile);
    });
  }
}
