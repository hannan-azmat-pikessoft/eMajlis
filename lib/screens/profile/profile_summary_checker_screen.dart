import 'package:countup/countup.dart';
import 'package:emajlis/main.dart';
import 'package:emajlis/models/my_profile_model.dart';
import 'package:emajlis/providers/connection_provider.dart';
import 'package:emajlis/screens/home/dashboard_screen.dart';
import 'package:emajlis/screens/profile/education_screen.dart';
import 'package:emajlis/screens/profile/goals_screen.dart';
import 'package:emajlis/screens/profile/interested_industry_screen.dart';
import 'package:emajlis/screens/profile/meeting_preferences_screen.dart';
import 'package:emajlis/screens/profile/profile_edit_screen.dart';
import 'package:emajlis/screens/profile/profile_screen.dart';
import 'package:emajlis/screens/profile/social_links_screen.dart';
import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/utlis/animated_flip_counter.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/src/provider.dart';

class ProfileSummaryCheckerScreen extends StatefulWidget {
  const ProfileSummaryCheckerScreen({Key key}) : super(key: key);

  @override
  _ProfileSummaryCheckerScreenState createState() =>
      _ProfileSummaryCheckerScreenState();
}

class _ProfileSummaryCheckerScreenState
    extends State<ProfileSummaryCheckerScreen>
    with SingleTickerProviderStateMixin {
  MyProfile myprofile;

  // AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    myprofile = MyApp.getMyProfile(context);
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: Duration(milliseconds: 400),
    //   reverseDuration: Duration(milliseconds: 400),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // GestureDetector(
                    //   child: Text(
                    //     'Skip',
                    //     style: TextStyle(
                    //       fontSize: 17,
                    //       decoration: TextDecoration.underline,
                    //       decorationThickness: 2,
                    //     ),
                    //   ),
                    //   onTap: () async {
                    //     goToDashboard(0);
                    //   },
                    // ),
                  ],
                ),
                SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'eMajlis ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                          text:
                              'App is a platform which shows professionals around UAE and we connect like-minded people to share meaningful career insights and help them achieve their professional goals. '),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Profile Score',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xffFFCD07),
                        appMustard,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'eMajlis ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                              text:
                                  'App is a platform which shows professionals around UAE and we connect like-minded people to share meaningful career insights and help them achieve their professional goals. '),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                itemCompletion(),
                SizedBox(height: 20),
                progressBar(),
                SizedBox(height: 20),
                if (myprofile.profilePercentage == 100) buttonViewProfile(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget itemCompletion() {
    return Column(
      children: [
        item('Personal Information', myprofile.isPersonalInformationCompleted),
        item('Goals', myprofile.isGoalsCompleted),
        item('Education', myprofile.isEducationCompleted),
        item('Interested Industries', myprofile.isIndustryCompleted),
        item('Meeting Preferences', myprofile.isMeetingPreferencesCompleted),
        item('Social Links', myprofile.isSocialLinksCompleted),
      ],
    );
  }

  Widget item(String text, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        child: Row(
          children: [
            SizedBox(width: 5),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? black : appGrey5,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all((isCompleted ? 3 : 7)),
                child: Icon(
                  isCompleted ? Icons.done : Icons.brightness_1,
                  color: isCompleted ? black : appGrey5,
                  size: isCompleted ? 22 : 14,
                ),
              ),
            ),
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isCompleted ? black : appGrey5,
              ),
            )
          ],
        ),
        onTap: () async {
          if (!isCompleted) {
            if (text == 'Personal Information') {
              final response = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileEditScreen(
                    profileData: myprofile.profile,
                  ),
                ),
              );
              if (response != null) {
                success(context, "Personal Information updated");
                setState(() {
                  myprofile.profile = response;
                  onProfileUpdate();
                });
              }
            } else if (text == 'Goals') {
              final response = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoalsScreen(
                    myGoalList: myprofile.goalList,
                  ),
                ),
              );
              if (response != null) {
                success(context, 'Goals updated');
                setState(() {
                  myprofile.goalList = response;
                  onProfileUpdate();
                });
              }
            } else if (text == 'Education') {
              final response = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EducationScreen(
                    education: myprofile.education,
                  ),
                ),
              );
              if (response != null) {
                success(context, 'Education updated');
                setState(() {
                  myprofile.education = response;
                  onProfileUpdate();
                });
              }
            } else if (text == 'Interested Industries') {
              final response = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InterestedIndustryScreen(
                    myIndustryList: myprofile.interestedIndustryList,
                  ),
                ),
              );
              if (response != null) {
                success(context, "Interested Industries updated");
                myprofile.interestedIndustryList = response;
                onProfileUpdate();
              }
            } else if (text == 'Meeting Preferences') {
              final response = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MeetingPreferencesScreen(
                    myPreferenceList: myprofile.meetingPreferenceList,
                  ),
                ),
              );
              if (response != null) {
                success(context, "Meeting Preferences updated");
                setState(() {
                  myprofile.meetingPreferenceList = response;
                  onProfileUpdate();
                });
              }
            } else if (text == 'Social Links') {
              final response = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SocialLinksScreen(
                    socialLinks: myprofile.socialLinks,
                  ),
                ),
              );
              if (response != null) {
                success(context, "Social Links updated");
                setState(() {
                  myprofile.socialLinks = response;
                  onProfileUpdate();
                });
              }
            }
          }
        },
      ),
    );
  }

  Widget progressBar() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              child: Countup(
                begin: myprofile.profilePercentage != null &&
                        myprofile.profilePercentage >= 20
                    ? myprofile.profilePercentage.toDouble() - 20
                    : 0,
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
        Container(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.all(0.0),
            child: new LinearPercentIndicator(
              width: MediaQuery.of(context).size.width - 40,
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
        ),
      ],
    );
  }

  Widget buttonViewProfile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            decoration: BoxDecoration(
              color: appBlack,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'View Profile',
              style: TextStyle(
                color: appwhite,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onTap: () async {
            goToDashboard(4);
          },
        ),
      ],
    );
  }

  void onProfileUpdate() {
    setState(() {
      myprofile = updateCompletionPercentage(myprofile);
      MyApp.setMyProfile(context, myprofile);
    });
  }

  Future<void> goToDashboard(screenIndex) async {
    await context.read<ConnectionProvider>().loadConnections();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DashboardScreen(
          screenIndex: 0,
          id: -1,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          Animatable<Offset> tween = Tween(
            begin: Offset(0.0, 1.0),
            end: Offset.zero,
          ).chain(
            CurveTween(curve: Curves.ease),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
