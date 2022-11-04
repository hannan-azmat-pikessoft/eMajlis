import 'dart:convert';
import 'dart:io';
import 'package:emajlis/environment.dart';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/models/industry_model.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<IndustryModel>> getIndustries() async {
  final prefs = await SharedPreferences.getInstance();
  List<IndustryModel> items = [];
  try {
    var response = await http.get(
      Uri.parse(Environment.Host + 'industries'),
      headers: Utility.httpHeaders(prefs),
    );

    final json = jsonDecode(response.body);
    final list = json["result"]["industry"];
    for (int i = 0; i < list.length; i++) {
      IndustryModel cdata = IndustryModel(
        id: int.parse(list[i]['id']),
        name: list[i]['name'],
        isSelected: false,
      );
      items.add(cdata);
    }
  } on SocketException catch (e) {
    print("SocketException-getIndustries:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.getIndustries:" + e.toString());
  }
  return items;
}

Future<bool> saveWorkIndustry(int industryId) async {
  final prefs = await SharedPreferences.getInstance();
  try {
    var response = await http.post(
      Uri.parse(Environment.Host + 'save_work_industry'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "member_id": prefs.getString(StorageKeys.MemberId),
        "industry": industryId.toString(),
      }),
    );
    return jsonDecode(response.body)["status"];
  } on SocketException catch (e) {
    print("SocketException-saveWorkIndustry:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.saveWorkIndustry:" + e.toString());
  }
  return false;
}

Future<bool> saveIntrestedIndustries(String selected) async {
  final prefs = await SharedPreferences.getInstance();
  try {
    var response = await http.post(
      Uri.parse(Environment.Host + 'save_industries'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "member_id": prefs.getString(StorageKeys.MemberId),
        "industry": selected,
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
