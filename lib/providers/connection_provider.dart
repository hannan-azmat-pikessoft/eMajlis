import 'dart:convert';
import 'dart:io';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/environment.dart';
import 'package:emajlis/models/member_model.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionProvider extends ChangeNotifier {
  List<MemberModel> invitationList = [];
  List<MemberModel> friendList = [];
  String myMemberId = '';

  Future<void> loadConnections() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.post(
        Uri.parse(Environment.Host + 'social_new/get_friends'),
        headers: Utility.httpHeaders(prefs),
        body: jsonEncode(<String, String>{
          'member_id': prefs.getString(StorageKeys.MemberId),
        }),
      );

      final json = jsonDecode(response.body);
      if (json["status"]) {
        final ilist = json["result"]["unmatched"];
        invitationList.clear();
        for (int i = 0; i < ilist.length; i++) {
          final img = ilist[i]['image_url'].toString();
          MemberModel d = new MemberModel(
            id: ilist[i]['id'],
            firstName: ilist[i]['firstname'],
            lastName: ilist[i]['lastname'],
            imageUrl: img.endsWith('/users/') ? null : img,
            job: ilist[i]['jobtitle'],
            message: ilist[i]['message'],
          );
          invitationList.insert(0, d);
        }

        final flist = json["result"]["matched"];
        friendList.clear();
        for (int i = 0; i < flist.length; i++) {
          final img = flist[i]['image_url'].toString();
          MemberModel d = new MemberModel(
            id: flist[i]['id'],
            firstName: flist[i]['firstname'],
            lastName: flist[i]['lastname'],
            imageUrl: img.endsWith('/users/') ? null : img,
            job: flist[i]['jobtitle'],
          );
          friendList.insert(0, d);
        }
      }
    } on SocketException catch (e) {
      print("SocketException-loadConnections:" + e.toString());
    } on Exception catch (e) {
      print("Exception-API.loadConnections:" + e.toString());
    }
    notifyListeners();
  }

  Future<bool> addRemoveFriend(String id, int status, String message) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.post(
        Uri.parse(Environment.Host + 'social_new/add_remove_friend_new'),
        headers: Utility.httpHeaders(prefs),
        body: jsonEncode(<String, String>{
          "member_id": prefs.getString(StorageKeys.MemberId),
          "friend_id": id,
          "friendship_status": status.toString(),
          "message": message == "" ? "TEST" : message
        }),
      );
      debugPrint(response.body);
      return jsonDecode(response.body)["status"];
    } on SocketException catch (e) {
      print("SocketException-addRemoveFriend:" + e.toString());
    } on Exception catch (e) {
      print("Exception-API.addRemoveFriend:" + e.toString());
    }
    return false;
  }

  Future<bool> addRemoveInvitation(String friendId, int status) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.post(
        Uri.parse(Environment.Host + 'social_new/add_remove_friend_new'),
        headers: Utility.httpHeaders(prefs),
        body: jsonEncode(<String, String>{
          "member_id": prefs.getString(StorageKeys.MemberId),
          "friend_id": friendId,
          "friendship_status": status.toString(),
          "message": "Hi User, testing is going on!"
        }),
      );

      return jsonDecode(response.body)["status"];
    } on SocketException catch (e) {
      print("SocketException-removeInvitation:" + e.toString());
    } on Exception catch (e) {
      print("Exception-API.removeInvitation:" + e.toString());
    }
    return false;
  }

  Future<List<MemberModel>> getMemberConnections(String memberId) async {
    final prefs = await SharedPreferences.getInstance();
    List<MemberModel> items = [];
    try {
      final response = await http.post(
        Uri.parse(Environment.Host + 'social_new/get_friends'),
        headers: Utility.httpHeaders(prefs),
        body: jsonEncode(<String, String>{
          'member_id': '$memberId',
        }),
      );

      final json = jsonDecode(response.body);
      if (json["status"]) {
        final list = json["result"]["matched"];
        for (int i = 0; i < list.length; i++) {
          final img = list[i]['image_url'].toString();
          MemberModel d = new MemberModel(
            id: list[i]['id'],
            firstName: list[i]['firstname'],
            lastName: list[i]['lastname'],
            imageUrl: img.endsWith('/users/') ? null : img,
            job: list[i]['jobtitle'],
          );
          items.insert(0, d);
        }
      }
    } on SocketException catch (e) {
      print("SocketException-getFriends:" + e.toString());
    } on Exception catch (e) {
      print("Exception-API.getFriends:" + e.toString());
    }
    return items;
  }

  void removeFriend(String id) {
    if (friendList.any((e) => e.id == id)) {
      friendList.removeWhere((e) => e.id == id);
      notifyListeners();
    }
  }

  void removeInvitation(String id) {
    if (invitationList.any((e) => e.id == id)) {
      invitationList.removeWhere((e) => e.id == id);
      notifyListeners();
    }
  }

  void addFriend(MemberModel member) {
    if (!friendList.any((e) => e.id == member.id)) {
      friendList.insert(0, member);
      notifyListeners();
    }
  }

  void setMyMemberId(String id) {
    myMemberId = id;
  }
}
