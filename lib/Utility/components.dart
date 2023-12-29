import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Functions/bookFunctions.dart';
import 'package:transaction_record_app/screens/Book%20Screens/newBookUI.dart';
import 'package:transaction_record_app/screens/Home%20Screens/homeUi.dart';
import 'package:transaction_record_app/services/size.dart';

import '../Functions/navigatorFns.dart';
import 'colors.dart';
import '../screens/Transact Screens/new_transactUi.dart';

final oCcy = new NumberFormat("#,##0.00", "en_US");
const String appLogoPath = 'lib/assets/logo/logo.png';

Widget get height5 => SizedBox(height: 5);
Widget get height10 => SizedBox(height: 10);
Widget get height20 => SizedBox(height: 20);
Widget get width5 => SizedBox(width: 5);
Widget get width10 => SizedBox(width: 10);
Widget get width20 => SizedBox(width: 20);

Widget FirstTransactCard(BuildContext context, String bookId) {
  return Container(
    margin: EdgeInsets.only(top: 0),
    width: double.infinity,
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? Colors.amber : Colors.amber.shade100,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create your first Transact',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: blackColor,
            fontSize: 20,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Track your daily expenses by creating Transacts.',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: blackColor,
            fontSize: 15,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.amberAccent : Colors.orange,
                  blurRadius: 100,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                NavPush(
                  context,
                  NewTransactUi(
                    bookId: bookId,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.amber.shade100 : Colors.orange,
                elevation: 0,
              ),
              icon: Icon(
                Icons.bolt,
                color: isDark ? blackColor : whiteColor,
              ),
              label: Text(
                'Create',
                style: TextStyle(
                  color: isDark ? blackColor : whiteColor,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class AppTitle extends StatelessWidget {
  const AppTitle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Transact ",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 25,
                    color: Colors.grey.shade600,
                  ),
                ),
                TextSpan(
                  text: "Record",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 25,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Made by Avishek Verma',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          )
        ],
      ),
    );
  }
}

