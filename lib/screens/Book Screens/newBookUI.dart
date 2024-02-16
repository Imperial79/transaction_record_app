import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Utility/customScaffold.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/screens/rootUI.dart';
import 'package:transaction_record_app/services/database.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/services/user.dart';
import '../../Utility/sdp.dart';

class NewBookUI extends StatefulWidget {
  const NewBookUI({Key? key}) : super(key: key);

  @override
  State<NewBookUI> createState() => _NewBookUIState();
}

class _NewBookUIState extends State<NewBookUI> {
  bool isLoading = false;
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedTimeStamp = DateTime.now();
  String _selectedTime =
      DateFormat().add_jm().format(DateTime.now()).toString();

  final bookTitleController = TextEditingController(
      text: DateFormat('MMMM, yyyy').format(DateTime.now()));
  final bookDescriptionController = TextEditingController();
  final dbMethod = DatabaseMethods();

  String selectedBookType = 'regular';

  void createBook() async {
    try {
      setState(() {
        isLoading = true;
      });
      if (bookTitleController.text.isNotEmpty) {
        String displayDate = DateFormat.yMMMMd().format(_selectedDate);
        String displayTime =
            DateFormat().add_jm().format(_selectedTimeStamp).toString();

        Map<String, dynamic> newBookMap = {
          'bookName': bookTitleController.text,
          'bookDescription': bookDescriptionController.text,
          'date': displayDate,
          'time': displayTime,
          'bookId': "$_selectedTimeStamp",
          'income': 0,
          'expense': 0,
          'type': selectedBookType,
          'users': [],
          'uid': globalUser.uid,
        };
        await FirebaseFirestore.instance
            .collection('transactBooks')
            .doc("$_selectedTimeStamp")
            .set(newBookMap);

        ShowSnackBar(context, content: 'Book Created');
        FocusScope.of(context).unfocus();
        pageControllerGlobal.value.animateToPage(0,
            duration: Duration(milliseconds: 300), curve: Curves.ease);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ShowSnackBar(context, content: "$e", isDanger: true);
    }
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
                        controller: bookTitleController,
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
                                controller: bookDescriptionController,
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
                      // height20,
                      // Text("Book Type"),
                      // height10,
                      // bookTypeBtn('Regular Book'),
                      // height5,
                      // bookTypeBtn('Due Book'),
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
        child: ElevatedButton.icon(
          onPressed: () {
            createBook();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Dark.profitCard : Colors.black,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: kRadius(20),
            ),
          ),
          icon: Icon(
            Icons.add_circle,
            color: isDark ? Colors.black : Colors.white,
          ),
          label: Container(
            width: double.infinity,
            child: Text(
              'Create',
              style: TextStyle(
                fontSize: sdp(context, 15),
                color: isDark ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget bookTypeBtn(String label) {
    bool isSelected = selectedBookType == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBookType = label;
        });
      },
      child: Card(
        elevation: 0,
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: kRadius(15),
          side: BorderSide(
            color: isSelected
                ? isDark
                    ? Dark.profitText
                    : Light.profitText
                : Colors.transparent,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isSelected
                    ? isDark
                        ? Dark.profitText
                        : Light.profitText
                    : Colors.grey.shade400,
                radius: 5,
              ),
              width10,
              Expanded(child: Text(label))
            ],
          ),
        ),
      ),
    );
  }
}
