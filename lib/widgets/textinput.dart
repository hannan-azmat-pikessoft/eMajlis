import 'package:emajlis/utlis/theme.dart';
import 'package:flutter/material.dart';

InputDecoration inputDecoration(labelText, {hintText}) {
  return InputDecoration(
    counterText: '',
    filled: true,
    fillColor: appDarkGrey,
    labelText: labelText,
    hintText: hintText,
    labelStyle: TextStyle(
      fontSize: 16,
      color: appGrey3,
    ),
    border: outlineInputBorder(),
    enabledBorder: outlineInputBorder(),
    focusedBorder: outlineInputBorder(),
  );
}

OutlineInputBorder outlineInputBorder() {
  return new OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(
      color: appGrey3,
    ),
  );
}

InputDecoration inputDecoration2({labelText, hintText, prefixtxt}) {
  return InputDecoration(
    prefixText: prefixtxt,
    counterText: '',
    filled: false,
    fillColor: appDarkGrey,
    labelText: labelText,
    labelStyle: TextStyle(
      fontSize: 16,
      color: appgreydate,
    ),
    // helperText: hintText,

    hintText: hintText,
    hintStyle: TextStyle(
      fontSize: 16,
      color: appgreydate,
    ),
    border: outlineInputBorder2(),
    enabledBorder: outlineInputBorder2(),
    focusedBorder: outlineInputBorder2(),
  );
}

OutlineInputBorder outlineInputBorder2() {
  return new OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    borderSide: BorderSide(
      color: appgreydate,
    ),
  );
}

InputDecoration inputDecoration3({labelText, hintText, prefixtxt}) {
  return InputDecoration(
    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
    prefixText: prefixtxt,
    counterText: '',
    filled: false,
    fillColor: appDarkGrey,
    labelText: labelText,
    labelStyle: TextStyle(
      fontSize: 16,
      color: appgreydate,
    ),
    // helperText: hintText,

    hintText: hintText,
    hintStyle: TextStyle(
      fontSize: 16,
      color: appgreydate,
    ),
    border: outlineInputBorder2(),
    enabledBorder: outlineInputBorder2(),
    focusedBorder: outlineInputBorder2(),
  );
}

OutlineInputBorder outlineInputBorder3() {
  return new OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    borderSide: BorderSide(
      color: appgreydate,
    ),
  );
}
