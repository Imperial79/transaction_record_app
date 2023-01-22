import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/screens/Book%20Screens/newBookUI.dart';

import 'Functions/navigatorFns.dart';
import 'colors.dart';
import 'screens/Transact Screens/new_transactUi.dart';

final oCcy = new NumberFormat("#,##0.00", "en_US");

Widget FirstTransactCard(BuildContext context, String bookId) {
  return Container(
    margin: EdgeInsets.only(top: 0),
    width: double.infinity,
    padding: EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Color.fromARGB(255, 73, 55, 0),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create your first Transact',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
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
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.topRight,
          child: MaterialButton(
            onPressed: () {
              NavPush(
                  context,
                  NewTransactUi(
                    bookId: bookId,
                  ));
            },
            color: Colors.amber,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              alignment: Alignment.center,
              width: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bolt_outlined,
                    color: Colors.black,
                  ),
                  Text(
                    'Create',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
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

Widget StatsCard({final label, content, isBook, bookId}) {
  return Stack(
    children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              label == 'Expenses' ? Colors.red.shade900 : primaryColor,
              label == 'Expenses' ? Colors.red : Colors.lightGreenAccent,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  label == 'Expenses'
                      ? Icons.file_upload_outlined
                      : Icons.file_download_outlined,
                  color: label == 'Expenses' ? Colors.white : Colors.black,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: label == 'Expenses' ? Colors.white : Colors.black,
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
                color: label == 'Expenses' ? Colors.white : Colors.black,
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

MaterialButton BookMenuBtn({final onPress, label, icon, btnColor, textColor}) {
  return MaterialButton(
    onPressed: onPress,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    elevation: 0,
    color: btnColor,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: textColor,
          size: 15,
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          label,
          style: TextStyle(color: textColor),
        ),
      ],
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
