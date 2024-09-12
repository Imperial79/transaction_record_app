import 'package:flutter/material.dart';

import 'components.dart';
import 'newColors.dart';

class KButton {
  static full(
    bool isDark, {
    required void Function()? onPressed,
    String label = "label",
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Dark.profitCard : Colors.black,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: kRadius(15),
        ),
      ),
      child: SizedBox(
        width: double.maxFinite,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20,
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  static icon(
    bool isDark, {
    required void Function()? onPressed,
    required Widget icon,
    String label = "label",
    Color? backgroundColor,
    Color? textColor,
    bool isOutlined = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: !isOutlined
            ? backgroundColor != null
                ? backgroundColor
                : isDark
                    ? Dark.profitCard
                    : Colors.black
            : Colors.transparent,
        side: BorderSide(
          color: isOutlined
              ? backgroundColor != null
                  ? backgroundColor
                  : isDark
                      ? Dark.profitCard
                      : Colors.black
              : Colors.transparent,
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: kRadius(15),
        ),
      ),
      child: SizedBox(
        width: double.maxFinite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            icon,
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                color: !isOutlined
                    ? textColor != null
                        ? textColor
                        : isDark
                            ? Colors.black
                            : Colors.white
                    : backgroundColor != null
                        ? backgroundColor
                        : isDark
                            ? Dark.profitCard
                            : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static text(bool isDark,
      {void Function()? onTap, String label = "label", double fontSize = 17}) {
    return InkWell(
      onTap: onTap,
      borderRadius: kRadius(100),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? Dark.profitText : Light.profitText,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
