import 'package:flutter/material.dart';

const String appLogoPath = 'lib/assets/logo/logo.png';

Widget get height5 => const SizedBox(height: 5);
Widget get height10 => const SizedBox(height: 10);
Widget get height15 => const SizedBox(height: 15);
Widget get height20 => const SizedBox(height: 20);
Widget get width5 => const SizedBox(width: 5);
Widget get width10 => const SizedBox(width: 10);
Widget get width15 => const SizedBox(width: 15);
Widget get width20 => const SizedBox(width: 20);

Widget kHeight(double height) => SizedBox(height: height);
Widget kWidth(double width) => SizedBox(width: width);

BorderRadius kRadius(double radius) => BorderRadius.circular(radius);
