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
        style: TextStyle(
          color: context.profitColor,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
