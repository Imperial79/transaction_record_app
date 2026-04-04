import 'package:flutter/material.dart';
import 'package:transaction_record_app/utility/newColors.dart';
import 'package:transaction_record_app/utility/constants.dart';

class KStatBox extends StatelessWidget {
  final String label;
  final double value;
  final bool isCurrency;
  final bool isPrimary;
  final bool isLoss;

  const KStatBox({
    super.key,
    required this.label,
    required this.value,
    this.isCurrency = true,
    this.isPrimary = false,
    this.isLoss = false,
  });

  @override
  Widget build(BuildContext context) {
    Color displayColor = isPrimary
        ? context.primaryColor
        : isLoss
        ? context.lossColor
        : context.textColor;

    return Container(
      padding: const EdgeInsets.all(16),
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
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: context.fadeTextColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCurrency ? "₹${kMoneyFormat(value)}" : value.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 16,
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
