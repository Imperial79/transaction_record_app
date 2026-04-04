import 'package:flutter/material.dart';
import 'package:transaction_record_app/utility/newColors.dart';
import 'package:transaction_record_app/utility/commons.dart';
import 'package:transaction_record_app/components/common/widgets.dart';

class KBookHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;

  const KBookHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: context.textColor.lighten(0.1)),
      ),
      child: Row(
        children: [
          kBackButton(context),
          width15,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: context.fadeTextColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          ...actions.expand((a) => [width10, a]).skip(1),
        ],
      ),
    );
  }
}
