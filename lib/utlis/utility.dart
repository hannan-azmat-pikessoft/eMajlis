import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/environment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utility {
  String token = '';
  static Map<String, String> httpHeaders(SharedPreferences prefs) {
    String token = '';
    if (prefs.containsKey(StorageKeys.EncryptedToken)) {
      token = prefs.getString(StorageKeys.EncryptedToken);
    }
    if (token != "") {
      return <String, String>{
        'Content-Type': 'application/json',
        'AUTH-API-KEY': token,
        'Authorization': '555666',
      };
    } else {
      return <String, String>{
        'Content-Type': 'application/json',
      };
    }
  }

  String utf8convert(String text) {
    List<int> bytes = text.toString().codeUnits;
    return utf8.decode(bytes);
  }

  static StreamTransformer transformer<T>(
          T Function(Map<String, dynamic> json) fromJson) =>
      StreamTransformer<QuerySnapshot, List<T>>.fromHandlers(
        handleData: (QuerySnapshot data, EventSink<List<T>> sink) {
          final snaps = data.docs.map((doc) => doc.data()).toList();
          final users = snaps.map((json) => fromJson(json)).toList();

          sink.add(users);
        },
      );

  static DateTime toDateTime(Timestamp value) {
    if (value == null) return null;

    return value.toDate();
  }

  static dynamic fromDateTimeToJson(DateTime date) {
    if (date == null) return null;

    return date.toUtc();
  }

  static String getShareText(String name) {
    String text = "Hello!";
    text += "\n\nThis profile I saw on eMajlis could be interesting for you: ";
    text += "\n\n$name";
    text += "\n\nGet the app and Start meeting inspiring people every day";
    text += "\n\nGoogle Play Store: " + Environment.AndroidLink;
    text += "\nApp Store: " + Environment.IosLink;
    return text;
  }
}
