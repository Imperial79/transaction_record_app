import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:transaction_record_app/Utility/components.dart';

import 'newColors.dart';

class KTextfield {
  static regular(bool isDark,
      {TextEditingController? controller,
      int maxLines = 10,
      int minLines = 1,
      double fontSize = 15,
      String? hintText,
      Widget? icon,
      TextInputType? keyboardType,
      EdgeInsetsGeometry? padding,
      TextCapitalization textCapitalization = TextCapitalization.sentences,
      List<TextInputFormatter>? inputFormatters}) {
    bool isNumField = false;
    if ([TextInputType.number, TextInputType.phone].contains(keyboardType)) {
      isNumField = true;
    }
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Dark.card : Light.card,
        borderRadius: kRadius(15),
      ),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: icon,
            ),
          Flexible(
            child: TextField(
              controller: controller,
              maxLines: 10,
              minLines: 1,
              keyboardType: keyboardType,
              inputFormatters: isNumField
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : inputFormatters,
              cursorColor: isDark ? Dark.primary : Light.primary,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
              textCapitalization: textCapitalization,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: fontSize,
                  color: isDark ? Dark.fadeText : Light.fadeText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
