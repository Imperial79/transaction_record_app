import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Components/WIdgets.dart';
import 'package:transaction_record_app/Utility/KButton.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/KTextfield.dart';
import 'package:transaction_record_app/Utility/components.dart';
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
        "Due book is used for tracking due amount lend to someone or chasing a target amount.",
    "Savings": "Savings book is used for tracking collected/saved amount."
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
    bool isDark = Theme.of(context).brightness == Brightness.dark;
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
                  mainAxisSize: MainAxisSize.min,
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
              kCard(
                context,
                icon: Icons.schedule,
                title: "Created On",
                children: [
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
              height20,
              const Text("Book Type"),
              height10,
              MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                itemCount: bookTypeMap.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return _bookTypeBtn(
                    isDark,
                    title: bookTypeMap.keys.toList()[index],
                    subTitle: bookTypeMap.values.toList()[index],
                    identifier: bookTypeMap.keys.toList()[index].toLowerCase(),
                  );
                },
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

  Widget _bookTypeBtn(
    bool isDark, {
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
      child: AnimatedContainer(
        curve: Curves.ease,
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: kRadius(15),
          color: isDark ? Dark.card : Light.card,
          border: Border.fromBorderSide(
            BorderSide(
              width: 2,
              color: isActive
                  ? isDark
                      ? Dark.primaryAccent
                      : Light.profitText
                  : isDark
                      ? Dark.card
                      : Light.card,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isActive
                      ? isDark
                          ? Dark.primaryAccent
                          : Light.profitText
                      : isDark
                          ? Dark.fadeText
                          : Light.text,
                  radius: 5,
                ),
                width10,
                Text(
                  "$title Book",
                  style: TextStyle(
                    color: isActive
                        ? isDark
                            ? Dark.primaryAccent
                            : Light.profitText
                        : isDark
                            ? Dark.text
                            : Light.text,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            height10,
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
    );
  }
}
