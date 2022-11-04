import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/environment.dart';
import 'package:emajlis/models/message_model.dart';
import 'package:emajlis/models/message_template_model.dart';
import 'package:emajlis/models/message_thread_model.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MessageApi {
  static Future<List<MessageTemplateModel>> getMessageTemplates() async {
    final utility = new Utility();
    final prefs = await SharedPreferences.getInstance();
    List<MessageTemplateModel> items = [];
    try {
      var response = await http.get(
        Uri.parse(Environment.Host + 'message/templates'),
        headers: Utility.httpHeaders(prefs),
      );

      final json = jsonDecode(response.body);
      final list = json['result'];
      for (int i = 0; i < list.length; i++) {
        MessageTemplateModel cdata = MessageTemplateModel(
          list[i]['id'],
          list[i]['code'],
          utility.utf8convert(list[i]['name'].toString()),
          list[i]['type_group_id'],
          list[i]['created_by'],
        );
        items.add(cdata);
      }
    } on SocketException catch (e) {
      print("SocketException-getMessageTemplates:" + e.toString());
    } on Exception catch (e) {
      print("Exception-API.getMessageTemplates:" + e.toString());
    }
    return items;
  }

  static Future<List<MessageThreadModel>> getMessageThreads() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<MessageThreadModel> items = [];
    try {
      final myMemberId = prefs.getString(StorageKeys.MemberId);
      final response = await http.get(
        Uri.parse(
            Environment.Host + 'message/get_messages?member_id=' + myMemberId),
        headers: Utility.httpHeaders(prefs),
      );

      final json = jsonDecode(response.body);
      final list = json['result'];
      for (int i = 0; i < list.length; i++) {
        if (list[i]['initiated_by'] != list[i]['initiated_with']) {
          int otherMemberId = 0;
          if (list[i]['initiated_by'] == myMemberId) {
            otherMemberId = int.parse(list[i]['initiated_with']);
          } else {
            otherMemberId = int.parse(list[i]['initiated_by']);
          }
          final String threadName =
              getThreadName(int.parse(myMemberId), otherMemberId);
          final lastChat = await lastMessage(threadName);
          if (lastChat != null) {
            MessageThreadModel item = MessageThreadModel(
              list[i]['message_id'],
              threadName,
              int.parse(myMemberId),
              otherMemberId,
              list[i]['sender_name'],
              list[i]['profile_pic'],
              0,
              lastChat.message,
              lastChat.createdDate,
            );
            items.add(item);
          }
        }
      }
    } on SocketException catch (e) {
      print("SocketException-getMessageThreads:" + e.toString());
    } on Exception catch (e) {
      print("Exception-API.getMessageThreads:" + e.toString());
    }

    return items;
  }

  static Future<bool> saveMessage(String toId, String message) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String fromId = prefs.getString(StorageKeys.MemberId);
      MessageApi.sendMessage(int.parse(fromId), int.parse(toId), message);

      final response = await http.post(
        Uri.parse(Environment.Host + 'message/send'),
        headers: Utility.httpHeaders(prefs),
        body: jsonEncode(<String, String>{
          "initiated_by": fromId,
          "initiated_with": toId,
          "message": message,
        }),
      );

      final json = jsonDecode(response.body);
      return json["status"];
    } on SocketException catch (e) {
      print("SocketException-saveMessage:" + e.toString());
    } on Exception catch (e) {
      print("Exception-API.saveMessage:" + e.toString());
    }

    return null;
  }

  static Future sendMessage(int fromId, int toId, String message) async {
    final MessageModel newMessage = MessageModel(
      fromId: fromId,
      toId: toId,
      message: message,
      createdDate: DateTime.now(),
    );
    final String threadName = getThreadName(fromId, toId);

    final CollectionReference collection =
        FirebaseFirestore.instance.collection('threads');
    final DocumentReference reference =
        collection.doc(threadName).collection('messages').doc();

    await reference
        .set(newMessage.toJson())
        .whenComplete(() => print("Added"))
        .catchError((e) => print(e));
  }

  static Stream<QuerySnapshot> getMessages(String threadName) =>
      FirebaseFirestore.instance
          .collection('threads')
          .doc(threadName)
          .collection('messages')
          .orderBy('created_date', descending: true)
          .snapshots();

  static Future<MessageModel> lastMessage(String threadName) async {
    final item = await FirebaseFirestore.instance
        .collection('threads')
        .doc(threadName)
        .collection('messages')
        .orderBy('created_date', descending: true)
        .get();
    if (item.docs.length > 0) {
      final message =
          item.docs.map((data) => MessageModel.fromSnapshot(data)).first;
      return message;
    }
    return null;
  }

  static String getThreadName(int fromId, int toId) {
    String threadName = '';
    if (fromId < toId) {
      threadName += fromId.toString() + '_X_' + toId.toString();
    } else {
      threadName += toId.toString() + '_X_' + fromId.toString();
    }
    return threadName;
  }

  static Future<bool> deleteMessage(String messageId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(
        Uri.parse(Environment.Host +
            'message/delete_message?message_id=' +
            messageId),
        headers: Utility.httpHeaders(prefs),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['result'];
        print(data);
        return true;
      }
    } on SocketException catch (e) {
      print("SocketException-getMessageThreads:" + e.toString());
    } on Exception catch (e) {
      print("Exception-API.getMessageThreads:" + e.toString());
    }

    return false;
  }
}
