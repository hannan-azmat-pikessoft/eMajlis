import 'dart:convert';
import 'dart:io';
import 'package:emajlis/environment.dart';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/models/member_model.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<MemberModel>> searchPeoples({
  String searchText,
  String emirate,
  String network,
  String industry,
  String sliderValue,
  int gender,
}) async {
  final prefs = await SharedPreferences.getInstance();
  List<MemberModel> items = [];
  try {
    final response = await http.post(
      Uri.parse(Environment.Host + 'general_new/search2'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(
        <String, String>{
          'member_id': prefs.getString(StorageKeys.MemberId),
          "emirates": emirate ?? "",
          "goals": network ?? "",
          "industry": industry ?? "",
          "gender": gender != null ? gender.toString() : "",
          "km": sliderValue ?? "",
          "name": searchText,
          "hashtags": "",
        },
      ),
    );

    final json = jsonDecode(response.body);
    final list = json["result"];
    for (int i = 0; i < list.length; i++) {
      items.add(
        new MemberModel(
          id: list[i]['user_info']['id'],
          firstName: list[i]['user_info']['firstname'],
          lastName: list[i]['user_info']['lastname'],
          imageUrl: list[i]['user_info']['image_url'],
        ),
      );
    }
  } on SocketException catch (e) {
    print("SocketException-searchPeoples:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.searchPeoples:" + e.toString());
  }
  return items;
}

Future<List<MemberModel>> searchPeoplesByIndustry(
  int industry,
  String searchText,
) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  List<MemberModel> items = [];
  try {
    final response = await http.post(
      Uri.parse(Environment.Host + 'general_new/search2'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(
        <String, String>{
          'member_id': prefs.getString(StorageKeys.MemberId),
          "emirates": "",
          "goals": "",
          "industry": "",
          "gender": "",
          "km": "",
          "name": searchText ?? "",
          "hashtags": "",
        },
      ),
    );
    final json = jsonDecode(response.body);
    final list = json["result"];
    for (int i = 0; i < list.length; i++) {
      if (list[i]['user_info']['work_industry_id'] == industry.toString()) {
        items.add(
          new MemberModel(
            id: list[i]['user_info']['id'],
            firstName: list[i]['user_info']['firstname'],
            lastName: list[i]['user_info']['lastname'],
            imageUrl: list[i]['user_info']['image_url'],
            job: list[i]['user_info']['jobtitle'],
          ),
        );
      }
    }
  } on SocketException catch (e) {
    print("SocketException-searchPeoples:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.searchPeoples:" + e.toString());
  }

  return items;
}
