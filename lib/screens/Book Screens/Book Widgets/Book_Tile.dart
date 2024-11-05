import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import '../../../Utility/KButton.dart';
import '../../../Utility/commons.dart';
import '../../../Utility/constants.dart';
import '../../../Utility/newColors.dart';
import '../Due_Book_UI.dart';
import '../Savings_Book_UI.dart';
import '../Regular_Book_UI.dart';

class BookTile extends StatefulWidget {
  final BookModel book;
  final String title;
  final bool showDate;
  final void Function(String, String)? onDelete;
  const BookTile(
      {super.key,
      required this.book,
      required this.title,
      this.onDelete,
      required this.showDate});

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
    Color textColor = Colors.black;
    bool isCompleted = false;

    if (widget.book.type == "regular") {
      isCompleted = widget.book.expense != 0 &&
          (widget.book.income == widget.book.expense);
    } else {
      isCompleted = widget.book.targetAmount != 0 &&
          (widget.book.income == widget.book.targetAmount);
    }

    if (isCompleted) {
      kCardColor = isDark ? Dark.completeCard : Light.completeCard;
      textColor = isDark ? Colors.white : Colors.black;
    } else {
      kCardColor = isDark ? Dark.card : Light.card;
      textColor = isDark ? Colors.white : Colors.black;
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
                letterSpacing: 2,
                wordSpacing: 5,
                color: isDark ? Dark.text : Light.text,
                fontWeight: FontWeight.w500,
                fontFamily: 'Serif',
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (widget.book.type == "due") {
              navPush(context, Due_Book_UI(bookData: widget.book));
            } else if (widget.book.type == "regular") {
              navPush(context, Regular_Book_UI(bookData: widget.book));
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
            margin: const EdgeInsets.only(top: 10),
            shape: RoundedRectangleBorder(
              borderRadius: kRadius(10),
            ),
            color: kCardColor,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCompleted)
                    Text(
                      "Completed",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            isDark ? Dark.onCompleteCard : Light.onCompleteCard,
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.book.bookName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1,
                                      color: textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                width10,
                                widget.book.users != null &&
                                        widget.book.users!.isNotEmpty
                                    ? const CircleAvatar(
                                        radius: 12,
                                        child: Icon(
                                          Icons.groups_2,
                                          size: 12,
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                            Visibility(
                              visible: widget.book.bookDescription.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.note,
                                      color: textColor,
                                      size: 12,
                                    ),
                                    width5,
                                    Text(
                                      widget.book.bookDescription,
                                      style: TextStyle(
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            height5,
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: textColor,
                                  size: 12,
                                ),
                                width5,
                                Text(
                                  widget.book.time,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isSavings)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              borderRadius: kRadius(7),
                              color: isDark ? Dark.scaffold : Light.scaffold),
                          child: Text(
                            "₹ ${kMoneyFormat(widget.book.income)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (!isCompleted && !isSavings)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: widget.book.type == "due"
                          ? Row(
                              children: [
                                _bookStats(
                                  index: 0,
                                  crossAlign: CrossAxisAlignment.start,
                                  labelColor:
                                      isDark ? Colors.white : Colors.black,
                                  amount: widget.book.targetAmount -
                                      widget.book.income,
                                  label: 'Due',
                                  cardColor: isDark
                                      ? Dark.completeCard
                                      : Light.completeCard,
                                  amountColor: isDark
                                      ? Dark.onCompleteCard
                                      : Light.onCompleteCard,
                                ),
                                width5,
                                _bookStats(
                                  index: 2,
                                  crossAlign: CrossAxisAlignment.end,
                                  label: "Target",
                                  amount: widget.book.targetAmount,
                                  cardColor: isDark
                                      ? const Color(0xFF0B2A43)
                                      : const Color.fromARGB(
                                          255, 197, 226, 250),
                                  labelColor: isDark
                                      ? Colors.white
                                      : Colors.blue.shade900,
                                  amountColor: isDark
                                      ? Colors.blue.shade100
                                      : Colors.blue.shade900,
                                ),
                              ],
                            )
                          : widget.book.type == "regular"
                              ? Row(
                                  children: [
                                    _bookStats(
                                      index: 0,
                                      crossAlign: CrossAxisAlignment.start,
                                      labelColor:
                                          isDark ? Colors.white : Colors.black,
                                      amount: widget.book.income,
                                      label: 'Income',
                                      cardColor: isDark
                                          ? const Color(0xFF223B05)
                                          : const Color(0xFFB5FFB7),
                                      amountColor: isDark
                                          ? Colors.lightGreenAccent
                                          : Colors.lightGreen.shade900,
                                    ),
                                    width5,
                                    _bookStats(
                                      index: 1,
                                      crossAlign: CrossAxisAlignment.center,
                                      amount: widget.book.expense,
                                      label: 'Expense',
                                      cardColor: isDark
                                          ? Colors.black
                                          : Colors.grey.shade300,
                                      labelColor:
                                          isDark ? Colors.white : Colors.black,
                                      amountColor:
                                          isDark ? Colors.white : Colors.black,
                                    ),
                                    width5,
                                    _bookStats(
                                      index: 2,
                                      crossAlign: CrossAxisAlignment.end,
                                      label: 'Current',
                                      amount: widget.book.income -
                                          widget.book.expense,
                                      cardColor: isDark
                                          ? const Color(0xFF0B2A43)
                                          : const Color.fromARGB(
                                              255, 197, 226, 250),
                                      labelColor: isDark
                                          ? Colors.white
                                          : Colors.blue.shade900,
                                      amountColor: isDark
                                          ? Colors.blue.shade100
                                          : Colors.blue.shade900,
                                    ),
                                  ],
                                )
                              : SizedBox(),
                    ),
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
                            color: isDark
                                ? Dark.onCompleteCard
                                : Light.onCompleteCard,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
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
              color: isDark ? Dark.scaffold : Light.scaffold,
              borderRadius: kRadius(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor:
                        isDark ? Colors.grey.shade300 : Colors.black,
                    child: Icon(
                      Icons.menu_open_sharp,
                      color: isDark ? Light.text : Dark.text,
                    ),
                  ),
                  height10,
                  Text(
                    "Book Options",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  height20,
                  KButton.icon(
                    isDark,
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
        cardColor = Dark.lossCard.withOpacity(.2);
      } else {
        labelColor = Light.lossText;
        amountColor = Light.lossText;
        cardColor = Light.lossCard.withOpacity(.2);
      }
    }
    return Flexible(
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: kRadius(7),
        ),
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
