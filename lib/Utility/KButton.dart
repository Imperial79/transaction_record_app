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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            icon,
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                color: isDark ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
