import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/newColors.dart';

const String appLogoPath = 'lib/assets/logo/logo.png';

// Helper widgets for vertical and horizontal spacing
Widget kWidth(double width) => SizedBox(width: width);
Widget kHeight(double height) => SizedBox(height: height);

// Shortcuts for specific spacings
const SizedBox height5 = SizedBox(height: 5);
const SizedBox height10 = SizedBox(height: 10);
const SizedBox height15 = SizedBox(height: 15);
const SizedBox height20 = SizedBox(height: 20);
const SizedBox height50 = SizedBox(height: 50);

const SizedBox width4 = SizedBox(width: 4);
const SizedBox width5 = SizedBox(width: 5);
const SizedBox width10 = SizedBox(width: 10);
const SizedBox width12 = SizedBox(width: 12);
const SizedBox width15 = SizedBox(width: 15);
const SizedBox width20 = SizedBox(width: 20);

// Border radius utility
BorderRadius kRadius(double radius) => BorderRadius.circular(radius);

void KSnackbar(
  BuildContext context, {
  required String content,
  bool isDanger = false,
  bool showIcon = true,
  SnackBarAction? action,
}) {
  DelightToastBar(
    position: DelightSnackbarPosition.top,
    autoDismiss: true,
    snackbarDuration: const Duration(seconds: 3),
    builder: (context) => ToastCard(
      shadowColor: Colors.transparent,
      color: isDanger ? context.lossCardColor : context.profitCardColor,
      leading: Icon(
        isDanger ? Icons.dangerous : Icons.verified,
        size: 28,
        color: isDanger ? context.lossColor : context.profitColor,
      ),
      title: Text(
        content,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: isDanger ? context.lossColor : context.profitColor,
        ),
      ),
    ),
  ).show(context);
}

Widget kNoData(BuildContext context, {required String title}) {
  return Center(
    child: Text(
      title,
      style: TextStyle(
        fontSize: 25,
        fontFamily: "Serif",
        color: context.fadeTextColor,
      ),
    ),
  );
}
