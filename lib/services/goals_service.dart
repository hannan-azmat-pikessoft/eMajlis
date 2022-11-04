import 'dart:convert';
import 'dart:io';
import 'package:emajlis/environment.dart';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/models/goal_model.dart';
import 'package:emajlis/models/response_model.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<GoalModel>> getGoals() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  List<GoalModel> items = [];
  try {
    final response = await http.post(
      Uri.parse(Environment.Host + 'goals'),
      headers: Utility.httpHeaders(prefs),
    );

    final json = jsonDecode(response.body);
    final list = json["result"]["goal"];
    for (int i = 0; i < list.length; i++) {
      GoalModel item = GoalModel(
        id: list[i]['id'],
        name: list[i]['name'],
        description: list[i]['description'],
        isSelected: list[i]['is_selected'],
      );
      items.add(item);
    }
  } on SocketException catch (e) {
    print("SocketException-getGoals:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.getGoals:" + e.toString());
  }
  return items;
}

Future<ResponseModel> saveGoals(String selected) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  ResponseModel result = new ResponseModel();
  try {
    var response = await http.post(
      Uri.parse(Environment.Host + 'save_goal'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "member_id": prefs.getString(StorageKeys.MemberId),
        "goal": selected,
        "goal_description": "test",
      }),
    );
    final obj = jsonDecode(response.body);
    result.status = obj["status"];
    result.message = obj["message"];
  } on SocketException catch (e) {
    print("SocketException-saveGoals:" + e.toString());
    result.message = 'No Internet Connection';
  } on Exception catch (e) {
    print("Exception-API.saveGoals:" + e.toString());
    result.message = 'Something went wrong';
  }
  return result;
}
