import 'package:emajlis/screens/authentication/login_screen.dart';
import 'package:emajlis/screens/authentication/register_screen.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SplashOnboardingScreen extends StatefulWidget {
  @override
  SplashOnboardingScreenState createState() => SplashOnboardingScreenState();
}

class SplashOnboardingScreenState extends State<SplashOnboardingScreen> {
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {
      "image": "assets/images/graphics/splash1.svg",
      "title": "Professional Networking",
      "disc":
          "Connect & collaborate with like-minded professionals around you.",
    },
    {
      "image": "assets/images/graphics/splash2.svg",
      "title": "Meet Inspiring People",
      "disc":
          "Walkthrough the professional hallway of eMajlis and meet inspiring people.",
    },
    {
      "image": "assets/images/graphics/splash3.svg",
      "title": "Connect with professionals",
      "disc":
          "Witness the possibilities of connecting with professionals who share similar goals as you do.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          width: screenWidth,
          height: screenHeight,
          color: appBlackBackground,
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: PageView.builder(
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemCount: splashData.length,
                  itemBuilder: (context, index) => SplashContent(
                    image: splashData[index]["image"],
                    disc: splashData[index]["disc"],
                    title: splashData[index]["title"],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        splashData.length,
                        (index) => bulidDot(index: index),
                      ),
                    ),
                    Spacer(flex: 3),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(0xFF2B2B2B),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterScreen(),
                                ),
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 20,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: appwhite,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'Register',
                                style: b_16Black(),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 20,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'Sign In',
                                style: b_16white(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AnimatedContainer bulidDot({int index}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 0),
      margin: EdgeInsets.only(right: 10, left: 10),
      height: 10,
      width: 10,
      decoration: BoxDecoration(
        color: currentPage == index ? appwhite : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: appGrey,
          width: 1,
        ),
      ),
    );
  }
}

class SplashContent extends StatelessWidget {
  final String image;
  final String title;
  final String disc;

  const SplashContent({
    Key key,
    this.image,
    this.title,
    this.disc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Spacer(),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenHeight * 0.05,
            vertical: screenWidth * 0.05,
          ),
          child: SvgPicture.asset(image),
        ),
        SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontSize: 27,
            color: appwhite,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            disc,
            style: TextStyle(
              fontSize: 14,
              color: appGrey2,
              fontWeight: FontWeight.w100,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }
}
