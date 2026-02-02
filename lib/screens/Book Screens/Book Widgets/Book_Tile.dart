import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Helper/navigatorFns.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import '../../../Utility/KButton.dart';
import '../../../Utility/commons.dart';
import '../../../Utility/constants.dart';
import '../../../Utility/newColors.dart';
import '../Due_Book_UI.dart';
import '../Savings_Book_UI.dart';

class BookTile extends StatefulWidget {
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
  State<BookTile> createState() => _BookTileState();
}

class _BookTileState extends State<BookTile> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    var todayDate = DateFormat.yMMMMd().format(DateTime.now());

    String dateTitle = widget.title;

    // Change Card color -------------------->
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
        : context.profitColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: widget.showDate,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              dateTitle == todayDate ? 'Today' : dateTitle,
              style: TextStyle(
                fontSize: 12,
                color: context.fadeTextColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (widget.book.type == "due") {
              navPush(context, Due_Book_UI(bookData: widget.book));
            } else if (widget.book.type == "regular") {
              context.push("/book/regular/${widget.book.bookId}");
            } else {
              navPush(context, Savings_Book_UI(bookData: widget.book));
            }
          },
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              elevation: 0,
              builder: (context) {
                return _deleteModal(
                  isDark,
                  bookId: widget.book.bookId,
                  bookName: widget.book.bookName,
                );
              },
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: typeColor.withAlpha(isDark ? 40 : 20),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: typeColor.withAlpha(isDark ? 10 : 15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      widget.book.type == 'due'
                          ? Icons.pending_actions
                          : widget.book.type == 'savings'
                          ? Icons.savings_outlined
                          : Icons.account_balance_wallet_outlined,
                      size: 100,
                      color: typeColor.withAlpha(isDark ? 15 : 10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: typeColor.withAlpha(40),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.book.type == 'due'
                                    ? Icons.timer_outlined
                                    : widget.book.type == 'savings'
                                    ? Icons.savings
                                    : Icons.book_outlined,
                                size: 18,
                                color: typeColor,
                              ),
                            ),
                            width12,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.book.bookName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.book.bookDescription.isNotEmpty)
                                    Text(
                                      widget.book.bookDescription,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.fadeTextColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            if (widget.book.users != null &&
                                widget.book.users!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Icon(
                                  Icons.groups_rounded,
                                  size: 16,
                                  color: context.fadeTextColor,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (!isCompleted && !isSavings)
                          switch (widget.book.type) {
                            "due" => _dueStatsStyle(context),
                            "regular" => _regularStatsStyle(context),
                            _ => const SizedBox(),
                          },
                        if (isSavings) _savingsStatsStyle(context),
                        if (isCompleted && !isSavings)
                          _completedStatsStyle(context),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 12,
                                  color: context.fadeTextColor,
                                ),
                                width4,
                                Text(
                                  widget.book.time,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.fadeTextColor,
                                  ),
                                ),
                              ],
                            ),
                            if (isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: context.profitColor.withAlpha(40),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 12,
                                      color: context.profitColor,
                                    ),
                                    width4,
                                    Text(
                                      "Settled",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: context.profitColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _savingsStatsStyle(BuildContext context) {
    return Row(
      children: [
        _statColumn(
          label: "Total Balance",
          amount: widget.book.income,
          color: Colors.amber,
          icon: Icons.account_balance_wallet_rounded,
        ),
      ],
    );
  }

  Widget _completedStatsStyle(BuildContext context) {
    return Row(
      children: [
        _statColumn(
          label: "Final Settle",
          amount: widget.book.income,
          color: context.profitColor,
          icon: Icons.verified_rounded,
        ),
      ],
    );
  }

  Widget _regularStatsStyle(BuildContext context) {
    return Row(
      children: [
        _statColumn(
          label: "Income",
          amount: widget.book.income,
          color: context.profitColor,
          icon: Icons.arrow_downward_rounded,
        ),
        const Spacer(),
        _statColumn(
          label: "Expense",
          amount: widget.book.expense,
          color: context.lossColor,
          icon: Icons.arrow_upward_rounded,
        ),
        const Spacer(),
        _statColumn(
          label: "Current",
          amount: widget.book.income - widget.book.expense,
          color: Colors.blue,
          icon: Icons.wallet_rounded,
        ),
      ],
    );
  }

  Widget _dueStatsStyle(BuildContext context) {
    double progress = widget.book.targetAmount != 0
        ? (widget.book.income / widget.book.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    return Column(
      children: [
        Row(
          children: [
            _statColumn(
              label: "Due",
              amount: widget.book.targetAmount - widget.book.income,
              color: context.lossColor,
              icon: Icons.info_outline_rounded,
            ),
            const Spacer(),
            _statColumn(
              label: "Goal",
              amount: widget.book.targetAmount,
              color: Colors.blue,
              icon: Icons.flag_rounded,
            ),
          ],
        ),
        if (widget.book.targetAmount > 0) ...[
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? Colors.white10
                      : Colors.black.withAlpha(10),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 6,
                width: (MediaQuery.of(context).size.width - 56) * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.withAlpha(150), Colors.blue],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withAlpha(60),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _statColumn({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: context.fadeTextColor),
            width4,
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: context.fadeTextColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "₹${kMoneyFormat(amount)}",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _deleteModal(
    bool isDark, {
    required String bookName,
    required String bookId,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: context.scaffoldColor,
              borderRadius: kRadius(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: context.isDarkMode
                        ? Colors.grey.shade300
                        : Colors.black,
                    child: Icon(
                      Icons.menu_open_sharp,
                      color: context.isDarkMode ? Light.text : Dark.text,
                    ),
                  ),
                  height10,
                  Text(
                    "Book Options",
                    style: TextStyle(
                      color: context.colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  height20,
                  KButton.icon(
                    context,
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onDelete!(bookId, bookName);
                    },
                    icon: Icon(Icons.delete),
                    label: "Delete \"$bookName\" Book!",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
