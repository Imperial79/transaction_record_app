import 'package:flutter/material.dart';

final buttonGradient = LinearGradient(
  colors: [
    blackColor,
    Colors.grey.shade800,
    Colors.grey.shade900,
  ],
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
);

bool isDark = false;

//  common colors
// Color blackColor = Colors.black;
Color get blackColor => Colors.black;
Color whiteColor = Colors.white;
Color greyColorAccent = Colors.grey.shade300;
Color primaryColor = Color(0xFF04C282);

Color lightProfitColor = Color(0xFF04C282);
Color lightProfitColorAccent = Color(0xff98d3cb);
Color profitHighlightColor = Colors.greenAccent;
// Color primaryAccentColor = Colors.greenAccent;
Color lightScaffoldColor = Color.fromARGB(255, 247, 247, 247);
Color textLinkColor = Color(0xFF00A06B);
Color lossColor = Colors.red.shade700;
Color profitColor = Colors.green.shade700;

// dark colors
Color darkLossColorAccent = Color(0xffca705f);
Color darkProfitColorAccent = Color(0xff98d3cb);

Color get cardColordark => Colors.grey.shade800;
Color get cardColorlight => Colors.grey.shade200;
final Color darkScaffoldColor = Colors.grey.shade900;
final Color darkGreyColor = Colors.grey.shade600;
