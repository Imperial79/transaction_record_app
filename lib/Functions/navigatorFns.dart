// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> navPush(BuildContext context, screen) async {
  await Navigator.push(
      context, MaterialPageRoute(builder: (context) => screen));
}

Future<void> NavPushReplacement(BuildContext context, screen) {
  return Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => screen));
}

Future<void> navPopUntilPush(BuildContext context, Widget screen) {
  Navigator.popUntil(context, (route) => false);
  return navPush(context, screen);
}

launchTheUrl(Uri url) async {
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}
