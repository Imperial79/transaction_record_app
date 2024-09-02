import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Utility/KButton.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import 'package:transaction_record_app/screens/rootUI.dart';
import 'package:transaction_record_app/services/database.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/services/user.dart';

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

  final _bookTitle = TextEditingController(
      text: DateFormat('MMMM, yyyy').format(DateTime.now()));
  final _bookDescription = TextEditingController();
  final dbMethod = DatabaseMethods();

  String selectedBookType = 'regular';

  void _createBook() async {
    try {
      setState(() {
        isLoading = true;
      });
      if (_bookTitle.text.isNotEmpty) {
        String displayDate = DateFormat.yMMMMd().format(_selectedDate);
        String displayTime =
            DateFormat().add_jm().format(_selectedTimeStamp).toString();
        Book newBook = Book(
          bookId: "$_selectedTimeStamp",
          bookName: _bookTitle.text,
          bookDescription: _bookDescription.text,
          date: displayDate,
          expense: 0.0,
          income: 0.0,
          time: displayTime,
          type: selectedBookType,
          uid: globalUser.uid,
          createdAt: "$_selectedTimeStamp",
          users: [],
        );

        await FirebaseFirestore.instance
            .collection('transactBooks')
            .doc("$_selectedTimeStamp")
            .set(
              newBook.toMap(),
            );

        kSnackbar(context, content: 'Book Created');
        FocusScope.of(context).unfocus();
        pageControllerGlobal.value.animateToPage(0,
            duration: Duration(milliseconds: 300), curve: Curves.ease);
      }
    } catch (e) {
      kSnackbar(context, content: "$e", isDanger: true);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;
    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(15),
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 13),
                        decoration: BoxDecoration(
                          color: isDark ? Dark.card : Light.card,
                          borderRadius: kRadius(15),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.short_text_rounded,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            width10,
                            Expanded(
                              child: TextField(
                                controller: _bookDescription,
                                maxLines: 10,
                                minLines: 1,
                                cursorColor:
                                    isDark ? Dark.primary : Light.primary,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Add description',
                                  hintStyle: TextStyle(
                                    color:
                                        isDark ? Dark.fadeText : Light.fadeText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      height10,
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 13, vertical: 20),
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
                                      color: isDark
                                          ? Dark.scaffold
                                          : Light.scaffold,
                                    ),
                                    child: Text(
                                      DateFormat.yMMMMd().format(_selectedDate),
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
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
                                    color:
                                        isDark ? Dark.scaffold : Light.scaffold,
                                  ),
                                  child: Text(
                                    _selectedTime,
                                    style: TextStyle(
                                      color:
                                          isDark ? Colors.white : Colors.black,
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
                      bookTypeBtn(
                        label: 'Regular Book',
                        identifier: "regular",
                      ),
                      height10,
                      bookTypeBtn(
                        label: 'Due Book',
                        identifier: "due",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: KButton.icon(isDark, onPressed: () {
          _createBook();
        }, icon: Icon(Icons.add_circle_outline), label: "Create Book"),
        // ElevatedButton.icon(
        //   onPressed: () {
        //     createBook();
        //   },
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: isDark ? Dark.profitCard : Colors.black,
        //     padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        //     shape: RoundedRectangleBorder(
        //       borderRadius: kRadius(20),
        //     ),
        //   ),
        //   icon: Icon(
        //     Icons.add_circle,
        //     color: isDark ? Colors.black : Colors.white,
        //   ),
        //   label: Container(
        //     width: double.infinity,
        //     child: Text(
        //       'Create',
        //       style: TextStyle(
        //         fontSize: 20,
        //         color: isDark ? Colors.black : Colors.white,
        //       ),
        //     ),
        //   ),
        // ),
      ),
    );
  }

  Widget bookTypeBtn({
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
      child: Card(
        elevation: 0,
        // color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        color: isSelected
            ? isDark
                ? Dark.profitText
                : Light.profitCard
            : isDark
                ? Dark.card
                : Light.card,
        shape: RoundedRectangleBorder(
          borderRadius: kRadius(15),
          // side: BorderSide(
          //   color: isSelected
          //       ? isDark
          //           ? Dark.profitText
          //           : Light.profitText
          //       : Colors.transparent,
          // ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    isSelected ? Colors.black : Colors.grey.shade400,
                radius: 5,
              ),
              width10,
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.black : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
