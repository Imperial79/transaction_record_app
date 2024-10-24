import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/newColors.dart';

const String appLogoPath = 'lib/assets/logo/logo.png';

// Define common space constants
const double kSpace5 = 5.0;
const double kSpace10 = 10.0;
const double kSpace15 = 15.0;
const double kSpace20 = 20.0;

// Helper widgets for vertical and horizontal spacing
Widget kWidth(double height) => SizedBox(height: height);
Widget kHeight(double width) => SizedBox(width: width);

// Shortcuts for specific spacings
Widget get height5 => kWidth(kSpace5);
Widget get height10 => kWidth(kSpace10);
Widget get height15 => kWidth(kSpace15);
Widget get height20 => kWidth(kSpace20);
Widget get width5 => kHeight(kSpace5);
Widget get width10 => kHeight(kSpace10);
Widget get width15 => kHeight(kSpace15);
Widget get width20 => kHeight(kSpace20);

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
