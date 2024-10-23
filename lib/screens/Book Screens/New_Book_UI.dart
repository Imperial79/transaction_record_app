import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Components/WIdgets.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Utility/KButton.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/KTextfield.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import 'package:transaction_record_app/services/database.dart';

import '../../Repository/auth_repository.dart';
import '../../Utility/commons.dart';

class New_Book_UI extends ConsumerStatefulWidget {
  const New_Book_UI({super.key});

  @override
  ConsumerState<New_Book_UI> createState() => _New_Book_UIState();
}

class _New_Book_UIState extends ConsumerState<New_Book_UI> {
  final Map<String, String> bookTypeMap = {
    "Regular": "Regular book is used for daily transaction audits.",
    "Due":
        "Due book is used for tracking due amount lend to someone or chasing a target amount."
  };

  bool isLoading = false;
  final DateTime _selectedDate = DateTime.now();
  final DateTime _selectedTimeStamp = DateTime.now();
  final String _selectedTime =
      DateFormat().add_jm().format(DateTime.now()).toString();

  final _targetAmount = TextEditingController();
  final _bookTitle = TextEditingController(
      text: DateFormat('MMMM, yyyy').format(DateTime.now()));
  final _bookDescription = TextEditingController();
  final dbMethod = DatabaseMethods();

  String selectedBookType = 'regular';

  void _createBook(String uid) async {
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
          uid: uid,
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

        ref.read(pageControllerProvider).animateToPage(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
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
    final user = ref.watch(userProvider);
    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KTextfield.title(
                isDark,
                controller: _bookTitle,
                hintText: "Book Title",
              ),
              TextButton(
                onPressed: () {
                  if (_bookTitle.text.isEmpty) {
                    setState(() {
                      _bookTitle.text =
                          DateFormat('MMMM, yyyy').format(DateTime.now());
                    });
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_mode_sharp,
                      size: 15,
                    ),
                    width5,
                    Text("Auto Generate"),
                  ],
                ),
              ),
              height15,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 20),
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
                        width10,
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
                            padding: const EdgeInsets.all(10),
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
                        width5,
                        Container(
                          padding: const EdgeInsets.all(10),
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
              const Text("Book Type"),
              height10,
              Column(
                children: List.generate(
                  bookTypeMap.length,
                  (index) => _bookTypeBtn(
                    title: bookTypeMap.keys.toList()[index],
                    subTitle: bookTypeMap.values.toList()[index],
                    identifier: bookTypeMap.keys.toList()[index].toLowerCase(),
                  ),
                ),
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
                      icon: const Text(
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: KButton.icon(
          isDark,
          onPressed: () {
            _createBook(user!.uid);
          },
          icon: const Icon(Icons.add_circle_outline),
          label: "Create Book",
        ),
      ),
    );
  }

  Widget _bookTypeBtn({
    required String title,
    required String subTitle,
    required String identifier,
  }) {
    bool isActive = selectedBookType == identifier;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBookType = identifier;
        });
      },
      child: AnimatedSize(
        alignment: Alignment.topCenter,
        duration: const Duration(milliseconds: 200),
        child: Container(
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: kRadius(15),
            color: isDark ? Dark.card : Light.card,
            border: Border.fromBorderSide(
              BorderSide(
                width: 2,
                color: isActive
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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isActive
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
                        "$title Book",
                        style: TextStyle(
                          color: isActive
                              ? isDark
                                  ? Dark.primaryAccent
                                  : Light.primaryAccent
                              : isDark
                                  ? Dark.text
                                  : Light.text,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      if (isActive)
                        Text(
                          subTitle,
                          style: TextStyle(
                            letterSpacing: .6,
                            color: isDark ? Dark.text : Light.text,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
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
