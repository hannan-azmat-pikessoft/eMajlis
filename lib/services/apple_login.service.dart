import 'dart:convert';
import 'dart:io';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/environment.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<dynamic> getAppleLogin(String userId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    var response = await http.get(
      Uri.parse(Environment.Host + 'social_info/$userId?'),
      headers: Utility.httpHeaders(prefs),
    );
    if (response.statusCode == 200) {
      dynamic body = jsonDecode(response.body);
      return body['result'];
    }
  } on SocketException catch (e) {
    print("SocketException-checkAppleLogin:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.checkAppleLogin:" + e.toString());
  }
  return false;
}

Future<dynamic> saveAppleLogin(
    String userId, String emailId, String fullname) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    var response = await http.post(
      Uri.parse(Environment.Host + 'save_social_info'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "full_name": fullname,
        "email": emailId,
        "social_id": userId
      }),
    );
    if (response.statusCode == 200) {
      dynamic res = jsonDecode(response.body);
      return res['result'];
    }
  } on SocketException catch (e) {
    print("SocketException-saveAppleLogin:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.saveAppleLogin:" + e.toString());
  }
  return false;
}

Future<dynamic> checkAppleLogin(
    String userId, String emailId, String fullname) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (emailId != null) {
    prefs.setString(StorageKeys.AppleEmailID, emailId);
    prefs.setString(StorageKeys.AppleUserID, userId);
    prefs.setString(StorageKeys.AppleGivenName, fullname);

    await saveAppleLogin(userId, emailId, fullname);
  } else {
    if (prefs.containsKey(StorageKeys.AppleEmailID)) {
      emailId = prefs.getString(StorageKeys.AppleEmailID);
      fullname = prefs.getString(StorageKeys.AppleGivenName);
    }
    if (emailId == null) {
      final getRes = await getAppleLogin(userId);
      emailId = getRes['email'];
      fullname = getRes['full_name'];
    }
  }

  if (emailId != null) {
    return {'emailId': emailId, 'fullname': fullname, 'userId': userId};
  }
  return false;
}
