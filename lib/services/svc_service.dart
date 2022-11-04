import 'dart:convert';
import 'package:emajlis/environment.dart';
import 'package:emajlis/models/svc_score_model.dart';
import 'package:emajlis/models/upvotes_model.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SVCService {
  static Future<dynamic> getUpvotesDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final response = await http.get(
      Uri.parse(Environment.Host + 'general_new/upvotes_detail'),
      headers: Utility.httpHeaders(prefs),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      UpvotesModelClass details = UpvotesModelClass.fromJson(data);
      return details;
    } else {
      return null;
    }
  }

  static Future<bool> saveUpvoteScore(
    String givenTo,
    String givenBy,
    List<String> levels,
    String svcScore,
    String meetId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final body = jsonEncode(<String, dynamic>{
        "credit_score_given_to": givenTo,
        "credit_score_given_by": givenBy,
        "level": levels,
        "added_svc": svcScore,
        "appointment_id": meetId
      });
      final response = await http.post(
        Uri.parse(Environment.Host + 'profile_new/save_upvote_score_svc'),
        headers: Utility.httpHeaders(prefs),
        body: body,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['status'];
      }
    } catch (e) {
      print("Exception-API.saveUpvoteScore:" + e.toString());
    }
    return null;
  }

  static getSVCScore(id) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(
        Uri.parse(Environment.Host +
            'profile_new/upvote_score_svc_by_member?' +
            'member_id=$id'),
        headers: Utility.httpHeaders(prefs),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SVCScoreModelClass details = SVCScoreModelClass.fromJson(data);
        return details;
      }
    } catch (e) {
      print("Exception-API.getSVCScore:" + e.toString());
    }
    return null;
  }
}
