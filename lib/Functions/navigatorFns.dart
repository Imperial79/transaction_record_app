// ignore_for_file: non_constant_identifier_names
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
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

void KSnackbar(
  BuildContext context, {
  required String content,
  bool isDanger = false,
  bool showIcon = true,
  SnackBarAction? action,
}) {
  DelightToastBar.removeAll();
  DelightToastBar(
    position: DelightSnackbarPosition.top,
    autoDismiss: true,
    snackbarDuration: const Duration(seconds: 3),
    builder: (context) => ToastCard(
      shadowColor: Colors.transparent,
      color: isDanger
          ? isDark
              ? Dark.lossCard
              : Light.lossCard
          : isDark
              ? Dark.profitCard
              : Light.profitCard,
      leading: Icon(
        isDanger ? Icons.dangerous : Icons.verified,
        size: 28,
        color: isDanger
            ? isDark
                ? Dark.onLossCard
                : Light.onLossCard
            : isDark
                ? Dark.onProfitCard
                : Light.onProfitCard,
      ),
      title: Text(
        content,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: isDanger
              ? isDark
                  ? Dark.onLossCard
                  : Light.onLossCard
              : isDark
                  ? Dark.onProfitCard
                  : Light.onProfitCard,
        ),
      ),
    ),
  ).show(context);
}

launchTheUrl(Uri url) async {
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}
