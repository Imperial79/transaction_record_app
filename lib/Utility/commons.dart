import 'package:flutter/material.dart';

const String appLogoPath = 'lib/assets/logo/logo.png';

Widget get height5 => SizedBox(height: 5);
Widget get height10 => SizedBox(height: 10);
Widget get height15 => SizedBox(height: 15);
Widget get height20 => SizedBox(height: 20);
Widget get width5 => SizedBox(width: 5);
Widget get width10 => SizedBox(width: 10);
Widget get width15 => SizedBox(width: 15);
Widget get width20 => SizedBox(width: 20);

Widget kHeight(double height) => SizedBox(height: height);
Widget kWidth(double width) => SizedBox(width: width);

BorderRadius kRadius(double radius) => BorderRadius.circular(radius);