Widget DummyTransactList(BuildContext context) {
  return Column(
    children: [
      for (int i = 0; i <= 10; i++)
        Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Container(
            padding: EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF333333) : cardColorlight,
              borderRadius: BorderRadius.circular(20),
            ),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                height: sdp(context, 30),
                                width: sdp(context, 30),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 200,
                                height: 20,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              Spacer(),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 200,
                            height: 20,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          Container(
                            width: 200,
                            height: 20,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Container(
                    width: 200,
                    height: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

Widget StatsCard({final label, content, isBook, bookId}) {
  bool isExpense = label == 'Expenses';
  return Stack(
    children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isExpense ? Color(0xffca705f) : darkProfitColorAccent,
          border: Border.all(
            color: isExpense
                ? isDark
                    ? Colors.red.shade100
                    : Colors.red.shade900
                : isDark
                    ? Colors.white
                    : Colors.teal.shade700,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isExpense
                      ? Icons.file_upload_outlined
                      : Icons.file_download_outlined,
                  color: isExpense ? Colors.white : Colors.black,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: isExpense ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              oCcy.format(double.parse(content)) + ' INR',
              style: TextStyle(
                color: isExpense ? Colors.white : Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      // Align(
      //   alignment: Alignment.topRight,
      //   child: GestureDetector(
      //     onTap: () {
      //       print('Reset $label');
      //       if (isBook) {
      //         Map<String, dynamic> map =
      //             label == 'Income' ? {'income': 0} : {'expense': 0};
      //         DatabaseMethods()
      //             .resetBookIncomeExpense(bookId, UserDetails.uid, map);
      //       } else {
      //         Map<String, dynamic> map =
      //             label == 'Income' ? {'income': 0} : {'expense': 0};
      //         DatabaseMethods()
      //             .resetGlobalIncomeExpense(bookId, UserDetails.uid, map);
      //       }
      //     },
      //     child: Container(
      //       padding: EdgeInsets.all(5),
      //       decoration: BoxDecoration(
      //         color: Colors.white,
      //         borderRadius: BorderRadius.only(
      //           topRight: Radius.circular(10),
      //           bottomLeft: Radius.circular(10),
      //         ),
      //       ),
      //       child: Icon(
      //         Icons.restore,
      //         size: 15,
      //       ),
      //     ),
      //   ),
      // ),
    ],
  );
}

Widget kRenameModal(String oldBookName) {
  final _bookTitle = new TextEditingController(text: oldBookName);
  return StatefulBuilder(
    builder: (context, setState) {
      return SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          margin: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: isDark ? cardColordark : cardColorlight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                      isDark ? Colors.blue.shade100 : Colors.blueAccent,
                  child: Text(
                    'Aa',
                    style: TextStyle(
                      fontSize: sdp(context, 16),
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.blue.shade800 : whiteColor,
                    ),
                  ),
                ),
                height10,
                Text(
                  'Rename Book',
                  style: TextStyle(
                    color: isDark ? whiteColor : blackColor,
                    fontSize: sdp(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Change the book name',
                  style: TextStyle(
                    color: isDark ? Colors.blue.shade300 : Colors.blueAccent,
                    fontSize: sdp(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                height20,
                TextField(
                  controller: _bookTitle,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(
                    fontSize: sdp(context, 20),
                    fontWeight: FontWeight.w900,
                    color: isDark ? whiteColor : blackColor,
                  ),
                  cursorWidth: 1,
                  cursorColor: isDark ? whiteColor : blackColor,
                  decoration: InputDecoration(
                    focusColor: isDark ? whiteColor : blackColor,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? darkGreyColor : blackColor,
                        width: 2,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? darkGreyColor : Colors.grey.shade300,
                      ),
                    ),
                    hintText: 'Book title',
                    hintStyle: TextStyle(
                      fontSize: sdp(context, 20),
                      color: isDark ? darkGreyColor : Colors.grey.shade400,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                height20,
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.file_upload_outlined),
                  label: Text('Update'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget ConfirmDeleteModal({
  required String label,
  required String content,
  required VoidCallback onDelete,
}) {
  return StatefulBuilder(
    builder: (context, setState) {
      return SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? cardColordark : cardColorlight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                      isDark ? Colors.red.shade100 : Colors.redAccent,
                  child: Text(
                    '!',
                    style: TextStyle(
                      fontSize: sdp(context, 16),
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.red.shade800 : whiteColor,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? whiteColor : blackColor,
                    fontSize: sdp(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  content,
                  style: TextStyle(
                    color: isDark ? Colors.red.shade300 : Colors.redAccent,
                    fontSize: sdp(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? blackColor : lossColor,
                        foregroundColor:
                            isDark ? Colors.red.shade300 : whiteColor,
                      ),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: onDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? blackColor : primaryColor,
                        foregroundColor:
                            isDark ? darkProfitColorAccent : whiteColor,
                      ),
                      child: Text('Yes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget BookMenuBtn({
  required void Function()? onPressed,
  required String label,
  required IconData icon,
  required Color btnColor,
  required Color textColor,
  double? labelSize,
  double? iconSize,
}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: btnColor,
      foregroundColor: textColor,
      elevation: 0,
    ),
    icon: Icon(
      icon,
      size: iconSize,
    ),
    label: Text(
      label,
      style: TextStyle(
        fontSize: labelSize,
      ),
    ),
  );
}

Widget CustomCard(BuildContext context, {required Widget child}) {
  return Container(
    margin: EdgeInsets.only(bottom: 13),
    padding: EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: isDark ? cardColordark : cardColorlight,
      borderRadius: BorderRadius.circular(15),
    ),
    child: child,
  );
}

setSystemUIColors({
  Brightness? statusBarIconBrightness,
  Brightness? systemNavigationBarIconBrightness,
  Brightness? statusBarBrightness,
}) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
    ),
  );
}

bool isKeyboardOpen(BuildContext context) {
  return MediaQuery.of(context).viewInsets.bottom != 0;
}

Widget ALertBox(BuildContext context, {final label, content, onPress}) {
  return StatefulBuilder(
    builder: (context, StateSetter setState) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        icon: Icon(
          Icons.delete,
          color: Colors.red,
          size: 30,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
            ),
          ),
          MaterialButton(
            onPressed: onPress,
            color: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            elevation: 0,
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}

Widget NewBookCard(BuildContext context) => Container(
      margin: EdgeInsets.all(10),
      width: double.infinity,
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            primaryColor,
            Colors.black,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Create your first Transact Book',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Track your daily expenses by creating categorised Transact Book',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.topRight,
            child: MaterialButton(
              onPressed: () {
                NavPush(context, NewBookUI());
              },
              color: Colors.white.withOpacity(0.2),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                alignment: Alignment.center,
                width: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bolt_outlined,
                      color: Colors.yellow,
                    ),
                    Text(
                      'Create',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

Widget bookOptionsModal({required String bookName, required String bookId}) {
  return StatefulBuilder(
    builder: (context, setState) {
      return SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: isDark ? cardColordark : cardColorlight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: isDark ? Colors.grey.shade300 : Colors.black,
                  child: SvgPicture.asset(
                    'lib/assets/icons/options.svg',
                    colorFilter: svgColor(
                      isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Book Options",
                  style: TextStyle(
                    color: isDark ? whiteColor : blackColor,
                    fontSize: sdp(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    BookMethods.deleteBook(context,
                        bookName: bookName, bookId: bookId);
                  },
                  child: Card(
                    elevation: 0,
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Card(
                            color: isDark ? Colors.red.shade100 : Colors.red,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: SvgPicture.asset(
                                'lib/assets/icons/delete.svg',
                                colorFilter: svgColor(
                                  isDark ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Text(
                              "Delete book",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: sdp(context, 15),
                                color:
                                    isDark ? Colors.red.shade200 : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget AnimatedFloatingButton(
  BuildContext context, {
  void Function()? onTap,
  required Widget icon,
  required String label,
}) {
  return InkWell(
    onTap: onTap,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? Colors.greenAccent : blackColor,
      ),
      child: AnimatedSize(
        reverseDuration: Duration(milliseconds: 300),
        duration: Duration(milliseconds: 300),
        alignment: Alignment.centerLeft,
        curve: Curves.ease,
        child: ValueListenableBuilder<bool>(
          valueListenable: showAdd,
          builder: (
            BuildContext context,
            bool showFullAddBtn,
            Widget? child,
          ) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: showFullAddBtn ? sdp(context, 11) : sdp(context, 9),
                vertical: sdp(context, 9),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: isDark ? blackColor : Colors.white,
                    size: 30,
                  ),
                  if (showFullAddBtn) const SizedBox(width: 10),
                  if (showFullAddBtn)
                    Text(
                      'Create Book',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: sdp(context, 11),
                        color: isDark ? blackColor : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}
