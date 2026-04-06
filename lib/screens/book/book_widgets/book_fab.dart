import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:transaction_record_app/helpers/navigation_helper.dart';
import 'package:transaction_record_app/screens/transaction/new_transaction_screen.dart';
import 'package:transaction_record_app/Utility/newColors.dart';

class BookFAB extends StatelessWidget {
  final String bookType;
  final String bookId;

  const BookFAB({
    super.key,
    required this.bookType,
    required this.bookId,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => navPush(
        context,
        NewTransactionScreen(
          bookType: bookType,
          bookId: bookId,
        ),
      ),
      backgroundColor: context.textColor,
      foregroundColor: context.scaffoldColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: const Icon(LucideIcons.plus),
    );
  }
}
