import 'package:emajlis/utlis/theme.dart';
import 'package:flutter/material.dart';

Container circularProgress({Color color}) {
  return Container(
    width: 50,
    height: 50,
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(color == null ? appBlack : color),
    ),
  );
}
Container circularProgressBig({Color color}) {
  return Container(
    width: 70,
    height: 70,
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(color == null ? appBlack : color),
    ),
  );
}

Container linearProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(appBlack),
    ),
  );
}
