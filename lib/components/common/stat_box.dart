import 'package:flutter/material.dart';
import 'package:transaction_record_app/utility/newColors.dart';
import 'package:transaction_record_app/utility/constants.dart';

class KStatBox extends StatelessWidget {
  final String label;
  final double value;
  final bool isCurrency;
  final bool isPrimary;
  final bool isLoss;
  final bool small;
  final double? width;

  const KStatBox({
    super.key,
    required this.label,
    required this.value,
    this.isCurrency = true,
    this.isPrimary = false,
    this.isLoss = false,
    this.small = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color displayColor = isPrimary
        ? context.primaryColor
        : isLoss
        ? context.lossColor
        : context.textColor;

    return Container(
      width: width,
      padding: EdgeInsets.all(small ? 12 : APP_PADDING),
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border.all(color: context.textColor.lighten(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: small ? 8 : 9,
              fontWeight: FontWeight.w900,
              color: context.fadeTextColor,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: small ? 4 : 8),
          Text(
            isCurrency ? "₹${kMoneyFormat(value)}" : value.toStringAsFixed(0),
            style: TextStyle(
              fontSize: small ? 13 : 16,
              fontWeight: FontWeight.w900,
              color: displayColor,
              letterSpacing: -0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
