import 'package:flutter/material.dart';
import 'package:transaction_record_app/utility/newColors.dart';

class KActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? borderColor;
  final double padding;
  final double iconSize;

  const KActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.borderColor,
    this.padding = 10,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor ?? context.textColor.lighten(0.1),
          ),
        ),
        child: Icon(icon, size: iconSize, color: color ?? context.textColor),
      ),
    );
  }
}
