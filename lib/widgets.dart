import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/services/database.dart';
import 'package:transaction_record_app/services/user.dart';

import 'Functions/navigatorFns.dart';
import 'colors.dart';
import 'screens/Transact Screens/new_transactUi.dart';

final oCcy = new NumberFormat("#,##0.00", "en_US");

Widget FirstTransactCard(BuildContext context, String bookId) {
  return Container(
    margin: EdgeInsets.only(top: 20),
    width: double.infinity,
    padding: EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create your first Transact',
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
          'Track your daily expenses by creating Transacts.',
          style: TextStyle(
            fontWeight: FontWeight.w600,
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: label == 'Expenses'
                  ? Colors.red.shade100.withOpacity(0.6)
                  : primaryColor.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              label == 'Expenses' ? Colors.red : primaryColor,
              label == 'Expenses' ? Colors.red.shade100 : Color(0xFF1FFFB4),
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
