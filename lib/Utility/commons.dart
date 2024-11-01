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

const SizedBox width5 = SizedBox(width: 5);
const SizedBox width10 = SizedBox(width: 10);
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
  bool isDark = Theme.of(context).brightness == Brightness.dark;
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

Widget kNoData(
  bool isDark, {
  required String title,
}) {
  return Center(
    child: Text(
      title,
      style: TextStyle(
          fontSize: 25,
          fontFamily: "Serif",
          color: isDark ? Dark.fadeText : Light.fadeText),
    ),
  );
}
