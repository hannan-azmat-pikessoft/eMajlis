import 'dart:convert';
import 'dart:io';
import 'package:emajlis/environment.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> deleteAppointment(String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    var response = await http.post(
      Uri.parse(Environment.Host + 'delete_appointment'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{"id": id}),
    );
    return jsonDecode(response.body)["status"];
  } on SocketException catch (e) {
    print("SocketException-deleteAppointment:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.deleteAppointment:" + e.toString());
  }
  return false;
}

Future<bool> acceptCancelAppointment(String id, String status) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    var response = await http.post(
      Uri.parse(Environment.Host + 'accept_appointment'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "id": id,
        "status": status,
      }),
    );
    return jsonDecode(response.body)["status"];
  } on SocketException catch (e) {
    print("SocketException-acceptCancelAppointment:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.acceptCancelAppointment:" + e.toString());
  }
  return false;
}
