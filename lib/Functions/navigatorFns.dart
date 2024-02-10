import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/colors.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:url_launcher/url_launcher.dart';

Future<Null> NavPush(BuildContext context, screen) async {
  await Navigator.push(
      context, MaterialPageRoute(builder: (context) => screen));
}

Future<Null> NavPushReplacement(BuildContext context, screen) async {
  await Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => screen));
}

ShowSnackBar(
  BuildContext context, {
  required String content,
  bool isDanger = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        content,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      backgroundColor: isDanger
          ? isDark
              ? DarkColors.lossCard
              : LightColors.lossCard
          : isDark
              ? DarkColors.profitCard
              : LightColors.profitCard,
    ),
  );
}

launchTheUrl(Uri url) async {
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}
