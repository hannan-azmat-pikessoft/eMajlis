import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/models/appointment_model.dart';
import 'package:emajlis/providers/appointment_provider.dart';
import 'package:emajlis/providers/connection_provider.dart';
import 'package:emajlis/screens/profile/meeting_preferences_screen.dart';
import 'package:emajlis/services/meeting_preference_service.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/models/member_model.dart';
import 'package:emajlis/models/meeting_preference_model.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class AppointmentBookingScreen extends StatefulWidget {
  @override
  _AppointmentBookingScreenState createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  SharedPreferences pref;
  LoaderOverlay overlay;
  double height;
  double width;

  TextEditingController startDateController = new TextEditingController();
  TextEditingController endDateController = new TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

  AppointmentProvider pAppointment;
  List<MeetingPreferenceModel> meetingPreferenceList = [];
  List onlineMeetingTypeList = [];
  MemberModel selectedFriend;

  String personId = '';
  String meetingPreference = '';
  bool isOnlineMeeting = true;
  int selectedId = 0;

  DateTime selectedStartDate;
  DateTime selectedEndDate;
  TimeOfDay selectedStartTime =  TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 15)));
  TimeOfDay selectedEndTime = TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);
  DateTime selectedTime = DateTime.now();

  int _radioSelected = 1;
  MaterialColor kPrimaryColor = const MaterialColor(
    0xFF0B0C0C,
    const <int, Color>{
      50: const Color(0xFF080808),
      100: const Color(0xFF080808),
      200: const Color(0xFF080808),
      300: const Color(0xFF080808),
      400: const Color(0xFF080808),
      500: const Color(0xFF080808),
      600: const Color(0xFF080808),
      700: const Color(0xFF080808),
      800: const Color(0xFF080808),
      900: const Color(0xFF080808),
    },
  );

  @override
  void initState() {
    super.initState();
    pAppointment = context.read<AppointmentProvider>();
    selectedStartDate = pAppointment.targetDateTime;
    selectedEndDate = pAppointment.targetDateTime;
    if (selectedStartDate.isBefore(DateTime.now())) {
      selectedStartDate = DateTime.now();
    }
    if (selectedEndDate.isBefore(DateTime.now())) {
      selectedEndDate = DateTime.now();
    }
    personId = context.read<ConnectionProvider>().friendList[0].id;
    selectedFriend = context.read<ConnectionProvider>().friendList[0];
    Future.delayed(Duration.zero, () {
      initialize();
    });
    onlineMeetingTypeList = [
      {"icon": Icons.videocam, "color": Colors.blue},
      {"icon": Icons.call, "color": Colors.green},
    ];
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
      appBar: simpleAppbar(context, titleText: "Book Appointment"),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: appBodyGrey,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                'Person',
                style: b_14black(),
              ),
            ),
            Consumer<ConnectionProvider>(
              builder: (context, pConnection, child) {
                return FormField<String>(
                  enabled: false,
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: appwhite,
                        hintText: "Select person",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(color: appBlack),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          icon: Center(
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: appBlack,
                              size: 30,
                            ),
                          ),
                          hint: Text(
                            "Select person",
                            style: TextStyle(color: appBlack),
                          ),
                          value: personId,
                          isDense: true,
                          onChanged: (newValue) {
                            setState(() {
                              personId = newValue;
                              loadMeetingPreferences();
                            });
                          },
                          items: pConnection.friendList.map((map) {
                            return DropdownMenuItem<String>(
                              onTap: () {
                                selectedFriend = map;
                              },
                              value: map.id,
                              child: Text(map.firstName ?? ''),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                'Start Date / Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextFormField(
              controller: startDateController,
              style: TextStyle(color: appBlack),
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                _selectStartDate(context);
              },
              cursorColor: appGrey2,
              enableInteractiveSelection: false,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                counterText: '',
                hintText: 'Select Date Time',
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down,
                  color: appBlack,
                  size: 30,
                ),
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: appGrey3,
                ),
                border: new OutlineInputBorder(
                  borderSide: BorderSide(
                    color: appGrey3,
                  ),
                ),
                enabledBorder: new OutlineInputBorder(
                  borderSide: BorderSide(
                    color: appGrey3,
                  ),
                ),
                disabledBorder: new OutlineInputBorder(
                  borderSide: BorderSide(
                    color: appGrey3,
                  ),
                ),
                focusedBorder: new OutlineInputBorder(
                  borderSide: BorderSide(
                    color: appGrey3,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                'End Date / Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextFormField(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                _selectEndDate(context);
              },
              controller: endDateController,
              enableInteractiveSelection: false,
              style: TextStyle(color: appBlack),
              cursorColor: appGrey2,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                counterText: '',
                hintText: 'Select Date Time',
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down,
                  color: appBlack,
                  size: 30,
                ),
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: appGrey3,
                ),
                border: new OutlineInputBorder(
                  borderSide: BorderSide(
                    color: appGrey3,
                  ),
                ),
                enabledBorder: new OutlineInputBorder(
                  borderSide: BorderSide(
                    color: appGrey3,
                  ),
                ),
                disabledBorder: new OutlineInputBorder(
                  borderSide: BorderSide(
                    color: appGrey3,
                  ),
                ),
                focusedBorder: new OutlineInputBorder(
                  borderSide: BorderSide(
                    color: appGrey3,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Meeting type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Radio(
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  groupValue: _radioSelected,
                  value: 1,
                  activeColor: appBlack,
                  onChanged: (value) {
                    setState(() {
                      _radioSelected = value;
                      isOnlineMeeting = !isOnlineMeeting;
                    });
                  },
                ),
                SizedBox(width: 10,),
                Text('Online Meeting'),
                SizedBox(width: 20,),
                Radio(
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  groupValue: _radioSelected,
                  value: 2,
                  activeColor: appBlack,
                  onChanged: (value) {
                    setState(() {
                      _radioSelected = value;
                      isOnlineMeeting = !isOnlineMeeting;
                    });
                  },
                ),
                SizedBox(width: 10,),
                Text('In Person'),
              ],
            ),
            SizedBox(height: 15),
            isOnlineMeeting
                ? Container(
              child: Text(
                "Using our built-in video calling app",
                style: n_14grey(),
              ),
            )
            //onlineMeetingTypeListSection()
                : meetingPreferenceSection(),
            SizedBox(height: 20),
            bookAppointmentButton(),
          ],
        ),
      ),
    );
  }

  Widget onlineMeetingTypeListSection() {
    return Center(
      child: Container(
        width: 90 * double.parse(onlineMeetingTypeList.length.toString()),
        height: height * 0.15,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: onlineMeetingTypeList.length,
          itemBuilder: (context, i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedId = i;
                  });
                },
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (selectedId == i) ? Colors.black : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    onlineMeetingTypeList[i]["icon"],
                    size: 40,
                    color: onlineMeetingTypeList[i]["color"],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget meetingPreferenceSection() {
    if (meetingPreferenceList.length > 0) {
      return Container(
        padding: EdgeInsets.all(10),
       // height: 100,
        width: width,
        color: appwhite,
        child: GridView.builder(
          shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              // number of items per row
              crossAxisCount: 3,
              // vertical spacing between the items
              mainAxisSpacing: 10,
              // horizontal spacing between the items
              crossAxisSpacing: 10,
            ),
            // number of items in your list
            itemCount: meetingPreferenceList.length,

         // shrinkWrap: true,
          //scrollDirection: Axis.horizontal,
          //itemCount: meetingPreferenceList.length,
          itemBuilder: (context, i) {
            final item = meetingPreferenceList[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedId = i;
                    meetingPreference = item.preferenceTypeName;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5),
                 // width: (width - 120) / 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 5,bottom: 5),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.black),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(8),
                        child: Image.network(
                          item.imageName,
                          scale: 1.5,
                          color: appBlack,
                        ),
                      ),
                      Text(
                       item.preferenceTypeName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: (selectedId == i) ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Center(
        child: Column(
          children: [
            Text(
              "Please add any meeting prefrence in your profile",
              textAlign: TextAlign.center,
            ),
            updatePreferenceButton(),
          ],
        ),
      );
    }
  }

  Widget updatePreferenceButton() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: ElevatedButton(
        child: Text(
          'Update Preference',
          style: TextStyle(
            color: appwhite,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          primary: appBlack,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        ),
        onPressed: () async {
          final response = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeetingPreferencesScreen(
                myPreferenceList: [],
              ),
            ),
          );
          if (response != null) {
            success(context, "Meeting Preference Saved");
            setState(() {
              meetingPreferenceList = response;
            });
          }
        },
      ),
    );
  }

  Widget bookAppointmentButton() {
    if (isOnlineMeeting ||
        (!isOnlineMeeting && meetingPreferenceList.length > 0)) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            primary: appBlack,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          ),
          onPressed: () async {
            final df = new DateFormat('yyyy-MM-dd');
            final now = DateTime.now();
            final sDate = DateTime(
              selectedStartDate.year,
              selectedStartDate.month,
              selectedStartDate.day,
              selectedStartTime.hour,
              selectedStartTime.minute,
            );
            if (now.isAfter(sDate)) {
              warning(context, 'Please select a Future Start Date and Time');
            } else if (selectedStartDate.isAfter(selectedEndDate)) {
              warning(context, 'End Date should be greater than Start Date');
            } else if (startTimeController.text == '') {
              warning(context, 'Please Select Start Date and Time');
            } else if (endTimeController.text == '') {
              warning(context, 'Please Select End Date and Time');
            } else if (df
                    .format(DateTime.parse(selectedStartDate.toString())) ==
                df.format(DateTime.parse(selectedEndDate.toString()))) {
              DateTime dStartTime =
                  DateFormat.jm().parse(startTimeController.text);
              DateTime dEndTime = DateFormat.jm().parse(endTimeController.text);
              int duration = dEndTime.difference(dStartTime).inMinutes;
              if (duration >= 60) {
                saveAppointment();
              } else {
                warning(context, 'Minimum 1 hour duration is required');
              }
            } else {
              saveAppointment();
            }
          },
          child: Text(
            'Book Appointment',
            style: TextStyle(
              color: appwhite,
            ),
          ),
        ),
      );
    }
    return Container();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedStartDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: kPrimaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: appBlack,
              ),
            ),
          ),
          child: child,
        );
      },
      lastDate: DateTime(2101),
    );
    final TimeOfDay pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 15))),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: kPrimaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: appBlack, // button text color
              ),
            ),
          ),
          child: child,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        selectedStartTime = pickedTime;
        startTimeController.text = formatDate(
            DateTime(2019, 08, 1, pickedTime.hour, pickedTime.minute),
            [hh, ':', nn, " ", am]).toString();
      });
    }
    String dateText = '';
    if (pickedDate != null) {
      setState(() {
        selectedStartDate = pickedDate;
        dateText = pickedDate.toString().substring(0, 10);
       selectedTime = new DateTime(selectedStartDate.year, selectedStartDate.month, selectedStartDate.day, selectedStartTime.hour, selectedStartTime.minute);
      });
    }
    if (dateText != '' && startTimeController.text != '') {
      startDateController.text = dateText + " " + startTimeController.text;
    } else {
      warning(context, 'Please select both Date and Time');
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedStartDate,
      initialDatePickerMode: DatePickerMode.day,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: kPrimaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: appBlack,
              ),
            ),
          ),
          child: child,
        );
      },
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    final TimeOfDay pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedTime.add(Duration(hours: 1))),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: kPrimaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: appBlack, // button text color
              ),
            ),
          ),
          child: child,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        selectedEndTime = pickedTime;
        endTimeController.text = formatDate(
            DateTime(2019, 08, 1, pickedTime.hour, pickedTime.minute),
            [hh, ':', nn, " ", am]).toString();
      });
    }
    String dateText = '';
    if (pickedDate != null) {
      setState(() {
        selectedEndDate = pickedDate;
        dateText = pickedDate.toString().substring(0, 10);
      });
    }
    if (dateText != '' && endTimeController.text != '') {
      endDateController.text = dateText + " " + endTimeController.text;
    } else {
      warning(context, 'Please select both Date and Time');
    }
  }

  Future<void> initialize() async {
    pref = await SharedPreferences.getInstance();
    overlay = LoaderOverlay.of(context);
    loadMeetingPreferences();
  }

  Future<void> loadMeetingPreferences() async {
    final response = await getMyMeetingPreferences();
    setState(() {
      meetingPreferenceList = response;
    });
  }

  Future<void> saveAppointment() async {
    final response = await overlay.during(
      pAppointment.saveAppointment(
        personId,
        startTimeController.text,
        endTimeController.text,
        selectedStartDate,
        selectedEndDate,
        meetingPreference,
        isOnlineMeeting,
      ),
    );

    if (response.status) {
      print(response.status);
      AppointmentModel item = new AppointmentModel();
      item.appointmentId = response.id;
      item.memberId = pref.getString(StorageKeys.MemberId);
      item.personId = personId;
      item.personName = selectedFriend.firstName;
      item.image = selectedFriend.imageUrl;
      item.status = "requested";
      item.meetingType = isOnlineMeeting ? "Online" : "Offline";
      item.meetingLink = "test link";
      item.meetingPreference = isOnlineMeeting ? "Online" : meetingPreference;
      item.isVoted = false;
      item.startDate = DateTime(
        selectedStartDate.year,
        selectedStartDate.month,
        selectedStartDate.day,
        selectedStartTime.hour,
        selectedStartTime.minute,
      );
      item.endDate = DateTime(
        selectedEndDate.year,
        selectedEndDate.month,
        selectedEndDate.day,
        selectedEndTime.hour,
        selectedEndTime.minute,
      );
      Navigator.pop(context, item);
    } else {
      toastBuild(response.message);
    }
  }
}
