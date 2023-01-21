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

//  common colors
// Color blackColor = Colors.black;
Color get blackColor => Colors.black;
Color whiteColor = Colors.white;
Color greyColorAccent = Colors.grey.shade300;
Color primaryColor = Color(0xFF04C282);
Color primaryAccentColor = Color(0xFF00FFAA);
Color bgColor = Color.fromARGB(255, 247, 247, 247);
Color textLinkColor = Color(0xFF00A06B);
Color lossColor = Colors.red.shade700;
Color profitColor = Colors.green.shade700;

// dark colors

final Color darkScaffoldColor = Colors.grey.shade900;
final Color darkGreyColor = Colors.grey.shade700;
final Color greyColorDarker = Colors.grey.shade800;
