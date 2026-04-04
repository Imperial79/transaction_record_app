import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/utility/newColors.dart';

class KTransactMonthHeader extends StatelessWidget {
  final String month;
  final String date;

  const KTransactMonthHeader({
    super.key,
    required this.month,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = '';
    try {
      formattedDate = DateFormat(
        "dd MMMM, yyyy",
      ).format(DateFormat.yMMMMd().parse(date));
    } catch (e) {
      formattedDate = month;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(height: 2, width: 20, color: context.textColor),
              const SizedBox(width: 12),
              Text(
                formattedDate.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class KTransactDateHeader extends StatelessWidget {
  final String date;

  const KTransactDateHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    String formattedDate = '';
    try {
      formattedDate = DateFormat(
        "dd MMMM, yyyy",
      ).format(DateFormat.yMMMMd().parse(date));
    } catch (e) {
      formattedDate = date;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            height: 1,
            width: 15,
            color: context.fadeTextColor.lighten(0.3),
          ),
          const SizedBox(width: 10),
          Text(
            formattedDate.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: context.fadeTextColor,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
