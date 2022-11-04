import 'dart:convert';
import 'dart:io';
import 'package:emajlis/environment.dart';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/models/meeting_preference_model.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<MeetingPreferenceModel>> getMyMeetingPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  List<MeetingPreferenceModel> items = [];
  try {
    var response = await http.get(
      Uri.parse(Environment.Host +
          'meeting_preference?' +
          'member_id=' +
          prefs.getString(StorageKeys.MemberId)),
      headers: Utility.httpHeaders(prefs),
    );

    final obj = jsonDecode(response.body)['result'];
    if (obj.length > 0) {
      final itemdataMeet = obj['all_favorite_ways'];
      for (int i = 0; i < itemdataMeet.length; i++) {
        MeetingPreferenceModel cdata = MeetingPreferenceModel(
          id: itemdataMeet[i]['id'],
          preferenceTypeName: itemdataMeet[i]['preference_type_name'],
          imageName: itemdataMeet[i]['image_name'],
        );
        if (items.length != 0) {
          bool p = false;
          items.forEach((element) {
            if (element.id == cdata.id) {
              p = true;
            }
          });
          if (!p) {
            items.add(cdata);
          }
        } else {
          items.add(cdata);
        }
      }
    }
  } on SocketException catch (e) {
    print("SocketException-getMyMeetingPreferences:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.getMyMeetingPreferences:" + e.toString());
  }
  return items;
}

Future<List<MeetingPreferenceModel>> getMeetingPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  List<MeetingPreferenceModel> items = [];
  try {
    final response = await http.get(
      Uri.parse(Environment.Host + 'meeting_preferences'),
      headers: Utility.httpHeaders(prefs),
    );

    final json = jsonDecode(response.body);
    final list = json["result"]["all_favorite_ways"];
    for (int i = 0; i < list.length; i++) {
      MeetingPreferenceModel item = MeetingPreferenceModel(
        id: list[i]['id'],
        preferenceTypeName: list[i]['preference_type_name'],
        imageName: list[i]['image_name'],
        isSelected: list[i]['is_selected'],
      );
      items.add(item);
    }
  } on SocketException catch (e) {
    print("SocketException-getMeetingPreferences:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.getMeetingPreferences:" + e.toString());
  }
  return items;
}

Future<bool> saveMeetingPreferences(String selected) async {
  final prefs = await SharedPreferences.getInstance();
  try {
    var response = await http.post(
      Uri.parse(Environment.Host + 'save_meeting_preference'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "member_id": prefs.getString(StorageKeys.MemberId),
        "favorite_ways_to_meet": selected,
      }),
    );
    return jsonDecode(response.body)["status"];
  } on SocketException catch (e) {
    print("SocketException-saveMeetingPreferences:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.saveMeetingPreferences:" + e.toString());
  }
  return false;
}
