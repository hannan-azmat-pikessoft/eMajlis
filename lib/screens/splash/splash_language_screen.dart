import 'dart:async';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/main.dart';
import 'package:emajlis/models/my_profile_model.dart';
import 'package:emajlis/providers/common_provider.dart';
import 'package:emajlis/providers/connection_provider.dart';
import 'package:emajlis/screens/home/dashboard_screen.dart';
import 'package:emajlis/screens/profile/profile_summary_checker_screen.dart';
import 'package:emajlis/screens/splash/splash_onboarding_screen.dart';
import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class SplashLanguageScreen extends StatefulWidget {
  const SplashLanguageScreen({Key key}) : super(key: key);

  @override
  _SplashLanguageScreenState createState() => _SplashLanguageScreenState();
}

class _SplashLanguageScreenState extends State<SplashLanguageScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      loadBaseData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        color: appwhite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/graphics/elog.png'),
            SizedBox(height: 30),
            Text(
              'Welcome!',
              style: TextStyle(
                color: appBlack,
                fontSize: 31,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future loadBaseData() async {
    await context.read<CommonProvider>().loadCountries();
    await context.read<CommonProvider>().loadCities();

    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getString(StorageKeys.MemberId);
    final token = prefs.getString(StorageKeys.EncryptedToken);
    if (memberId != null && token != null) {
      context.read<ConnectionProvider>().setMyMemberId(memberId);
      checkProfileCompletion(memberId);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SplashOnboardingScreen(),
        ),
      );
    }
  }

  Future<void> checkProfileCompletion(String memberId) async {
    final MyProfile myProfile = await getMemberProfile(memberId);
    MyApp.setMyProfile(context, myProfile);
    if (myProfile.profilePercentage < 100) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileSummaryCheckerScreen(),
        ),
        (route) => false,
      );
    } else {
      await context.read<ConnectionProvider>().loadConnections();
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
  }
}
