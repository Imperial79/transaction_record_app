import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Components/WIdgets.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Utility/KButton.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/KTextfield.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import 'package:transaction_record_app/screens/rootUI.dart';
import 'package:transaction_record_app/services/database.dart';
import 'package:transaction_record_app/services/user.dart';

import '../../Utility/commons.dart';

class New_Book_UI extends StatefulWidget {
  const New_Book_UI({Key? key}) : super(key: key);

  @override
  State<New_Book_UI> createState() => _New_Book_UIState();
}

class _New_Book_UIState extends State<New_Book_UI> {
  bool isLoading = false;
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedTimeStamp = DateTime.now();
  String _selectedTime =
      DateFormat().add_jm().format(DateTime.now()).toString();

  final _targetAmount = new TextEditingController();
  final _bookTitle = new TextEditingController(
      text: DateFormat('MMMM, yyyy').format(DateTime.now()));
  final _bookDescription = new TextEditingController();
  final dbMethod = DatabaseMethods();

  String selectedBookType = 'regular';

  void _createBook() async {
    FocusScope.of(context).unfocus();
    try {
      setState(() {
        isLoading = true;
      });
      if (_bookTitle.text.isNotEmpty) {
        String displayDate = DateFormat.yMMMMd().format(_selectedDate);
        String displayTime =
            DateFormat().add_jm().format(_selectedTimeStamp).toString();
        BookModel newBook = BookModel(
          bookId: "$_selectedTimeStamp",
          bookName: _bookTitle.text,
          bookDescription: _bookDescription.text,
          date: displayDate,
          expense: 0.0,
          income: 0.0,
          time: displayTime,
          type: selectedBookType,
          uid: globalUser.uid,
          targetAmount:
              selectedBookType == "due" ? double.parse(_targetAmount.text) : 0,
          createdAt: "$_selectedTimeStamp",
          users: [],
        );

        await FirebaseFirestore.instance
            .collection('transactBooks')
            .doc("$_selectedTimeStamp")
            .set(
              newBook.toMap(),
            );

        KSnackbar(context, content: 'Book Created');

        pageControllerGlobal.value.animateToPage(0,
            duration: Duration(milliseconds: 300), curve: Curves.ease);
      }
    } catch (e) {
      KSnackbar(context, content: "$e", isDanger: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _bookTitle.dispose();
    _bookDescription.dispose();
    _targetAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;
    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(15, 15, 15, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _bookTitle,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                ),
                cursorWidth: 1,
                cursorColor: isDark ? Colors.white : Colors.black,
                decoration: InputDecoration(
                  focusColor: isDark ? Colors.white : Colors.black,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Dark.card : Colors.black,
                      width: 2,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Dark.card : Colors.grey.shade300,
                    ),
                  ),
                  hintText: 'Book title',
                  hintStyle: TextStyle(
                    fontSize: 40,
                    color: isDark ? Dark.fadeText : Light.fadeText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              KTextfield.regular(
                isDark,
                controller: _bookDescription,
                hintText: 'Add description',
                maxLines: 10,
                minLines: 1,
                icon: Icon(
                  Icons.short_text_rounded,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              height10,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 13, vertical: 20),
                decoration: BoxDecoration(
                  color: isDark ? Dark.card : Light.card,
                  borderRadius: kRadius(15),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 20,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Created on',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    height10,
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: kRadius(10),
                              color: isDark ? Dark.scaffold : Light.scaffold,
                            ),
                            child: Text(
                              DateFormat.yMMMMd().format(_selectedDate),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: kRadius(10),
                            color: isDark ? Dark.scaffold : Light.scaffold,
                          ),
                          child: Text(
                            _selectedTime,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              height20,
              Text("Book Type"),
              height10,
              _bookTypeBtn(
                label: 'Regular Book',
                identifier: "regular",
              ),
              height10,
              _bookTypeBtn(
                label: 'Due Book',
                identifier: "due",
              ),
              if (selectedBookType == "due")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    kLabel("Target / Due Amount"),
                    KTextfield.regular(
                      isDark,
                      controller: _targetAmount,
                      fontSize: 30,
                      hintText: "1 - 10,000",
                      keyboardType: TextInputType.number,
                      icon: Text(
                        "INR",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: KButton.icon(isDark,
            onPressed: _createBook,
            icon: Icon(Icons.add_circle_outline),
            label: "Create Book"),
      ),
    );
  }

  Widget _bookTypeBtn({
    required String label,
    required String identifier,
  }) {
    bool isSelected = selectedBookType == identifier;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBookType = identifier;
        });
      },
      child: AnimatedSize(
        alignment: Alignment.topCenter,
        duration: Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: kRadius(15),
            color: isDark ? Dark.card : Light.card,
            border: Border.fromBorderSide(
              BorderSide(
                width: 2,
                color: isSelected
                    ? isDark
                        ? Dark.primaryAccent
                        : Light.primaryAccent
                    : isDark
                        ? Dark.card
                        : Light.card,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isSelected
                      ? isDark
                          ? Dark.primaryAccent
                          : Light.primaryAccent
                      : isDark
                          ? Dark.text
                          : Light.text,
                  radius: 5,
                ),
                width20,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                            color: isSelected
                                ? isDark
                                    ? Dark.primaryAccent
                                    : Light.primaryAccent
                                : isDark
                                    ? Dark.text
                                    : Light.text,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                      if (isSelected && selectedBookType == "due")
                        Text(
                          "Due book is used for tracking due amount lend to someone or chasing a target amount.",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: isDark ? Dark.fadeText : Light.fadeText,
                          ),
                        ),
                      if (isSelected && selectedBookType == "regular")
                        Text(
                          "Regular book is used for daily transaction audits.",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: isDark ? Dark.fadeText : Light.fadeText,
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
