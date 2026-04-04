import 'package:flutter/material.dart';

import 'commons.dart';
import 'newColors.dart';

class KButton {
  static ElevatedButton regular(
    BuildContext context, {
    void Function()? onPressed,
    String label = "label",
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        shape: RoundedRectangleBorder(borderRadius: kRadius(100)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          color: context.isDarkMode ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  static ElevatedButton full(
    BuildContext context, {
    void Function()? onPressed,
    String label = "label",
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: kRadius(15)),
      ),
      child: SizedBox(
        width: double.maxFinite,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20,
            color: context.isDarkMode ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  static ElevatedButton icon(
    BuildContext context, {
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
            ? backgroundColor ?? context.primaryColor
            : Colors.transparent,
        side: BorderSide(
          color: isOutlined
              ? backgroundColor ?? context.primaryColor
              : Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: kRadius(15)),
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
                    ? textColor ??
                          (context.isDarkMode ? Colors.black : Colors.white)
                    : backgroundColor ?? context.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static InkWell text(
    BuildContext context, {
    void Function()? onTap,
    String label = "label",
    double fontSize = 17,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: kRadius(100),
      child: Text(
        label,
        style: TextStyle(color: context.profitColor, fontSize: fontSize),
      ),
    );
  }

  static ElevatedButton outline(
    BuildContext context, {
    void Function()? onPressed,
    String label = "label",
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: context.textColor,
        side: BorderSide(color: context.textColor.withAlpha(40), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: kRadius(12)),
        elevation: 0,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          color: context.textColor,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
