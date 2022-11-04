import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:another_flushbar/flushbar.dart';

void toastBuild(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.grey.withOpacity(.8),
    textColor: Colors.black,
    fontSize: 16.0,
  );
}

void toastBuildsec({String msg, int sec}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: sec ?? 1,
    backgroundColor: Colors.grey.withOpacity(.8),
    textColor: Colors.black,
    fontSize: 16.0,
  );
}

void warning(BuildContext context, String message) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    icon: Icon(
      Icons.warning,
      color: Colors.orange,
    ),
    title: 'Warning',
    message: message,
    duration: Duration(seconds: 2),
  )..show(context);
}

void error(BuildContext context, String message) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    icon: Icon(
      Icons.error,
      color: Colors.red,
    ),
    title: 'Error',
    message: message,
    duration: Duration(seconds: 2),
  )..show(context);
}

void success(BuildContext context, String message) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    icon: Icon(
      Icons.check,
      color: Colors.green,
    ),
    title: 'Success',
    message: message,
    duration: Duration(seconds: 2),
  )..show(context);
}

void somethingWentWrong(BuildContext context) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    icon: Icon(
      Icons.error,
      color: Colors.red,
    ),
    title: 'Error',
    message: "Something went wrong, please contact eMajlis Team",
    duration: Duration(seconds: 2),
  )..show(context);
}
