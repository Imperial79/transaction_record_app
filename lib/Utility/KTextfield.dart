import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'commons.dart';
import 'newColors.dart';

class KTextfield {
  static TextStyle _titleTextStyle(bool isDark, double fontSize) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: isDark ? Colors.white : Colors.black,
    );
  }

  static TextStyle _hintTextStyle(
      bool isDark, double fontSize, FontWeight fontWeight) {
    return TextStyle(
      fontSize: fontSize,
      color: isDark ? Dark.fadeText : Light.fadeText,
      fontWeight: fontWeight,
    );
  }

  static InputDecoration _buildInputDecoration({
    required bool isDark,
    required String? hintText,
    Widget? prefix,
    double fontSize = 15,
    bool underlineBorder = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: _hintTextStyle(isDark, fontSize, FontWeight.w500),
      prefixIcon: prefix != null
          ? Padding(padding: const EdgeInsets.only(right: 10.0), child: prefix)
          : SizedBox(
              width: 10,
            ),
      prefixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
      border: underlineBorder ? null : InputBorder.none,
      focusedBorder: underlineBorder
          ? UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Dark.text : Light.text,
                width: 3,
              ),
            )
          : null,
      enabledBorder: underlineBorder
          ? UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Dark.card : Colors.grey.shade300,
              ),
            )
          : null,
    );
  }

  static Widget title(
    bool isDark, {
    TextEditingController? controller,
    int maxLines = 2,
    int minLines = 1,
    double fontSize = 40,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.words,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: _titleTextStyle(isDark, fontSize),
      cursorWidth: 1,
      maxLength: 15,
      minLines: minLines,
      maxLines: maxLines,
      cursorColor: isDark ? Colors.white : Colors.black,
      decoration: _buildInputDecoration(
        isDark: isDark,
        hintText: hintText,
        underlineBorder: true,
        fontSize: fontSize,
      ),
    );
  }

  static Widget regular(
    bool isDark, {
    TextEditingController? controller,
    Color? fieldColor,
    int maxLines = 10,
    int minLines = 1,
    double fontSize = 15,
    String? hintText,
    TextInputType? keyboardType,
    Widget? icon,
    Widget? prefix,
    EdgeInsetsGeometry? padding,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    List<TextInputFormatter>? inputFormatters,
  }) {
    bool isNumField = [
      TextInputType.number,
      TextInputType.phone,
    ].contains(keyboardType);

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: fieldColor ?? (isDark ? Dark.card : Light.card),
        borderRadius: kRadius(15),
      ),
      child: Row(
        children: [
          if (icon != null) icon,
          Flexible(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              minLines: minLines,
              keyboardType: keyboardType,
              inputFormatters: isNumField
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : inputFormatters,
              cursorColor: isDark ? Dark.primary : Light.primary,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
              textCapitalization: textCapitalization,
              decoration: _buildInputDecoration(
                isDark: isDark,
                hintText: hintText,
                prefix: prefix,
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
