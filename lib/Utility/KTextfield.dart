import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'commons.dart';
import 'newColors.dart';

class KTextfield {
  static TextStyle _titleTextStyle(BuildContext context, double fontSize) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: context.colorScheme.onSurface,
    );
  }

  static TextStyle _hintTextStyle(
      BuildContext context, double fontSize, FontWeight fontWeight) {
    return TextStyle(
      fontSize: fontSize,
      color: context.fadeTextColor,
      fontWeight: fontWeight,
    );
  }

  static InputDecoration _buildInputDecoration({
    required BuildContext context,
    required String? hintText,
    Widget? prefix,
    double fontSize = 15,
    bool underlineBorder = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: _hintTextStyle(context, fontSize, FontWeight.w500),
      prefixIcon: prefix != null
          ? Padding(padding: const EdgeInsets.only(right: 10.0), child: prefix)
          : const SizedBox(
              width: 10,
            ),
      prefixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
      border: underlineBorder ? null : InputBorder.none,
      focusedBorder: underlineBorder
          ? UnderlineInputBorder(
              borderSide: BorderSide(
                color: context.primaryColor,
                width: 3,
              ),
            )
          : null,
      enabledBorder: underlineBorder
          ? UnderlineInputBorder(
              borderSide: BorderSide(
                color: context.isDarkMode ? Colors.white24 : Colors.black12,
              ),
            )
          : null,
    );
  }

  static Widget title(
    BuildContext context, {
    TextEditingController? controller,
    int maxLines = 2,
    int minLines = 1,
    double fontSize = 40,
    int? maxLength = 15,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.words,
    List<TextInputFormatter>? inputFormatters,
    void Function(String val)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: _titleTextStyle(context, fontSize),
      cursorWidth: 1,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      cursorColor: context.colorScheme.onSurface,
      decoration: _buildInputDecoration(
        context: context,
        hintText: hintText,
        underlineBorder: false,
        fontSize: fontSize,
      ).copyWith(counterText: ""),
      onChanged: onChanged,
    );
  }

  static Widget regular(
    BuildContext context, {
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
        color: fieldColor ?? context.cardColor,
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
              cursorColor: context.primaryColor,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
              textCapitalization: textCapitalization,
              decoration: _buildInputDecoration(
                context: context,
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
