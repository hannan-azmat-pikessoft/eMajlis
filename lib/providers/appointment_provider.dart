import 'dart:convert';
import 'dart:developer';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/environment.dart';
import 'package:emajlis/models/appointment_model.dart';
import 'package:emajlis/models/response_model.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentProvider extends ChangeNotifier {
  List<AppointmentModel> appointmentList = [];
  int currentYear = DateTime.now().year;
  int currentMonth = DateTime.now().month;
  DateTime targetDateTime = DateTime.now().add(Duration(minutes: 10));
  String memberId;

  Future<void> loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    List<AppointmentModel> items = [];
    try {
      final memberId = prefs.getString(StorageKeys.MemberId);
      final url = Environment.Host +
          'get_appointment?' +
          'member_id=$memberId' +
          '&year=$currentYear' +
          '&month=$currentMonth';
      final response = await http.get(
        Uri.parse(url),
        headers: Utility.httpHeaders(prefs),
      );
      final json = jsonDecode(response.body);
      if (json['status']) {
        final data = json['result']['appointments'];
        for (int i = 0; i < data.length; i++) {
          final person = data[i]['person'];
          final image = person.length > 0
              ? person['image'].endsWith('/users/')
                  ? null
                  : person['image']
              : null;
          AppointmentModel item = new AppointmentModel();
          item.appointmentId = data[i]['id'];
          item.memberId = data[i]['member_id'];
          item.personId = data[i]['person_id'];
          item.personName = person.length > 0 ? person['firstname'] : 'N/A';
          item.image = image;
          item.status = data[i]['status'];
          item.startDate = DateTime.parse(data[i]['start_date_time']);
          item.endDate = DateTime.parse(data[i]['end_date_time']);
          item.meetingType = data[i]['meeting_type'];
          item.meetingLink = data[i]['meeting_url'];
          item.meetingPreference = data[i]['meetingPreference'];
          item.meetingPreferenceIcon = data[i]['meeting_preference_icon'];
          item.isVoted = data[i]['is_voted'];
          items.add(item);
        }
      }
    } catch (e) {
      print("Exception-API.getAppointments:" + e.toString());
    }
    appointmentList = items;
    notifyListeners();
  }

  Future<ResponseModel> saveAppointment(
    String personId,
    String startTime,
    String endTime,
    DateTime startDate,
    DateTime endDate,
    String meetingPreference,
    bool isOnline,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    ResponseModel result = new ResponseModel();
    try {
      final df = new DateFormat('yyyy-MM-dd');
      DateTime date = DateFormat.jm().parse(startTime);
      DateTime date2 = DateFormat.jm().parse(endTime);

      final response = await http.post(
        Uri.parse(Environment.Host + 'add_appointment'),
        headers: Utility.httpHeaders(prefs),
        body: jsonEncode(<String, String>{
          "member_id": prefs.getString(StorageKeys.MemberId),
          "person_id": personId,
          "date": df.format(DateTime.parse(startDate.toString())),
          "end_date": df.format(DateTime.parse(endDate.toString())),
          "time": DateFormat("Hms").format(date),
          "end_time": DateFormat("Hms").format(date2),
          "meeting_type": isOnline ? "Online" : "Offline",
          "meeting_url": "test link",
          "meetingPreference": isOnline ? "Online" : meetingPreference,
        }),
      );
      final obj = jsonDecode(response.body);
      result.status = obj["status"];
      result.message = obj["message"];
      if (result.status) {
        result.id = obj['result']['id'].toString();
      }
    } catch (e) {
      print("Exception-API.addAppointment:" + e.toString());
      result.message = 'Something went wrong';
    }
    return result;
  }

  void addAppointment(AppointmentModel item) {
    appointmentList.insert(0, item);
    notifyListeners();
  }

  void removeAppointment(String appointmentId) {
    appointmentList.removeWhere((e) => e.appointmentId == appointmentId);
    notifyListeners();
  }

  void updateAppointmentStatus(String id, String status) {
    appointmentList.forEach((e) {
      if (e.appointmentId == id) {
        e.status = status;
      }
    });
    notifyListeners();
  }

  void setCurrentYear(int year) {
    currentYear = year;
    notifyListeners();
  }

  void setCurrentMonth(int month) {
    currentMonth = month;
    notifyListeners();
  }

  void setTargetDateTime(DateTime date) {
    targetDateTime = date;
    notifyListeners();
  }

  void logout() {
    appointmentList = [];
    currentYear = DateTime.now().year;
    currentMonth = DateTime.now().month;
    targetDateTime = DateTime.now().add(Duration(minutes: 10));
  }
}
