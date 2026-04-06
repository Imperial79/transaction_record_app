import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../utility/newColors.dart';
import '../../Utility/constants.dart';

Widget kBackButton(BuildContext context) {
  return InkWell(
    onTap: () => Navigator.pop(context),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: context.textColor.lighten(0.1)),
      ),
      child: Icon(LucideIcons.arrowLeft, size: 20, color: context.textColor),
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
  Widget? child,
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
          if (child != null) ...[const SizedBox(height: 20), child],
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
class KPageHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  const KPageHeader({
    super.key,
    required this.title,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: APP_PADDING,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: context.textColor.lighten(0.1)),
      ),
      child: Row(
        children: [
          leading ??
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.arrowLeft, size: 20),
                color: context.textColor,
              ),
          const Spacer(),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: context.fadeTextColor,
            ),
          ),
          if (actions != null) ...actions! else const SizedBox(width: 48),
        ],
      ),
    );
  }
}
