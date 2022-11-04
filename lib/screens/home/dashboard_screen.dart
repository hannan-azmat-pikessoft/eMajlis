import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/providers/common_provider.dart';
import 'package:emajlis/screens/appointments/appointments_screen.dart';
import 'package:emajlis/screens/connections/connections_screen.dart';
import 'package:emajlis/screens/home/home_screen.dart';
import 'package:emajlis/screens/home/new_home_screen.dart';
import 'package:emajlis/screens/home/search_screen.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  final int screenIndex;
  final int id;

  DashboardScreen({
    Key key,
    @required this.screenIndex,
    @required this.id,
  });

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTabIndex = 0;
  bool hideAppbar = false;
  List<Widget> tabs;
  int selectAppbarOption = 0;
  String myMemberId = '';

  ///The controller of sliding up panel
  SlidingUpPanelController panelController = SlidingUpPanelController();

  @override
  void initState() {
    _currentTabIndex = widget.screenIndex;
    context.read<CommonProvider>().setIdToRedirect(widget.id);
    tabs = [
      //Home(),
      NewHomeScreen(
        triggerPanel: hideAppBar,
        panelController: panelController,
      ),
      //MessageScreen(),
      ConnectionsScreen(),
      SearchScreen(),
      AppointmentsScreen(),
      // HomeScreen(
      //   triggerPanel: hideAppBar,
      //   panelController: panelController,
      // ),
      // MessageScreen(),
      // ConnectionsScreen(),
      // AppointmentsScreen(),
      // ProfileScreen(),
    ];
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[_currentTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: appwhite,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        currentIndex: _currentTabIndex,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              child: SvgPicture.asset(
                'assets/images/icons/menu 1.svg',
                color:
                    //_currentTabIndex == 0 ?
                    appBlack,
                //: appLightGrey,
                height: 33,
              ),
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Container(
              child: SvgPicture.asset(
                'assets/images/icons/Mdot.svg',
                //   'assets/images/icons/menu 2.svg',
                color:
                    //_currentTabIndex == 1 ?
                    appBlack,
                //: appLightGrey,
                height: 38,
              ),
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Container(
              child: SvgPicture.asset(
                'assets/images/icons/menu 3.svg',
                color:
                    //_currentTabIndex == 2 ?
                    appBlack,
                //   : appLightGrey,
                height: 33,
              ),
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Container(
              child: SvgPicture.asset(
                'assets/images/icons/menu 4.svg',
                color:
                    //_currentTabIndex == 3 ?
                    appBlack,
                //: appLightGrey,
                height: 33,
              ),
            ),
            label: "",
          ),

          // BottomNavigationBarItem(
          //   icon: Container(
          //     child: SvgPicture.asset(
          //       'assets/images/icons/Mdot.svg',
          //       color: _currentTabIndex == 0 ? appBlack : appLightGrey,
          //       height: 30,
          //     ),
          //   ),
          //   label: "",
          // ),
          // BottomNavigationBarItem(
          //   icon: Container(
          //     child: SvgPicture.asset(
          //       'assets/images/icons/tab_mail.svg',
          //       color: _currentTabIndex == 1 ? appBlack : appLightGrey,
          //     ),
          //   ),
          //   label: "",
          // ),
          // BottomNavigationBarItem(
          //   icon: Container(
          //     child: SvgPicture.asset(
          //       'assets/images/icons/tab_connections.svg',
          //       color: _currentTabIndex == 2 ? appBlack : appLightGrey,
          //       height: 30,
          //     ),
          //   ),
          //   label: "",
          // ),
          // BottomNavigationBarItem(
          //   icon: Container(
          //     child: SvgPicture.asset(
          //       'assets/images/icons/tab_calendar.svg',
          //       color: _currentTabIndex == 3 ? appBlack : appLightGrey,
          //       height: 30,
          //     ),
          //   ),
          //   label: "",
          // ),
          // BottomNavigationBarItem(
          //   icon: Container(
          //     child: SvgPicture.asset(
          //       'assets/images/icons/tab_user.svg',
          //       color: _currentTabIndex == 4 ? appBlack : appLightGrey,
          //       height: 30,
          //     ),
          //   ),
          //   label: "",
          // ),
        ],
      ),
    );
  }

  void hideAppBar(bool val) {
    setState(() {
      hideAppbar = val;
    });
  }

  void reCheck() {}
}
