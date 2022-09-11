import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

NavPush(BuildContext context, screen) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
}

NavPushReplacement(BuildContext context, screen) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => screen));
}

ShowSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.grey.shade700,
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
