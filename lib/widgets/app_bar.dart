import 'package:emajlis/utlis/theme.dart';
import 'package:flutter/material.dart';

AppBar simpleAppbar(
  context, {
  bool isNavBack = true,
  bool isAppTitle = true,
  String titleText,
  bool centerTitle = false,
  List<Widget> actions,
  Function onTap,
      bool isBackText = false,
}) {
  return AppBar(
    toolbarHeight: 65,
    backgroundColor: appBodyGrey,
    elevation: 0,
    leadingWidth: isNavBack ? 65 : 10,
    centerTitle: centerTitle,
    title:!isBackText? Text(
      isAppTitle ? titleText : "",
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ):GestureDetector(onTap: onTap ?? () => Navigator.of(context).pop(),child:Text(
      isAppTitle ? titleText : "",
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ) ,),
    leading: isNavBack
        ? GestureDetector(
            onTap: onTap ?? () => Navigator.of(context).pop(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                ),
                child:Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                )
              ),
            ),
          )
        : Container(),
    actions: actions,
  );
}
