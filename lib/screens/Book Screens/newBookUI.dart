import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/services/database.dart';

class NewBookUI extends StatefulWidget {
  const NewBookUI({Key? key}) : super(key: key);

  @override
  State<NewBookUI> createState() => _NewBookUIState();
}

class _NewBookUIState extends State<NewBookUI> {
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedTimeStamp = DateTime.now();
  String _selectedTime =
      DateFormat().add_jm().format(DateTime.now()).toString();

  final bookTitleController = TextEditingController();
  final bookDescriptionController = TextEditingController();
  final dbMethod = DatabaseMethods();

  createBook() {
    try {
      if (bookTitleController.text.isNotEmpty) {
        String displayDate = DateFormat.yMMMMd().format(_selectedDate);
        String displayTime =
            DateFormat().add_jm().format(_selectedTimeStamp).toString();

        Map<String, dynamic> newBookMap = {
          'bookName': bookTitleController.text,
          'bookDescription': bookDescriptionController.text,
          'date': displayDate,
          'time': displayTime,
          'bookId': _selectedTimeStamp.toString(),
          'income': 0,
          'expense': 0,
        };
        dbMethod.createNewTransactBook(
            _selectedTimeStamp.toString(), newBookMap);
        ShowSnackBar(context, 'Book Created');
        Navigator.pop(context);
      }
    } catch (e) {
      ShowSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Spacer(),
                          // Expanded(
                          //   child: TransactTypeCard(
                          //     icon: Icons.file_download_outlined,
                          //     label: 'Income',
                          //   ),
                          // ),
                          // SizedBox(
                          //   width: 10,
                          // ),
                          // Expanded(
                          //   child: TransactTypeCard(
                          //     icon: Icons.file_upload_outlined,
                          //     label: 'Expense',
                          //   ),
                          // ),
                        ],
                      ),
                      TextField(
                        controller: bookTitleController,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                        cursorWidth: 1,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          focusColor: Colors.black,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          hintText: 'Book title',
                          hintStyle: TextStyle(
                            fontSize: 40,
                            color: Colors.grey.shade400,
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
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.short_text_rounded,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: TextField(
                                controller: bookDescriptionController,
                                maxLines: 10,
                                minLines: 1,
                                cursorColor: Colors.black,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Add description',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 13, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Created on',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: Text(
                                      DateFormat.yMMMMd().format(_selectedDate),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  ),
                                  child: Text(
                                    _selectedTime,
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
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30, bottom: 10),
              child: MaterialButton(
                onPressed: () {
                  createBook();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
                padding: EdgeInsets.zero,
                child: Ink(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 25,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade800,
                        Colors.grey.shade400,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Create',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
