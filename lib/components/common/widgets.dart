import 'package:flutter/material.dart';
import '../../utility/newColors.dart';

Widget kBackButton(BuildContext context) {
  return InkWell(
    onTap: () => Navigator.pop(context),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: context.textColor.lighten(0.1)),
      ),
      child: Icon(Icons.arrow_back, size: 20, color: context.textColor),
    ),
  );
}

Widget kLabel(String text, {double top = 20, double bottom = 15}) {
  return Padding(
    padding: EdgeInsets.only(top: top, bottom: bottom),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    ),
  );
}

Widget kAlertDialog(
  BuildContext context, {
  required String title,
  required String subTitle,
  Widget? content,
  required List<Widget> actions,
}) {
  return Dialog(
    elevation: 0,
    backgroundColor: context.scaffoldColor,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: context.textColor.lighten(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.fadeTextColor,
            ),
          ),
          if (content != null) ...[const SizedBox(height: 20), content],
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions
                .expand((a) => [const SizedBox(width: 12), a])
                .skip(1)
                .toList(),
          ),
        ],
      ),
    ),
  );
}
