import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:transaction_record_app/utility/newColors.dart';
import 'package:transaction_record_app/utility/constants.dart';
import 'package:transaction_record_app/models/transactModel.dart';

class KTransactTile extends StatelessWidget {
  final Transact data;
  final VoidCallback onTap;

  const KTransactTile({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    bool isIncome = data.type.toLowerCase() == 'income';
    final balance = double.tryParse(data.amount) ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(APP_PADDING),
        decoration: BoxDecoration(
          color: context.scaffoldColor,
          border: Border.all(color: context.textColor.lighten(0.08), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isIncome ? context.profitColor : context.lossColor)
                    .lighten(0.1),
              ),
              child: Icon(
                isIncome ? LucideIcons.plus : LucideIcons.minus,
                size: 16,
                color: isIncome ? context.profitColor : context.lossColor,
              ),
            ),
            const SizedBox(width: APP_PADDING),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.source.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (data.description.isNotEmpty)
                    Text(
                      data.description.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: context.fadeTextColor,
                        letterSpacing: 1,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${kMoneyFormat(balance.abs())}",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: isIncome ? context.profitColor : context.lossColor,
                  ),
                ),
                Text(
                  "${data.transactMode} • ${data.time}".toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: context.fadeTextColor,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
