import 'dart:convert';
import 'dart:io';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/environment.dart';
import 'package:emajlis/models/response_model.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> login(String email, String password, String firebaseToken) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.post(
      Uri.parse(Environment.Host + 'login'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "email": email,
        "password": password,
        "device_token": firebaseToken,
        "device_type": "web",
        "lat": "0.2358",
        "lang": "0.234589",
      }),
    );
    if (response.statusCode == 200) {
      final status = jsonDecode(response.body)["status"];
      if (status) {
        final memberId = jsonDecode(response.body)["result"]["profile"]["id"];
        final memberProfileImage = jsonDecode(response.body)["result"]["profile"]["image_url"];
        final token = jsonDecode(response.body)["result"]["token"];
        prefs.setString(StorageKeys.MemberId, memberId);
        prefs.setString(StorageKeys.MemberProfileImage, memberProfileImage);
        prefs.setString(StorageKeys.EncryptedToken, token);
        return true;
      }
      return false;
    }
  } on SocketException catch (e) {
    print("SocketException-login:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.login:" + e.toString());
  }
  return null;
}

Future<ResponseModel> socialLogin({
  String email,
  String socialType,
  String socialId,
  String firebaseToken,
}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  ResponseModel result = new ResponseModel();
  try {
    var response = await http.post(
      Uri.parse(Environment.Host + 'social_login'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "email": email,
        "device_token": firebaseToken,
        "social_id": socialId,
        "social_type": socialType,
        "device_type": "web",
        "lat": "0.2554",
        "lang": "0.3242",
      }),
    );
    final obj = jsonDecode(response.body);
    result.status = obj["status"];
    if (result.status) {
      result.hasAccount = obj["result"]["has_account"];

      if (!result.hasAccount) {
        return result;
      }

      final memberId = obj["result"]["profile"]["id"];
      final memberProfileImage = obj["result"]["profile"]["image_url"];
      final token = obj["result"]["token"];
      prefs.setString(StorageKeys.MemberId, memberId);
      prefs.setString(StorageKeys.MemberProfileImage, memberProfileImage);
      prefs.setString(StorageKeys.EncryptedToken, token);
    } else {
      result.message = obj["message"];
    }
  } on SocketException catch (e) {
    print("SocketException-socialLogin:" + e.toString());
    result.message = 'No Internet Connection';
  } on Exception catch (e) {
    print("Exception-API.socialLogin:" + e.toString());
    result.message = 'Something went wrong';
  }
  return result;
}

Future<bool> verifyEmail(String email) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    var response = await http.post(
      Uri.parse(Environment.Host + 'validate_email'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "email": email,
      }),
    );
    return jsonDecode(response.body)["result"]["is_validate"];
  } on SocketException catch (e) {
    print("SocketException-deleteMember:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.deleteMember:" + e.toString());
  }
  return null;
}

Future<bool> verifyMobile(String mobile) async {
  final prefs = await SharedPreferences.getInstance();
  try {
    var response = await http.post(
      Uri.parse(Environment.Host + 'validate_mobile'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "mobile": mobile,
      }),
    );
    return jsonDecode(response.body)["result"]["is_exist"];
  } on SocketException catch (e) {
    print("SocketException-verifyMobile:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.verifyMobile:" + e.toString());
  }
  return null;
}

Future<int> sendOTP(String email, String phoneNo) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    var response = await http.post(
      Uri.parse(Environment.Host + 'send_otp'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, dynamic>{
        "email": email,
        "phone_no": phoneNo,
      }),
    );

    final json = jsonDecode(response.body);
    return json["result"]["otp"];
  } on SocketException catch (e) {
    print("SocketException-sendOTP:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.sendOTP:" + e.toString());
  }
  return 0;
}

Future<bool> verifyOTP(String email, String phoneNo, String otpCode) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    var response = await http.post(
      Uri.parse(Environment.Host + 'verify_otp'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, dynamic>{
        "email": email,
        "phone_no": phoneNo,
        "otp_code": otpCode,
      }),
    );

    final json = jsonDecode(response.body);
    return json["status"];
  } on SocketException catch (e) {
    print("SocketException-sendOTP:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.sendOTP:" + e.toString());
  }
  return false;
}

Future<bool> logoutUser(String firebaseToken) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    var response = await http.post(
      Uri.parse(Environment.Host + 'logout'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, dynamic>{
        "member_id": prefs.getString(StorageKeys.MemberId),
        "user_id": prefs.getString(StorageKeys.MemberId),
        "device_token": firebaseToken,
      }),
    );

    if (response.statusCode == 200) {
      final status = jsonDecode(response.body)["status"];
      if (status) {
        return true;
      }
    }
  } catch (e) {
    print("Exception-API.logoutUser:" + e.toString());
  }
  return false;
}
