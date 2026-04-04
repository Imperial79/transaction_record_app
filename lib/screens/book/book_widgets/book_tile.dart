import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/utility/components.dart';
import 'package:transaction_record_app/helpers/navigation_helper.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import 'package:transaction_record_app/screens/book/due_book_screen.dart';
import 'package:transaction_record_app/screens/book/savings_book_screen.dart';
import 'package:transaction_record_app/screens/book/regular_book_screen.dart';
import '../../../utility/commons.dart';
import '../../../utility/constants.dart';
import '../../../utility/newColors.dart';

class BookTile extends ConsumerStatefulWidget {
  final BookModel book;
  final String title;
  final bool showDate;
  final void Function(String, String)? onDelete;
  const BookTile({
    super.key,
    required this.book,
    required this.title,
    this.onDelete,
    required this.showDate,
  });

  @override
  ConsumerState<BookTile> createState() => _BookTileState();
}

class _BookTileState extends ConsumerState<BookTile> {
  @override
  Widget build(BuildContext context) {
    var todayDate = DateFormat.yMMMMd().format(DateTime.now());
    String dateTitle = widget.title;

    bool isCompleted = false;
    if (widget.book.type == "regular") {
      isCompleted =
          widget.book.expense != 0 &&
          (widget.book.income == widget.book.expense);
    } else {
      isCompleted =
          widget.book.targetAmount != 0 &&
          (widget.book.income == widget.book.targetAmount);
    }

    bool isSavings = widget.book.type == "savings";
    Color typeColor = widget.book.type == 'due'
        ? Colors.blue
        : widget.book.type == 'savings'
        ? Colors.amber
        : context.textColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: widget.showDate,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 32, 0, 16),
            child: Row(
              children: [
                Text(
                  (dateTitle == todayDate ? 'Today' : dateTitle).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: context.textColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(child: Divider(color: context.textColor.lighten(0.1))),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (widget.book.type == "due") {
              navPush(context, DueBookScreen(bookData: widget.book));
            } else if (widget.book.type == "regular") {
              navPush(
                context,
                RegularBookScreen(
                  bookData: widget.book,
                  bookId: widget.book.bookId,
                  bookType: widget.book.type,
                ),
              );
            } else {
              navPush(context, SavingsBookScreen(bookData: widget.book));
            }
          },
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              elevation: 0,
              builder: (context) => _optionsModal(
                bookId: widget.book.bookId,
                bookName: widget.book.bookName,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              border: Border.all(
                color: context.textColor.lighten(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.book.type == 'due'
                            ? Icons.timer_outlined
                            : widget.book.type == 'savings'
                            ? Icons.savings_outlined
                            : Icons.receipt_long_outlined,
                        size: 20,
                        color: context.textColor,
                      ),
                      width15,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.book.bookName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.book.bookDescription.isNotEmpty)
                              Text(
                                widget.book.bookDescription.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: context.fadeTextColor,
                                  letterSpacing: 1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(color: context.textColor),
                          child: Text(
                            "SETTLED",
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: context.scaffoldColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (!isCompleted && !isSavings)
                    switch (widget.book.type) {
                      "due" => _dueStatsStyle(context),
                      "regular" => _regularStatsStyle(context),
                      _ => const SizedBox(),
                    },
                  if (isSavings) _savingsStatsStyle(context),
                  if (isCompleted && !isSavings) _completedStatsStyle(context),
                  const SizedBox(height: 20),
                  Divider(color: context.textColor.lighten(0.05)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.book.time.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: context.fadeTextColor,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        widget.book.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: typeColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _savingsStatsStyle(BuildContext context) {
    return _statColumn(
      label: "TOTAL BALANCE",
      amount: widget.book.income,
      color: Colors.amber,
    );
  }

  Widget _completedStatsStyle(BuildContext context) {
    return _statColumn(
      label: "FINAL SETTLE",
      amount: widget.book.income,
      color: context.profitColor,
    );
  }

  Widget _regularStatsStyle(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _statColumn(
            label: "INCOME",
            amount: widget.book.income,
            color: context.profitColor,
          ),
        ),
        Expanded(
          child: _statColumn(
            label: "EXPENSE",
            amount: widget.book.expense,
            color: context.lossColor,
          ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              final amount = widget.book.income - widget.book.expense;
              final isNegative = amount < 0;
              return _statColumn(
                label: "NET",
                amount: amount.abs(),
                color: isNegative ? context.lossColor : context.textColor,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _dueStatsStyle(BuildContext context) {
    double progress = widget.book.targetAmount != 0
        ? (widget.book.income / widget.book.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _statColumn(
                label: "DUE",
                amount: widget.book.targetAmount - widget.book.income,
                color: context.lossColor,
              ),
            ),
            Expanded(
              child: _statColumn(
                label: "GOAL",
                amount: widget.book.targetAmount,
                color: context.textColor,
              ),
            ),
          ],
        ),
        if (widget.book.targetAmount > 0) ...[
          const SizedBox(height: 16),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: context.textColor.lighten(0.05)),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(color: context.textColor),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _statColumn({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: context.fadeTextColor,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "₹${kMoneyFormat(amount)}",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _optionsModal({required String bookName, required String bookId}) {
    return Consumer(
      builder: (context, ref, child) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.scaffoldColor,
              border: Border.all(color: context.textColor.lighten(0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "BOOK OPTIONS",
                  style: TextStyle(
                    color: context.textColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                _modalTile(
                  icon: Icons.edit_outlined,
                  label: "RENAME BOOK",
                  onTap: () {
                    Navigator.pop(context);
                    showRenameBookModal(
                      context,
                      ref,
                      bookId: bookId,
                      initialName: bookName,
                    );
                  },
                ),
                _modalTile(
                  icon: Icons.delete_outline,
                  label: "DELETE BOOK",
                  isDanger: true,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onDelete!(bookId, bookName);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _modalTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDanger ? context.lossColor : context.textColor,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isDanger ? context.lossColor : context.textColor,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
