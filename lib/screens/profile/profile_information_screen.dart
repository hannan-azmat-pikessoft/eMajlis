import 'package:cached_network_image/cached_network_image.dart';
import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/models/meeting_preference_model.dart';
import 'package:emajlis/models/member_model.dart';
import 'package:emajlis/models/my_profile_model.dart';
import 'package:emajlis/providers/connection_provider.dart';
import 'package:emajlis/screens/connections/only_connections_screen.dart';
import 'package:emajlis/screens/home/dashboard_screen.dart';
import 'package:emajlis/screens/home/quick_connect_screen.dart';
import 'package:emajlis/services/message_api.dart';
import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/textinput.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class ProfileInformationScreen extends StatefulWidget {
  final bool isFromChatScreen;
  final String memberId;

  const ProfileInformationScreen({
    this.isFromChatScreen,
    this.memberId,
  });

  @override
  _ProfileInformationScreenState createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen> {
  ConnectionProvider pConnection;
  SharedPreferences pref;
  LoaderOverlay overlay;
  double height;
  double width;

  TextEditingController textController = TextEditingController();
  MyProfile memberProfile;
  List<MemberModel> connectionList = [];
  String path;

  @override
  void initState() {
    super.initState();
    pConnection = context.read<ConnectionProvider>();
    Future.delayed(Duration.zero, () {
      loadData();
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: appBodyGrey,
      appBar: simpleAppbar(
        context,
        titleText: "Profile",
        actions: [
          if (memberProfile != null)
            GestureDetector(
              onTap: () {
                openDotsBottomModal();
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
        onRefresh: () => onRefresh(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: memberProfile != null
                ? Column(
                    children: [
                      topProfileSection(),
                      peopleInNetworkSection(),
                      SizedBox(height: 15),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            introductionSection(),
                            goalsSection(),
                            intrestedIndustrySection(),
                            workIndustrySection(),
                            meetingPreferencesSection(),
                            currentOrganizationSection(),
                            previousOrganizationSection(),
                            educationSection(),
                            socialLinksSection(),
                          ],
                        ),
                      ),
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
            // height: width * 0.55,
            margin: EdgeInsets.only(
              left: 20,
              right: 20,
              top: height * 0.15,
            ),
            decoration: BoxDecoration(
              color: appwhite,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: (height * 0.23) / 2),
                Text(
                  memberProfile.profile.firstname == ""
                      ? 'No name'
                      : memberProfile.profile.firstname,
                  style: TextStyle(
                    color: appBlack,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                memberProfile.profile.profession == ""
                    ? Text(
                        "No Profession",
                        style: TextStyle(
                          color: appGrey4,
                          fontSize: 14,
                        ),
                      )
                    : Text(
                        memberProfile.profile.profession,
                        style: TextStyle(
                          color: appGrey4,
                          fontSize: 10,
                        ),
                      ),
                SizedBox(height: width / 40),
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
                            memberProfile.profile.svc + ' SVC',
                            style: TextStyle(
                              color: appBlack,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: width / 40),
                    InkWell(
                      onTap: () {},
                      child: Icon(
                        Icons.info_outline,
                        size: 15,
                        color: appgreydate,
                      ),
                    )
                  ],
                ),
                Divider(
                  color: appGrey4,
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (memberProfile.profile.isRequestSent == 2) ...[
                      messageButton(),
                      calendarButton(),
                      connectedButton(),
                    ],
                    if (memberProfile.profile.isRequestSent == 1) ...[
                      cancelRequestButton(),
                    ],
                    if (memberProfile.profile.isRequestSent == 0)
                      connectButton(),
                  ],
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 5,
            child: Center(
              child: Container(
                height: height * 0.23,
                width: height * 0.23,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appgreydate,
                ),
                child: CachedNetworkImage(
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(height / 5.5 * 2),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  imageUrl: memberProfile.profile.imageUrl,
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

  Widget peopleInNetworkSection() {
    if (connectionList.length > 0) {
      return Container(
        margin: EdgeInsets.only(top: 15),
        width: width,
        child: InkWell(
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
                children: connectionList
                    .sublist(0,
                        connectionList.length > 3 ? 3 : connectionList.length)
                    .map((e) => Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
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
              if (connectionList.length > 3)
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
                    "+" + '${connectionList.length - 3}',
                    style: TextStyle(
                      color: appBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OnlyConnectionsScreen(
                  memberId: widget.memberId,
                  isFromMyProfile: true,
                  connectionList: connectionList,
                ),
              ),
            );
          },
        ),
      );
    }
    return Container(
      margin: EdgeInsets.all(0),
      width: width,
      child: Container(),
    );
  }

  Widget introductionSection() {
    if (memberProfile.profile.introduction != null &&
        memberProfile.profile.introduction != '') {
      return Container(
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
                  "Introduction",
                  style: b_14black(),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              memberProfile.profile.introduction.length > 150
                  ? memberProfile.profile.introduction.substring(0, 150) + '...'
                  : memberProfile.profile.introduction,
              style: n_12grey(),
            ),
          ],
        ),
      );
    }

    return Container();
  }

  Widget goalsSection() {
    if (memberProfile.goalList.length > 0) {
      return Container(
        margin: EdgeInsets.only(top: 15),
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
              ],
            ),
            SizedBox(height: 8),
            Wrap(
              children: [
                for (var i = 0; i < memberProfile.goalList.length; i++)
                  Container(
                    margin: EdgeInsets.all(3),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: appGrey6,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      memberProfile.goalList[i].name,
                      style: n_10white(),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }
    return Container();
  }

  Widget intrestedIndustrySection() {
    if (memberProfile.interestedIndustryList.length > 0) {
      return Container(
        margin: EdgeInsets.only(top: 15),
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
                  "Interested Industries",
                  style: b_14black(),
                ),
              ],
            ),
            SizedBox(height: 8),
            Wrap(
              children: [
                for (var i = 0;
                    i < memberProfile.interestedIndustryList.length;
                    i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      memberProfile.interestedIndustryList[i].name,
                      style: n_12grey(),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    return Container();
  }

  Widget workIndustrySection() {
    if (memberProfile.workIndustry != null &&
        memberProfile.workIndustry.name != null) {
      return Container(
        margin: EdgeInsets.only(top: 15),
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
              ],
            ),
            SizedBox(height: 8),
            Text(
              memberProfile.workIndustry.name ?? "What's your field?",
              style: n_12grey(),
            ),
          ],
        ),
      );
    }
    return Container();
  }

  Widget meetingPreferencesSection() {
    if (memberProfile.meetingPreferenceList.length > 0) {
      return Container(
        margin: EdgeInsets.only(top: 15),
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
                  "Meeting Preferences",
                  style: b_14black(),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                memberProfile.meetingPreferenceList.length,
                (i) {
                  MeetingPreferenceModel item =
                      memberProfile.meetingPreferenceList[i];
                  return Container(
                    margin: EdgeInsets.only(top: 5, bottom: 5),
                    width: (width - 60) / 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          child: Image.network(
                            item.imageName ?? Common.NoImage40,
                            scale: 1.5,
                            color: appBlack,
                          ),
                        ),
                        Text(
                          item.preferenceTypeName,
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
    return Container();
  }

  Widget currentOrganizationSection() {
    if (memberProfile.profile.currentOrganization != null &&
        memberProfile.profile.profession != null) {
      return Container(
        margin: EdgeInsets.only(top: 15),
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
                  "Current Organization",
                  style: b_14black(),
                ),
              ],
            ),
            SizedBox(height: 8),
            Wrap(
              children: [
                Text(
                  memberProfile.profile.profession,
                  style: n_12grey(),
                ),
                if (memberProfile.profile.profession != '' &&
                    memberProfile.profile.currentOrganization != '')
                  Text(
                    " at ",
                    style: n_12grey(),
                  ),
                Text(
                  memberProfile.profile.currentOrganization,
                  style: b_12black(),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return Container();
  }

  Widget previousOrganizationSection() {
    if (memberProfile.organizationList.length > 0) {
      return Container(
        margin: EdgeInsets.only(top: 15),
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
                  "Previous Organisation",
                  style: b_14black(),
                ),
              ],
            ),
            Wrap(
              children: [
                Text(
                  memberProfile.organizationList[0].designation ?? "no data",
                  style: n_12grey(),
                ),
                if (memberProfile.organizationList[0].designation != '' &&
                    memberProfile.organizationList[0].organizationName != '')
                  Text(
                    " at ",
                    style: n_12grey(),
                  ),
                Text(
                  memberProfile.organizationList[0].organizationName ??
                      "no data2",
                  style: b_12black(),
                ),
              ],
            )
          ],
        ),
      );
    }
    return Container();
  }

  Widget educationSection() {
    if (memberProfile.education != null) {
      return Container(
        margin: EdgeInsets.only(top: 15),
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
                  "Education",
                  style: b_14black(),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memberProfile.education.city ?? "no data3",
                    style: b_12black(),
                  ),
                  Text(
                    memberProfile.education.degree ?? "no data4",
                    style: n_12black(),
                  ),
                  Text(
                    memberProfile.education.school ?? "no data4 ",
                    style: n_12grey(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Container();
  }

  Widget socialLinksSection() {
    if (memberProfile.socialLinks.twitter != "" ||
        memberProfile.socialLinks.instagram != "" ||
        memberProfile.socialLinks.website != "" ||
        memberProfile.socialLinks.linkedin != "" ||
        memberProfile.socialLinks.facebook != "") {
      return Container(
        margin: EdgeInsets.only(top: 15),
        width: double.infinity,
        decoration: BoxDecoration(
          color: appwhite,
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Social links",
                  style: b_14black(),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                socialItem(
                  memberProfile.socialLinks.twitter,
                  Common.TwitterSvg,
                  "https://www.twitter.com/",
                ),
                socialItem(
                  memberProfile.socialLinks.instagram,
                  Common.InstagramSvg,
                  "https://www.instagram.com/",
                ),
                socialItem(
                  memberProfile.socialLinks.linkedin,
                  Common.LinkedinSvg,
                  "https://www.linkedin.com/in/",
                ),
                socialItem(
                  memberProfile.socialLinks.facebook,
                  Common.FacebookSvg,
                  "https://www.facebook.com/",
                ),
                socialItem(
                  memberProfile.socialLinks.website,
                  "",
                  "https://",
                ),
              ],
            ),
          ],
        ),
      );
    }
    return Container();
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

  Widget messageButton() {
    return InkWell(
      onTap: () {
        if (widget.isFromChatScreen) {
          Navigator.pop(context);
        } else {
          openBottomModal(context);
        }
      },
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: appgreydate),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Message",
              style: TextStyle(
                color: appBlack,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget calendarButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              screenIndex: 3,
              id: -1,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(left: 5),
        child: Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: appMustard,
            borderRadius: BorderRadius.circular(5),
          ),
          child: SvgPicture.asset(
            Common.CalendarSvg,
            color: appwhite,
            height: width / 22,
          ),
        ),
      ),
    );
  }

  Widget cancelRequestButton() {
    return InkWell(
      onTap: () async {
        final isSuccess = await overlay.during(
          pConnection.addRemoveFriend(
            widget.memberId,
            0,
            "",
          ),
        );
        if (isSuccess) {
          success(context, "Request Cancelled");
          setState(() {
            connectionList
                .removeWhere((element) => element.id == widget.memberId);
            memberProfile.profile.isRequestSent = 0;
          });
          pConnection.removeInvitation(widget.memberId);
        } else {
          error(context, "Something went wrong");
        }
      },
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: appBlack,
          ),
          SizedBox(width: width / 60),
          Text(
            "Cancel Request",
            style: b_12black(),
          ),
        ],
      ),
    );
  }

  Widget connectButton() {
    return InkWell(
      onTap: () async {
        if (memberProfile.profile.isBlocked) {
          onBlockUnblock(false);
        } else {
          final response = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuickConnectScreen(
                currentName: memberProfile.profile.firstname,
                currentProfile: memberProfile.profile.imageUrl,
                otherMemberId: memberProfile.profile.id,
              ),
            ),
          ).then((value){
            success(context, "Request Sent");
              setState(() {
                memberProfile.profile.isRequestSent = 1;
              });
          });
          // if (response != null && response) {
          //   success(context, "Request Sent");
          //   setState(() {
          //     memberProfile.profile.isRequestSent = 1;
          //   });
          // }
        }
      },
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        decoration: BoxDecoration(
          color: appBlack,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              memberProfile.profile.isBlocked ? 'Unblock' : 'Connect',
              style: TextStyle(
                color: appwhite,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget connectedButton() {
    return InkWell(
      onTap: () async {
        final isSuccess = await overlay.during(
          pConnection.addRemoveFriend(
            widget.memberId,
            0,
            "",
          ),
        );
        if (isSuccess) {
          success(context, "Friend Removed");
          setState(() {
            memberProfile.profile.isRequestSent = 0;
          });
          pConnection.removeFriend(widget.memberId);
        } else {
          somethingWentWrong(context);
        }
      },
      child: Container(
        margin: EdgeInsets.only(left: 5),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: appBlack,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Connected',
              style: TextStyle(
                color: appwhite,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        height: 50,
      ),
    );
  }

  dynamic openBottomModal(context) {
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.0),
                  child: Text(
                    "Write your message to ${memberProfile.profile.firstname}",
                    style: b_14black(),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: textController,
                    maxLines: 4,
                    autofocus: true,
                    cursorColor: appBlack,
                    decoration: InputDecoration(
                      border: outlineInputBorder(),
                      focusedBorder: outlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                InkWell(
                  onTap: () async {
                    if (textController.text.trim().isNotEmpty) {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      final isSuccess = await MessageApi.saveMessage(
                        widget.memberId,
                        textController.text.trim(),
                      );
                      if (isSuccess) {
                        toastBuild("Message sent");
                        setState(() {
                          textController.clear();
                        });
                        Navigator.pop(context);
                      } else {
                        toastBuild(
                            "Someting went wrong while sending the message");
                      }
                    } else {
                      toastBuild("Please add the message text");
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    decoration: BoxDecoration(
                      color: appBlack,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Send',
                      style: b_14white(),
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> openUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      error(context, "Invalid link");
    }
  }

  Future<void> onRefresh() async {
    await loadMemberProfile();
    await loadFriends();
  }

  Future<void> loadData() async {
    pref = await SharedPreferences.getInstance();
    overlay = LoaderOverlay.of(context);
    overlay.show();
    await loadMemberProfile();
    await loadFriends();
    overlay.hide();
  }

  Future<void> loadMemberProfile() async {
    final response = await getMemberProfile(widget.memberId);
    setState(() {
      memberProfile = response;
    });
  }

  Future<void> loadFriends() async {
    final response = await pConnection.getMemberConnections(widget.memberId);
    setState(() {
      connectionList = response;
    });
  }

  Future<void> openDotsBottomModal() {
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
                  title: Text(
                    memberProfile.profile.isSaved ? "Remove save" : "Save User",
                    style: b_15Black(),
                  ),
                  leading: Icon(Icons.save_alt, color: appBlack, size: 18),
                  onTap: () async {
                    if (memberProfile.profile.isSaved) {
                      final response = await overlay.during(
                        removeSavedProfileForLater(
                          memberProfile.profile.id,
                        ),
                      );
                      toastBuild(response.message);
                      setState(() {
                        memberProfile.profile.isSaved = true;
                      });
                    } else {
                      final response = await saveProfileForLater(
                        memberProfile.profile.id,
                      );
                      if (response != '') {
                        toastBuild(response);
                        setState(() {
                          memberProfile.profile.isSaved = false;
                        });
                      } else {
                        toastBuild('Something went wrong');
                      }
                    }
                  },
                ),
                SizedBox(
                  height: 0.1,
                  child: Container(color: appBlack),
                ),
                ListTile(
                  title: Text("Share Profile", style: b_15Black()),
                  leading: Icon(Icons.share, color: appBlack, size: 18),
                  onTap: () {
                    overlay.show();
                    _onImagDownloadButtonPressed(memberProfile.profile.imageUrl)
                        .whenComplete(
                      () {
                        overlay.hide();
                        final RenderBox box =
                            context.findRenderObject() as RenderBox;
                        String text = Utility.getShareText(
                            memberProfile.profile.firstname);
                        Share.shareFiles(
                          ['$path'],
                          text: text,
                          sharePositionOrigin:
                              box.localToGlobal(Offset.zero) & box.size,
                        );
                      },
                    );
                  },
                ),
                SizedBox(
                  height: 0.1,
                  child: Container(color: appBlack),
                ),
                ListTile(
                  title: Text(
                    memberProfile.profile.isBlocked ? "Unblock" : "Block",
                    style: b_15Black(),
                  ),
                  leading: Icon(
                    Icons.block_outlined,
                    color: appBlack,
                    size: 18,
                  ),
                  onTap: () async {
                    onBlockUnblock(true);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> onBlockUnblock(bool isClose) async {
    final isSuccess = await blockUnblockMember(
      memberProfile.profile.id,
      memberProfile.profile.isBlocked ? 1 : 0,
    );
    if (isSuccess) {
      setState(() {
        memberProfile.profile.isBlocked = !memberProfile.profile.isBlocked;
      });
      if (isClose) {
        Navigator.pop(context);
      }
      if (memberProfile.profile.isBlocked) {
        success(context, "Member Blocked");
      } else {
        success(context, "Member Unblocked");
      }
    } else {
      toastBuild("Something went wrong");
    }
  }

  Future _onImagDownloadButtonPressed(String url) async {
    try {
      // Saved with this method.
      var imageId = await ImageDownloader.downloadImage(url);
      if (imageId == null) {
        return;
      }
      path = await ImageDownloader.findPath(imageId);
      setState(() {
        path = path;
      });
    } on PlatformException catch (error) {
      print(error);
    }
    return true;
  }
}
