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
    Color kCardColor = Dark.card;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: widget.showDate,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
            child: Text(
              dateTitle == todayDate ? 'Today' : dateTitle,
              style: TextStyle(
                fontSize: 13,
                color: context.fadeTextColor,
                fontWeight: FontWeight.w500,
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
          child: Card(
            margin: const .only(top: 10),
            shape: RoundedRectangleBorder(borderRadius: kRadius(10)),
            color: context.cardColor,
            child: Padding(
              padding: const .all(10.0),
              child: Row(
                crossAxisAlignment: .start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.book.bookName,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: .w500,
                                            letterSpacing: 1,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      width10,
                                      if (widget.book.users != null &&
                                          widget.book.users!.isNotEmpty)
                                        const CircleAvatar(
                                          radius: 12,
                                          child: Icon(Icons.groups_2, size: 12),
                                        ),
                                    ],
                                  ),
                                  Visibility(
                                    visible:
                                        widget.book.bookDescription.isNotEmpty,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        children: [
                                          Icon(Icons.note, size: 12),
                                          width5,
                                          Text(widget.book.bookDescription),
                                        ],
                                      ),
                                    ),
                                  ),
                                  height5,
                                  Row(
                                    children: [
                                      Icon(Icons.schedule, size: 12),
                                      width5,
                                      Text(
                                        widget.book.time,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isSavings)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: kRadius(7),
                                  color: context.scaffoldColor,
                                ),
                                child: Text(
                                  "₹ ${kMoneyFormat(widget.book.income)}",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                        height10,
                        if (!isCompleted && !isSavings)
                          switch (widget.book.type) {
                            "due" => _dueStatsStyle(context),
                            "regular" => _regularStatsStyle(context),
                            _ => SizedBox(),
                          },
                        if (isCompleted && !isSavings)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              height10,
                              const Text(
                                "Final Sum",
                                style: TextStyle(fontSize: 15),
                              ),
                              Text(
                                "INR ${kMoneyFormat(widget.book.income)}",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: context.isDarkMode
                                      ? Dark.onCompleteCard
                                      : Light.onCompleteCard,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Icon(
                      Icons.verified,
                      color: context.isDarkMode
                          ? Dark.onCompleteCard
                          : Light.onCompleteCard,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _regularStatsStyle(BuildContext context) {
    return Row(
      children: [
        _bookStats(
          index: 0,
          crossAlign: CrossAxisAlignment.start,
          labelColor: kColor(context).primary,
          amount: widget.book.income,
          label: 'INCOME',
          cardColor: kColor(context).primaryContainer,
          amountColor: kColor(context).primary,
        ),
        width5,
        _bookStats(
          index: 1,
          crossAlign: CrossAxisAlignment.center,
          amount: widget.book.expense,
          label: 'EXPENSE',
          cardColor: context.isDarkMode ? Colors.black : Colors.grey.shade300,
          labelColor: context.colorScheme.onSurface,
          amountColor: context.colorScheme.onSurface,
        ),
        width5,
        _bookStats(
          index: 2,
          crossAlign: CrossAxisAlignment.end,
          label: 'CURRENT',
          amount: widget.book.income - widget.book.expense,
          cardColor: kColor(context).tertiaryContainer,
          labelColor: kColor(context).tertiary,
          amountColor: kColor(context).tertiary,
        ),
      ],
    );
  }

  Widget _dueStatsStyle(BuildContext context) {
    return Row(
      children: [
        _bookStats(
          index: 0,
          crossAlign: CrossAxisAlignment.start,
          labelColor: kColor(context).primary,
          amount: widget.book.targetAmount - widget.book.income,
          label: 'DUE',
          cardColor: kColor(context).primaryContainer,
          amountColor: kColor(context).primary,
        ),
        width5,
        _bookStats(
          index: 2,
          crossAlign: CrossAxisAlignment.end,
          label: "TARGET",
          amount: widget.book.targetAmount,
          cardColor: kColor(context).tertiaryContainer,
          labelColor: kColor(context).tertiary,
          amountColor: kColor(context).tertiary,
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

  Widget _bookStats({
    required int index,
    double amount = 0,
    required Color cardColor,
    String label = "label",
    required Color labelColor,
    required Color amountColor,
    required CrossAxisAlignment crossAlign,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (amount < 0) {
      if (isDark) {
        amountColor = Dark.lossText;
        cardColor = Dark.lossCard.lighten(.2);
      } else {
        labelColor = Light.lossText;
        amountColor = Light.lossText;
        cardColor = Light.lossCard.lighten(.2);
      }
    }
    return Flexible(
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: cardColor, borderRadius: kRadius(7)),
        child: Column(
          crossAxisAlignment: crossAlign,
          children: [
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
            height5,
            Text(
              "₹${kMoneyFormat(amount)}",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: amountColor,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }
}
