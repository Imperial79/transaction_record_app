import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/components.dart';

import '../Utility/newColors.dart';

Widget kBackButton(
  context, {
  bool isSearching = false,
}) {
  isDark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    child: IconButton(
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
          !isSearching ? width10 : SizedBox(),
          !isSearching
              ? Text(
                  'Return',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                )
              : SizedBox(),
        ],
      ),
    ),
  );
}
