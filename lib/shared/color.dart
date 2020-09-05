import 'package:flutter/material.dart';

class AppColor {
  static final primaryColor = Color(0xff854dff);
  static final buttonColor = Color(0xff4f2272);
}

class AppShape {
  static final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0),
      side: BorderSide(color: AppColor.buttonColor));
}
