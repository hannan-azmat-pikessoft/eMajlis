import 'dart:math';
import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/models/appointment_model.dart';
import 'package:emajlis/providers/appointment_provider.dart';
import 'package:emajlis/providers/connection_provider.dart';
import 'package:emajlis/screens/appointments/appointment_booking_screen.dart';
import 'package:emajlis/screens/appointments/appointment_list_screen.dart';
import 'package:emajlis/screens/appointments/appointment_meeting_screen.dart';
import 'package:emajlis/screens/appointments/venue/venue_list_screen.dart';
import 'package:emajlis/screens/home/dashboard_screen.dart';
import 'package:emajlis/services/appointment_service.dart';
import 'package:emajlis/utlis/flutter_device_type.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timelines/timelines.dart';
import 'svc_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<AppointmentsScreen> {
  SharedPreferences pref;
  LoaderOverlay overlay;
  double height;
  double width;

  AppointmentProvider pAppointment;
  ItemScrollController scrollController = ItemScrollController();
  double calendarHeight = 0;
  String myMemberId = '';

  final years = [2021, 2022, 2023];
  final months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  DateTime selectedDate;

  TextStyle textStyle = TextStyle(
    color: Colors.pink,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  void initState() {
    super.initState();
    pAppointment = context.read<AppointmentProvider>();
    initialize();
    calculateCaledarHeight();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  EventList<Event> _markedDateMap = new EventList();

  Widget _presentIcon(String day, String type) => Container(
        decoration: BoxDecoration(
          color: type == "accepted" ? Colors.green : Colors.orange,
          borderRadius: BorderRadius.all(Radius.circular(1000)),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    _markedDateMap = new EventList<Event>(
      events: {
        new DateTime(2020, 6, 20): [
          new Event(
              date: DateTime(2020, 6, 20),
              title: 'Event 1',
              icon: _presentIcon(DateTime(2020, 6, 20).day.toString(), '')),
        ],
      },
    );
    addMarkedDates();
    return Scaffold(
      appBar: simpleAppbar(
        context,
        titleText: "Appointments",
        isNavBack: false,
      ),
      body: Container(
        color: appBodyGrey,
        height: height,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Consumer<ConnectionProvider>(
                    builder: (context, pConnection, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          yearSelectorSection(),
                          makeBookingSection(pConnection),
                        ],
                      ),
                      SizedBox(height: 20),
                      monthSelectorSection(),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(15),
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        child: calendarCarouselNoHeader(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 5),
                        child: context
                                    .watch<AppointmentProvider>()
                                    .appointmentList
                                    .length ==
                                0
                            ? connectionListSection(pConnection)
                            : appointmentListSection(),
                      ),
                      findOurVenuesSection(),
                      SizedBox(height: 25),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget makeBookingSection(ConnectionProvider pConnection) {
    if (pAppointment.appointmentList.length != 0 &&
        pConnection.friendList.length > 0) {
      return GestureDetector(
        onTap: () async {
          final response = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentBookingScreen(),
            ),
          );
          if (response != null) {
            success(context, 'Appointment Requested Successfully');
            pAppointment.addAppointment(response);
          }
        },
        child: Container(
          height: 40,
          width: 140,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: appBlack,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            'Make a Booking',
            style: TextStyle(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Container();
  }

  Widget yearSelectorSection() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: pAppointment.currentYear,
        isDense: false,
        icon: FaIcon(
          Icons.keyboard_arrow_down_sharp,
          color: Colors.black,
        ),
        items: years.map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(value.toString()),
          );
        }).toList(),
        onChanged: (value) {
          print(value);
          overlay.show();
          setState(() {
            pAppointment.setCurrentYear(value);
            pAppointment.setCurrentMonth(1);
            onMonthChange();
          });
          overlay.hide();
        },
      ),
    );
  }

  Widget monthSelectorSection() {
    return Container(
      height: 30,
      width: width,
      child: ScrollablePositionedList.builder(
        itemScrollController: scrollController,
        itemCount: months.length,
        scrollDirection: Axis.horizontal,
        initialScrollIndex: pAppointment.currentMonth - 1,
        itemBuilder: (context, monthIndex) {
          return GestureDetector(
            onTap: () {
              setState(() {
                context
                    .read<AppointmentProvider>()
                    .setCurrentMonth(monthIndex + 1);
                onMonthChange();
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: _textSize(months[monthIndex], textStyle).width * 1.2,
                  height: _textSize(months[monthIndex], textStyle).height,
                  child: Center(
                    child: Text(
                      months[monthIndex],
                      style: TextStyle(
                        color: monthIndex == pAppointment.currentMonth - 1
                            ? Colors.black
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget calendarCarouselNoHeader() {
    return CalendarCarousel<Event>(
      height: calendarHeight,
      selectedDayBorderColor: Colors.white,
      selectedDateTime: selectedDate,
      targetDateTime: pAppointment.targetDateTime,
      minSelectedDate: DateTime.now().subtract(Duration(days: 365)),
      maxSelectedDate: DateTime.now().add(Duration(days: 365)),
      onCalendarChanged: (DateTime date) {},
      onDayLongPressed: (DateTime date) {},
      onDayPressed: (date, events) {
        this.setState(() => selectedDate = date);
        events.forEach((event) => print(event.title));
      },
      showHeader: false,
      //markedDateIconBorderColor: Colors.amber,
      markedDateIconMargin: 0,
      daysHaveCircularBorder: true,
      showOnlyCurrentMonthDate: false,
      markedDatesMap: _markedDateMap,
      markedDateShowIcon: true,
      markedDateIconMaxShown: 1,
      markedDateMoreShowTotal: null,
      weekFormat: false,
      isScrollable: false,
      firstDayOfWeek: 1,
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      // markedDateCustomShapeBorder:
      //     CircleBorder(side: BorderSide(color: Colors.green, width: 2)),
      thisMonthDayBorderColor: Colors.white,
      todayBorderColor: Colors.white,
      iconColor: Colors.black,
      dayButtonColor: Colors.white,
      selectedDayButtonColor: Colors.pink.shade300,
      markedDateIconBuilder: (event) {
        if (event != null) {
          return event.icon;
        }
        return Container();
      },
      // markedDateCustomShapeBorder:
      // CircleBorder(side: BorderSide(color: Colors.yellow,)),
      weekDayBackgroundColor: Colors.white,
      todayButtonColor: Colors.black,
      daysTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 12,
      ),
      weekendTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 12,
      ),
      weekdayTextStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      nextDaysTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      todayTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      markedDateCustomTextStyle: TextStyle(
        color: Colors.blue,
        fontSize: 12,
      ),
      selectedDayTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      prevDaysTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      inactiveDaysTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 12,
      ),
    );
  }

  Widget connectionListSection(ConnectionProvider pConnection) {
    if (pConnection.friendList.length == 0) {
      return Column(
        children: [
          Container(
            width: width,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "No friends in your friend list, Please make friends before booking appointment",
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appBlack,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          InkWell(
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
        ],
      );
    }
    return Container(
      height: height / 2.2,
      width: width,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "No active bookings, Click \"Make a booking \" to book an appointment now",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appBlack,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Image.asset(
            Common.TimePng,
            scale: 2,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () async {
                  final response = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentBookingScreen(),
                    ),
                  );
                  if (response != null) {
                    success(context, 'Appointment Requested Successfully');
                    setState(() {
                      pAppointment.addAppointment(response);
                    });
                  }
                },
                child: Container(
                  height: 40,
                  width: 140,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: appBlack,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Make a Booking',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VenueListScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 40,
                  width: 140,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Find our venues',
                    style: TextStyle(
                      color: appBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget appointmentListSection() {
    if (context.watch<AppointmentProvider>().appointmentList.length > 0) {
      return Column(
        children: [
          todaysMeeting(),
          upcomingMeeting(),
          waitingForResponse(),
          myRequestResponse(),
          completedMeetings(),
          declinedMeetingsSection(),
        ],
      );
    }
    return Container();
  }

  Widget todaysMeeting() {
    final today = DateTime.now();
    List<AppointmentModel> appointmentList = context
        .watch<AppointmentProvider>()
        .appointmentList
        .where((e) =>
            e.status == "accepted" &&
            e.startDate.year == today.year &&
            e.startDate.month == today.month &&
            e.startDate.day == today.day)
        .toList();

    if (appointmentList.length > 0) {
      return Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 10,
              bottom: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Meeting",
                  style: TextStyle(
                    color: appBlack,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(appointmentList.length, (index) {
            AppointmentModel item = appointmentList[index];
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(
                top: 10,
              ),
              child: Column(
                children: [
                  Card(
                    color: appBlack,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    margin: EdgeInsets.all(10),
                    child: Container(
                      padding: EdgeInsets.only(
                        top: 0,
                        left: 15,
                        right: 10,
                        bottom: 20,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(),
                              GestureDetector(
                                child: Icon(
                                  Icons.more_horiz,
                                  color: appwhite,
                                  size: 18,
                                ),
                                onTap: () {
                                  openBottomModal(context, item, 'T');
                                },
                              ),
                            ],
                          ),
                          Row(
                            // crossAxisAlignment:
                            // CrossAxisAlignment.start,
                            children: [
                              item.image != null
                                  ? CircleAvatar(
                                      radius: 12,
                                      backgroundColor: appwhite,
                                      backgroundImage: NetworkImage(item.image),
                                    )
                                  : CircleAvatar(
                                      radius: 12,
                                      backgroundColor: appwhite,
                                    ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.personName ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: appwhite,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        // mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          // SizedBox(width: 5,),
                                          Image.network(
                                              item.meetingPreferenceIcon,
                                              height: 10,
                                              width: 10,
                                              color: appwhite),
                                          // Icon(
                                          //   //item.meetingPreferenceIcon,
                                          //   item.meetingType.toLowerCase() ==
                                          //           "online"
                                          //       ? Icons.videocam
                                          //       : Icons.free_breakfast,
                                          //   size: 12,
                                          //   color: appwhite,
                                          // ),
                                          SizedBox(width: 5),
                                          Text(
                                            item.meetingPreference ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: appwhite,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 12,
                                            color: appwhite,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            dateRange(item),
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: TextStyle(
                                              color: appwhite,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    }
    return Container();
  }

  Widget upcomingMeeting() {
    List<AppointmentModel> appointmentList = context
        .watch<AppointmentProvider>()
        .appointmentList
        .where(
            (e) => e.status == "accepted" && DateTime.now().isBefore(e.endDate))
        .toList();

    return appointmentList.length > 0
        ? items("U", appointmentList)
        : Container();
  }

  Widget waitingForResponse() {
    List<AppointmentModel> appointmentList = context
        .watch<AppointmentProvider>()
        .appointmentList
        .where((e) =>
            e.memberId != context.read<AppointmentProvider>().memberId &&
            e.status == "requested")
        .toList();

    return appointmentList.length > 0
        ? items("W", appointmentList)
        : Container();
  }

  Widget myRequestResponse() {
    List<AppointmentModel> appointmentList = context
        .watch<AppointmentProvider>()
        .appointmentList
        .where((e) =>
            e.status == "requested" &&
            e.memberId == context.read<AppointmentProvider>().memberId)
        .toList();

    return appointmentList.length > 0
        ? items("R", appointmentList)
        : Container();
  }

  Widget completedMeetings() {
    List<AppointmentModel> appointmentList = context
        .watch<AppointmentProvider>()
        .appointmentList
        .where(
            (e) => e.status == "accepted" && DateTime.now().isAfter(e.endDate))
        .toList();

    return appointmentList.length > 0
        ? items("C", appointmentList)
        : Container();
  }

  Widget declinedMeetingsSection() {
    List<AppointmentModel> appointmentList = context
        .watch<AppointmentProvider>()
        .appointmentList
        .where((e) => e.status == "declined")
        .toList();

    return appointmentList.length > 0
        ? items("D", appointmentList)
        : Container();
  }

  Widget items(String type, List<AppointmentModel> appointmentList) {
    String title = '';
    Color titleColor = Colors.transparent;
    if (type == 'C') {
      title = 'Completed';
      titleColor = Colors.green;
    } else if (type == 'D') {
      title = 'Declined';
      titleColor = Colors.red;
    } else if (type == 'W') {
      title = 'Waiting for Response';
      titleColor = Colors.orange;
    } else if (type == 'R') {
      title = 'My Requests';
      titleColor = Colors.blue;
    } else if (type == 'U') {
      title = 'Upcoming Meetings';
      titleColor = Colors.deepPurple;
    }

    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AppointmentListScreen(appointmentList, type),
                        ),
                      );
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        "All",
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      //Icon(Icons.arrow_drop_down)
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(top: 10),
            child: Container(
              child: FixedTimeline.tileBuilder(
                theme: TimelineThemeData(
                  nodePosition: 0.12,
                  color: Colors.red,
                  indicatorTheme: IndicatorThemeData(
                    color: Colors.grey[350],
                  ),
                  connectorTheme: ConnectorThemeData(
                    color: Colors.grey[350],
                    thickness: 2,
                  ),
                ),
                builder: TimelineTileBuilder.connectedFromStyle(
                    firstConnectorStyle: ConnectorStyle.transparent,
                    lastConnectorStyle: ConnectorStyle.transparent,
                    contentsAlign: ContentsAlign.basic,
                    oppositeContentsBuilder: (context, index) => Padding(
                          padding: EdgeInsets.all(1.0),
                          child: Row(
                            children: [
                              Text(
                                dayAndMonth(appointmentList[index].startDate),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    contentsBuilder: (context, index) {
                      AppointmentModel item = appointmentList[index];
                      return Card(
                        color: type == 'W' ? Colors.orange : appwhite,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        margin: EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 0,
                            left: 10,
                            right: 10,
                            bottom: 10,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(),
                                  GestureDetector(
                                    child: Icon(
                                      Icons.more_horiz,
                                      color:
                                          item.isVoted == null || !item.isVoted
                                              ? type == 'W'
                                                  ? appwhite
                                                  : appBlack
                                              : Colors.transparent,
                                      size: 18,
                                    ),
                                    onTap: () {
                                      if (item.isVoted == null ||
                                          !item.isVoted) {
                                        openBottomModal(context, item, type);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Row(
                                              //  crossAxisAlignment:
                                              //    CrossAxisAlignment.start,
                                              children: [
                                                item.image != null
                                                    ? CircleAvatar(
                                                        radius: 12,
                                                        backgroundColor:
                                                            appBlack,
                                                        backgroundImage:
                                                            NetworkImage(
                                                                item.image),
                                                      )
                                                    : CircleAvatar(
                                                        radius: 12,
                                                        backgroundColor:
                                                            appBlack,
                                                      ),
                                                SizedBox(width: 7),
                                                Expanded(
                                                  child: Text(
                                                    item.personName ?? '',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      height: 1,
                                                      fontSize: 16,
                                                      color: type == 'W'
                                                          ? appwhite
                                                          : appBlack,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(width: 31),
                                              item.meetingPreferenceIcon !=
                                                          null &&
                                                      item.meetingPreferenceIcon !=
                                                          ''
                                                  ? Image.network(
                                                      item.meetingPreferenceIcon,
                                                      height: 10,
                                                      width: 10,
                                                      color: type == 'W'
                                                          ? appwhite
                                                          : appBlack,
                                                    )
                                                  : Icon(
                                                      item.meetingType
                                                                  .toLowerCase() ==
                                                              "online"
                                                          ? Icons.videocam
                                                          : Icons
                                                              .free_breakfast,
                                                      size: 12,
                                                      color: type == 'W'
                                                          ? appwhite
                                                          : appBlack,
                                                    ),
                                              SizedBox(width: 5),
                                              Text(
                                                item.meetingPreference ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: type == 'W'
                                                      ? appwhite
                                                      : appBlack,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 2),
                                          Row(
                                            children: [
                                              SizedBox(width: 30),
                                              Icon(
                                                Icons.access_time,
                                                size: 12,
                                                color: type == 'W'
                                                    ? appwhite
                                                    : appBlack,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                dateRange(item),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                                style: TextStyle(
                                                  color: type == 'W'
                                                      ? appwhite
                                                      : appBlack,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 7.5),
                                          if (type == 'C')
                                            Row(
                                              children: [
                                                SizedBox(width: 25),
                                                GestureDetector(
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xffFFCD07),
                                                          Color(0xffE97A18),
                                                        ],
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                            Common.SecuritySvg),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          item.isVoted ==
                                                                      null ||
                                                                  !item.isVoted
                                                              ? 'Vote'
                                                              : 'Voted',
                                                          style: TextStyle(
                                                            color: appBlack,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    if (item.isVoted == null ||
                                                        !item.isVoted) {
                                                      goToSVC(item);
                                                    } else {
                                                      warning(context,
                                                          'Already voted');
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    connectorStyleBuilder: (context, index) =>
                        ConnectorStyle.dashedLine,
                    indicatorStyleBuilder: (context, index) {
                      return IndicatorStyle.outlined;
                    },
                    itemCount: appointmentList.length < 3
                        ? appointmentList.length
                        : 3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget findOurVenuesSection() {
    if (pAppointment.appointmentList.length > 0) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VenueListScreen(),
            ),
          );
        },
        child: Center(
          child: Container(
            alignment: Alignment.center,
            height: 40,
            width: 140,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: appBodyGrey,
              border: Border.all(color: appBlack),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'Find our venues',
              style: TextStyle(color: appBlack),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return Container();
  }

  Future<dynamic> openBottomModal(context, AppointmentModel item, String type) {
    bool isDeleteVisible = type == 'D';
    bool isVoteVisible = type == 'C' && (item.isVoted == null || !item.isVoted);
    bool isAccepteVisible = item.memberId != myMemberId &&
        item.status != "accepted" &&
        item.status != "declined";
    bool isDeclineVisible = item.memberId != myMemberId &&
        item.status != "accepted" &&
        item.status != "declined";
    bool isCancelVisible = type == 'T' || type == 'U' || type == 'R';

    bool isMeetingVisible = false;
    if (item.meetingType.toLowerCase() == "online" &&
        item.status == "accepted") {
      final DateTime now = DateTime.now();
      final DateTime minDate = DateTime(
        item.startDate.year,
        item.startDate.month,
        item.startDate.day,
        item.startDate.hour,
        item.startDate.minute,
      ).add(Duration(minutes: -5));
      final DateTime maxDate = DateTime(
        item.endDate.year,
        item.endDate.month,
        item.endDate.day,
        item.endDate.hour,
        item.endDate.minute,
      ).add(Duration(minutes: 5));
      if (minDate.isBefore(now) && maxDate.isAfter(now)) {
        isMeetingVisible = true;
      }
    }

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
            bottom: MediaQuery.of(context).viewInsets.bottom +
                (Device.get().isIphoneX ? 40 : 0),
          ),
          child: Container(
            padding: EdgeInsets.all(10),
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
                if (isDeleteVisible)
                  ListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          color: appBlack,
                          size: 20,
                        ),
                        SizedBox(width: 25),
                        Text('Delete Appointment', style: b_15Black()),
                      ],
                    ),
                    onTap: () async {
                      onDelete(item);
                    },
                  ),
                if (isDeleteVisible)
                  SizedBox(
                    height: 0.1,
                    child: Container(color: appBlack),
                  ),
                if (isVoteVisible)
                  ListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.how_to_vote,
                          color: appBlack,
                          size: 20,
                        ),
                        SizedBox(width: 25),
                        Text('Vote for Appointment', style: b_15Black()),
                      ],
                    ),
                    onTap: () {
                      goToSVC(item);
                    },
                  ),
                if (isVoteVisible)
                  SizedBox(
                    height: 0.1,
                    child: Container(color: appBlack),
                  ),
                if (isAccepteVisible)
                  ListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.done,
                          color: appBlack,
                          size: 20,
                        ),
                        SizedBox(width: 25),
                        Text('Accept Appointment', style: b_15Black()),
                      ],
                    ),
                    onTap: () async {
                      await updateAppointmentStatus(
                        item.appointmentId,
                        "accepted",
                      );
                    },
                  ),
                if (isAccepteVisible)
                  SizedBox(
                    height: 0.1,
                    child: Container(color: appBlack),
                  ),
                if (isDeclineVisible)
                  ListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.cancel_sharp,
                          color: appBlack,
                          size: 20,
                        ),
                        SizedBox(width: 25),
                        Text('Decline Appointment', style: b_15Black()),
                      ],
                    ),
                    onTap: () async {
                      await updateAppointmentStatus(
                        item.appointmentId,
                        "declined",
                      );
                    },
                  ),
                if (isDeclineVisible)
                  SizedBox(
                    height: 0.1,
                    child: Container(color: appBlack),
                  ),
                if (isCancelVisible)
                  ListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.cancel_sharp,
                          color: appBlack,
                          size: 20,
                        ),
                        SizedBox(width: 25),
                        Text('Cancel Appointment', style: b_15Black()),
                      ],
                    ),
                    onTap: () async {
                      await updateAppointmentStatus(
                        item.appointmentId,
                        "cancelled",
                      );
                    },
                  ),
                if (isCancelVisible)
                  SizedBox(
                    height: 0.1,
                    child: Container(color: appBlack),
                  ),
                if (isMeetingVisible)
                  ListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.video_call,
                          color: appBlack,
                          size: 20,
                        ),
                        SizedBox(width: 25),
                        Text('Join Video Call', style: b_15Black()),
                      ],
                    ),
                    onTap: () async {
                      goToMeeting(item);
                    },
                  ),
                if (isMeetingVisible)
                  SizedBox(
                    height: 0.1,
                    child: Container(color: appBlack),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> onDelete(AppointmentModel item) async {
    final isDeleted = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Do you want to delete the appointment ?",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final isSuccess = await overlay.during(
                            deleteAppointment(
                              item.appointmentId,
                            ),
                          );
                          if (isSuccess) {
                            pAppointment.removeAppointment(
                              item.appointmentId,
                            );
                            Navigator.pop(context, true);
                          }
                        },
                        child: Container(
                          height: 40,
                          width: 120,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: appBlack,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'Yes',
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
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'No',
                            style: TextStyle(
                              color: appBlack,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
    if (isDeleted != null && isDeleted) {
      Navigator.pop(context);
      success(context, "Appointment Deleted");
    }
  }

  void goToSVC(AppointmentModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SVCScreen(
          meetingId: item.appointmentId,
          givenToId: item.personId,
          givenById: item.memberId,
          givenToImage: item.image,
          givenToName: item.personName,
        ),
      ),
    ).then((isSuccess) {
      if (isSuccess != null && isSuccess) {
        initialize();
        success(context, 'Successfully voted');
      }
    });
  }

  void goToMeeting(AppointmentModel item) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentMeeting(
          appointment: item,
        ),
      ),
    ).then((isSuccess) {});
  }

  Future<void> initialize() async {
    pref = await SharedPreferences.getInstance();
    overlay = LoaderOverlay.of(context);
    myMemberId = pref.getString(StorageKeys.MemberId);
    if (myMemberId != "") {
      loadData(context.read<AppointmentProvider>().memberId == null ||
              context.read<AppointmentProvider>().memberId == ""
          ? true
          : false);
    }
  }

  void onMonthChange() {
    pAppointment.setTargetDateTime(
        DateTime(pAppointment.currentYear, pAppointment.currentMonth));
    scrollController.scrollTo(
        index: pAppointment.currentMonth - 1, duration: Duration(seconds: 1));
    calculateCaledarHeight();
    loadData(true);
  }

  void calculateCaledarHeight() {
    DateTime monthFirst =
        DateTime(pAppointment.currentYear, pAppointment.currentMonth, 1);
    DateTime monthLast =
        DateTime(pAppointment.currentYear, pAppointment.currentMonth + 1, 0);
    String day = DateFormat('EEEE').format(monthFirst);
    setState(() {
      if ((monthLast.day == 31 && (day == 'Sunday' || day == 'Saturday')) ||
          (monthLast.day == 30 && day == 'Sunday')) {
        calendarHeight = 300;
      } else {
        calendarHeight = 260;
      }
    });
  }

  Future<void> loadData(bool showLoader) async {
    if (showLoader) {
      overlay.show();
    }
    await context.read<AppointmentProvider>().loadAppointments();
    context.read<AppointmentProvider>().memberId = myMemberId;
    if (showLoader) {
      overlay.hide();
    }
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    final isSuccess = await overlay.during(
      acceptCancelAppointment(id, status == "cancelled" ? "declined" : status),
    );
    if (isSuccess) {
      pAppointment.updateAppointmentStatus(
          id, status == "cancelled" ? "declined" : status);
      Navigator.pop(context);
      success(
          context,
          'Appointment ' +
              status.substring(0, 1).toUpperCase() +
              status.substring(1, status.length));
    } else {
      toastBuild('Something went wrong');
    }
  }

  String dayAndMonth(DateTime date) {
    return DateFormat('dd\nMMM').format(date);
  }

  String dateRange(AppointmentModel item) {
    final d1 = new DateFormat('MMM');
    final d2 = new DateFormat('d');
    final d3 = new DateFormat('hh:mm a');

    return d2.format(item.startDate) +
        " " +
        d1.format(item.startDate).substring(0, 3) +
        ", " +
        d3.format(item.startDate) +
        " - " +
        d2.format(item.endDate) +
        " " +
        d1.format(item.endDate).substring(0, 3) +
        ", " +
        d3.format(item.endDate);
  }

  TextStyle b_15Black() {
    return TextStyle(
      fontSize: 15,
      color: appBlack,
      fontWeight: FontWeight.bold,
    );
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

  addMarkedDates() {
    List<AppointmentModel> appointmentList = [];
    if (context.watch<AppointmentProvider>() != null &&
        context.watch<AppointmentProvider>().appointmentList != null) {
      appointmentList = context.watch<AppointmentProvider>().appointmentList;
      for (int i = 0;
          i < context.watch<AppointmentProvider>().appointmentList.length;
          i++) {
        if (appointmentList[i].startDate != null &&
            appointmentList[i].status == 'accepted' &&
            (appointmentList[i].startDate.isAfter(DateTime.now()))) {
          _markedDateMap.add(
              DateTime(
                  appointmentList[i].startDate.year,
                  appointmentList[i].startDate.month,
                  appointmentList[i].startDate.day),
              Event(
                  date: DateTime(
                      appointmentList[i].startDate.year,
                      appointmentList[i].startDate.month,
                      appointmentList[i].startDate.day),
                  icon: _presentIcon(
                      appointmentList[i].startDate.day.toString(),
                      "accepted")));
        } else if (appointmentList[i].startDate != null &&
            appointmentList[i].status == "requested" &&
            (appointmentList[i].startDate.isAfter(DateTime.now()))) {
          _markedDateMap.add(
              DateTime(
                  appointmentList[i].startDate.year,
                  appointmentList[i].startDate.month,
                  appointmentList[i].startDate.day),
              Event(
                  date: DateTime(
                      appointmentList[i].startDate.year,
                      appointmentList[i].startDate.month,
                      appointmentList[i].startDate.day),
                  icon: _presentIcon(
                      appointmentList[i].startDate.day.toString(),
                      "requested")));
        }
      }
    }
  }
}
