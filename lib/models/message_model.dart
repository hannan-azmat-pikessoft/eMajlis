import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:flutter/material.dart';

class MessageModel {
  final int fromId;
  final int toId;
  final String message;
  final DateTime createdDate;

  const MessageModel({
    @required this.fromId,
    @required this.toId,
    @required this.message,
    @required this.createdDate,
  });

  static MessageModel fromJson(Map<String, dynamic> json) => MessageModel(
        fromId: json['from_id'],
        toId: json['to_id'],
        message: json['message'],
        createdDate: Utility.toDateTime(json['created_date']),
      );

  Map<String, dynamic> toJson() => {
        'from_id': fromId,
        'to_id': toId,
        'message': message,
        'created_date': Utility.fromDateTimeToJson(createdDate),
      };

  factory MessageModel.fromSnapshot(DocumentSnapshot snapshot) {
    return MessageModel.fromJson(snapshot.data() as Map<String, dynamic>);
  }
}
