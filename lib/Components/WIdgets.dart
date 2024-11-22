import 'package:flutter/material.dart';

import '../Utility/commons.dart';
import '../Utility/newColors.dart';

Widget kBackButton(
  context, {
  bool isSearching = false,
}) {
  bool isDark = Theme.of(context).brightness == Brightness.dark;
  return IconButton(
    color: isDark ? Dark.profitText : Light.profitText,
    onPressed: () {
      Navigator.pop(context);
    },
    icon: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.arrow_back,
          color: isDark ? Dark.profitCard : Colors.black,
        ),
        !isSearching ? width10 : const SizedBox(),
        !isSearching
            ? Text(
                'Return',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              )
            : const SizedBox(),
      ],
    ),
  );
}

Widget kLabel(String text,
    {double top = 20, double bottom = 15, double fontSize = 15}) {
  return Padding(
    padding: EdgeInsets.only(top: top, bottom: bottom),
    child: Text(
      text,
      style: TextStyle(fontSize: fontSize),
    ),
  );
}

Widget kAlertDialog(
  bool isDark, {
  required String title,
  required String subTitle,
  Widget? content,
  required List<Widget> actions,
}) {
  return Dialog(
    elevation: 0,
    backgroundColor: isDark ? Dark.card : Light.card,
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          height15,
          Text(
            subTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (content != null)
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: content,
            ),
          height15,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions,
          ),
        ],
      ),
    ),
  );
}
