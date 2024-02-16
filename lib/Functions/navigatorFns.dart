// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:url_launcher/url_launcher.dart';

Future<Null> NavPush(BuildContext context, screen) async {
  await Navigator.push(
      context, MaterialPageRoute(builder: (context) => screen));
}

Future<void> NavPushReplacement(BuildContext context, screen) {
  return Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => screen));
}

Future<void> navPopUntilPush(BuildContext context, Widget screen) {
  Navigator.popUntil(context, (route) => false);
  return NavPush(context, screen);
}

ShowSnackBar(
  BuildContext context, {
  required String content,
  bool isDanger = false,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      dismissDirection: DismissDirection.horizontal,
      shape: RoundedRectangleBorder(
        borderRadius: kRadius(10),
        side: BorderSide(
          color: isDanger ? Colors.red.shade900 : Colors.teal.shade800,
        ),
      ),
      content: Text(
        content,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDanger ? Colors.red.shade900 : Colors.teal.shade900,
        ),
      ),
      backgroundColor: isDanger ? Colors.red.shade100 : Light.profitCard,
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
