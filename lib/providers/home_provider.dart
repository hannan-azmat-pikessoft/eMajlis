import 'dart:convert';
import 'dart:developer';
import 'package:emajlis/environment.dart';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/models/education_model.dart';
import 'package:emajlis/models/goal_model.dart';
import 'package:emajlis/models/industry_model.dart';
import 'package:emajlis/models/meeting_preference_model.dart';
import 'package:emajlis/models/notification_model.dart';
import 'package:emajlis/models/organization_model.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider extends ChangeNotifier {
  var itemlist;
  int profilesLength = 0;
  bool badge = false;
  bool isLoadingConnections = true;
  List<HomeModel> homelist = [];
  List<NotificationHistory> notificationList = [];
  String memberImage;
  String memberProfilePercentage;

  void setBadge(bool s) {
    this.badge = s;
    notifyListeners();
  }

  Future<Response> notification() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(
      Uri.parse(Environment.Host + 'general_new/notification_history'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "user_id": prefs.getString(StorageKeys.MemberId),
      }),
    );
    var d = jsonDecode(response.body)['result']["notification_history"];
    notificationList.clear();
    if (d != null) {
      for (int i = 0; i < d.length; i++) {
        notificationList.add(
          new NotificationHistory(
            createdDate: d[i]['created_date'],
            message: d[i]['message'],
            senderName: d[i]['sender_name'],
            title: d[i]['title'],
            senderId: d[i]['sender_id'],
            type: d[i]['type'],
            imageUrl: d[i]['image_url'],
          ),
        );
      }
    }
    notifyListeners();
    return response;
  }

  Future<Response> discover({String lat, String lang}) async {
    final utility = new Utility();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(StorageKeys.EncryptedToken);
    showLoadingConnections(true);
    final queryParams = {
      'match_percent': '0',
      'user_lat': lat,
      'user_lang': lang,
    };
    //  final Uri uri = Uri.https(authority, unencodedPath)
    final response = await http.get(
      Uri.parse(Environment.Host2).replace(queryParameters: queryParams),
      //'discover'
      headers: {"Authorization": "Token " + token},
      // Utility.httpHeaders(prefs),
      //   body: jsonEncode(<String, String>{
      //     "member_id": prefs.getString(StorageKeys.MemberId),
      //   }),
    );

    final json = jsonDecode(response.body);
    final data = json;
    //json["result"]["matched_profiles"];
    homelist.clear();
    for (var i = 0; i < data.length; i++) {
      homelist.add(new HomeModel(
          name: data[i]["user_info"]['firstname'],
          city: data[i]["user_info"]['city'],
          image: data[i]["user_info"]['image_url'],
          job: data[i]["user_info"]['jobtitle'],
          isSaved: data[i]["user_info"]['is_saved'],
          svc: data[i]["user_info"]['credit_score'],
          usermemberid: data[i]["user_info"]['id'].toString(),
          currentOrganization: data[i]["user_info"]["current_organization"],
          introduction:
              utility.utf8convert(data[i]["user_info"]["introduction"]),
          nearToMe: data[i]["near_to_me"]));
      final objGoal = data[i]["user_goal"];
      final objFavMeeting = data[i]["favorite_ways_meeting"];
      final objEducation = data[i]["education"];
      final objPreviousOrganization = data[i]["previous_organization"];
      if (homelist.length > i) {
        if (homelist[i].goalList == null) {
          homelist[i].goalList = [];
        }
        if (homelist[i].meetingPreferenceList == null) {
          homelist[i].meetingPreferenceList = [];
        }
        if (homelist[i].previousOrganizationList == null) {
          homelist[i].previousOrganizationList = [];
        }

        for (var j = 0; j < objGoal.length; j++) {
          final goalModel = new GoalModel(
            id: objGoal[j]["id"].toString(),
            name: objGoal[j]["name_en"],
          );
          homelist[i].goalList.add(goalModel);
        }
        for (var k = 0; k < objFavMeeting.length; k++) {
          final meetModel = new MeetingPreferenceModel(
            id: objFavMeeting[k]["id"].toString(),
            imageName: objFavMeeting[k]["image_name"],
            preferenceTypeName: objFavMeeting[k]["preference_type_en"],
          );
          homelist[i].meetingPreferenceList.add(meetModel);
        }
        if (objEducation.length > 0) {
          homelist[i].education = new EducationModel(
            city: objEducation[0]["city"],
            school: objEducation[0]["school"],
            degree: objEducation[0]["degree"],
          );
        }
        for (var p = 0; p < objPreviousOrganization.length; p++) {
          final preOrgModel = new OrganizationModel(
            organizationName: objPreviousOrganization[p]["organization_name"],
            designation: objPreviousOrganization[p]["designation"],
          );
          homelist[i].previousOrganizationList.add(preOrgModel);
        }
      }
    }
    profilesLength = homelist.length;
    notifyListeners();
    showLoadingConnections(false);
    return response;
  }

  void showLoadingConnections(bool isLoading) {
    isLoadingConnections = isLoading;
    notifyListeners();
  }
}

class HomeModel {
  String name;
  String image;
  String job;
  String usermemberid;
  String city;
  var svc;
  String currentOrganization;
  var isSaved;
  String introduction;
  List<GoalModel> goalList = [];
  List<IndustryModel> interestedIndustryList = [];
  List<MeetingPreferenceModel> meetingPreferenceList = [];
  List<OrganizationModel> previousOrganizationList = [];
  EducationModel education;
  double nearToMe;


  HomeModel(
      {this.name,
      this.image,
      this.job,
      this.usermemberid,
      this.isSaved,
      this.city,
      this.svc,
      this.introduction,
      this.nearToMe,
      this.goalList,
      this.education,
      this.interestedIndustryList,
      this.meetingPreferenceList,
      this.currentOrganization,
      this.previousOrganizationList,

      });
}
