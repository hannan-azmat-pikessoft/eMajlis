import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:flutter/cupertino.dart';

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  List<Map<String, String>> items = [
    {
      "title": "1. What is eMajlis",
      "disc":
          "We connect like-minded people to share meaningful career insights and help them achieve their professional goals. This is the mere reason why we strongly believe that Community Networking has the power to change lives as well as businesses.",
    },
    {
      "title": "2. Is eMajlis free?",
      "disc":
          "eMajlis is available for free in the App Store and Google Play Store",
    },
    {
      "title": "3. How do I create an eMajlis account?",
      "disc": "Welcome to eMajlis! Before you start matching, chatting and meeting, you’ll need to create a eMajlis account by following the steps below. These steps may vary depending on your device. \n\niOS\nDownload the eMajlis app for iOS\nTap “Register”\nSet up your profile\nConnect an account - connect your Apple, LinkedIn or Google account for a streamlined sign-in experience*\nSet up your profile\nAllow eMajlis access to all required permissions\nGet going!\n\nAndroid\nDownload the eMajlis app for Android\nTap “Register”\nEnter and verify your phone number Set up your profile\nConnect an account - connect your LinkedIn or Google account for a streamlined sign-in experience*\nAllow eMajlis access to all required permissions\nGet going!\n",
    },
    {
      "title": "4. Deleting your eMajlis account",
      "disc":
          "Open the app\nTap the profile button\nGo to Settings\nTap Delete Account and confirm by typing DELETE",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppbar(context, titleText: "FAQ"),
      backgroundColor: appBodyGrey,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            children: [
              ...List.generate(
                items.length,
                (index) => item(items[index]["title"], items[index]["disc"]),
              ),
              Container(
                margin: EdgeInsets.only(top: 5, left: 4, right: 4),
                decoration: BoxDecoration(
                  color: appwhite,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: const Text(
                        'Customer Care',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 17, right: 17, bottom: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'support@emajlis.ae',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.6)),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Text(
                                'feedback@emajlis.ae',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget item(String title, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: ExpandableNotifier(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              ScrollOnExpand(
                scrollOnExpand: true,
                scrollOnCollapse: false,
                child: ExpandablePanel(
                  theme: const ExpandableThemeData(
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    tapBodyToCollapse: true,
                  ),
                  header: Padding(
                    padding: EdgeInsets.only(
                      top: 15,
                      left: 15,
                      right: 15,
                      bottom: 10,
                    ),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  collapsed: null,
                  expanded: Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  builder: (_, collapsed, expanded) {
                    return Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: Expandable(
                        collapsed: collapsed,
                        expanded: expanded,
                        theme: const ExpandableThemeData(crossFadePoint: 0),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
