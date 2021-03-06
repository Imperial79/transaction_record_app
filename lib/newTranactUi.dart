import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Functions/homeFunctions.dart';
import 'package:transaction_record_app/colors.dart';
import 'package:transaction_record_app/services/user.dart';
import 'package:transaction_record_app/services/database.dart';

class NewTransactUi extends StatefulWidget {
  @override
  _NewTransactUiState createState() => _NewTransactUiState();
}

class _NewTransactUiState extends State<NewTransactUi> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController amountField = TextEditingController();
  TextEditingController sourceField = TextEditingController();
  TextEditingController descriptionField = TextEditingController();
  final title = TextEditingController();

  String source = 'From';
  String transactType = "Income";

  saveTransacts(var DisplayTime, String currTime) {
    if (amountField.text != '') {
      Map<String, dynamic> transactMap = {
        'title': title.text,
        "amount": amountField.text,
        "source": sourceField.text,
        "description": descriptionField.text,
        "type": transactType,
        'date': DisplayTime,
        'ts': currTime,
      };
      databaseMethods.uploadTransacts(UserDetails.uid, transactMap);
      if (transactType == 'add') {
        FirebaseFirestore.instance
            .collection('users')
            .doc(UserDetails.uid)
            .update({
          'currentBalance': FieldValue.increment(double.parse(amountField.text))
        });

        FirebaseFirestore.instance
            .collection('users')
            .doc(UserDetails.uid)
            .update({
          'income': FieldValue.increment(double.parse(amountField.text)),
        });
      } else {
        final amount = double.parse(amountField.text);
        // print((~(amount - 1)));

        // print(0 - amount);

        FirebaseFirestore.instance
            .collection('users')
            .doc(UserDetails.uid)
            .update({
          'currentBalance': FieldValue.increment(0.0 - amount),
        });

        FirebaseFirestore.instance
            .collection('users')
            .doc(UserDetails.uid)
            .update({
          'expense': FieldValue.increment(double.parse(amountField.text))
        });
      }

      Navigator.pop(context);

      //resetting the values
      amountField.clear();
      descriptionField.clear();
      sourceField.clear();

      transactType = 'add';
      source = 'From';
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
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
                          Expanded(
                            child: TransactTypeCard(
                              icon: Icons.file_download_outlined,
                              label: 'Income',
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TransactTypeCard(
                              icon: Icons.file_upload_outlined,
                              label: 'Expense',
                            ),
                          ),
                        ],
                      ),
                      TextField(
                        controller: title,
                        style: GoogleFonts.raleway(
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
                          hintText: 'Transact title',
                          hintStyle: GoogleFonts.raleway(
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
                        padding: EdgeInsets.all(13),
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
                                controller: descriptionField,
                                maxLines: 2,
                                minLines: 1,
                                cursorColor: Colors.black,
                                style: GoogleFonts.raleway(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Add description',
                                  hintStyle: GoogleFonts.raleway(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w700,
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
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 13, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 20,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Created on',
                                style: GoogleFonts.raleway(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Spacer(),
                              Text(
                                DateFormat('dd MMMM')
                                        .format(DateTime.now())
                                        .toString() +
                                    ' at ' +
                                    DateFormat()
                                        .add_jm()
                                        .format(DateTime.now())
                                        .toString(),
                                style: GoogleFonts.openSans(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: TextField(
                                controller: sourceField,
                                maxLines: 2,
                                minLines: 1,
                                cursorColor: Colors.black,
                                style: GoogleFonts.raleway(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Add source',
                                  hintStyle: GoogleFonts.raleway(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    spreadRadius: 10,
                    blurRadius: 10,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          width: 200,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: amountField,
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                              fontSize: 40,
                            ),
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0.00',
                              hintStyle: GoogleFonts.openSans(
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade600,
                                fontSize: 40,
                              ),
                              suffixText: 'INR',
                              suffixStyle: GoogleFonts.raleway(
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontSize: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            'Add money to',
                            style: GoogleFonts.raleway(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'CASH',
                            style: GoogleFonts.raleway(
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MediaQuery.of(context).viewInsets.bottom != 0
                          ? Container(
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
                                  FocusScope.of(context).unfocus();
                                },
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          : SizedBox(
                              width: 20,
                            ),
                      MaterialButton(
                        onPressed: () {
                          var formatter = DateFormat('dd MMMM, yyyy - ')
                              .add_jm()
                              .format(DateTime.now());
                          String currentTime = DateTime.now().toString();
                          saveTransacts(
                            formatter,
                            currentTime,
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        child: Ink(
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 25,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: LinearGradient(
                              colors: [
                                transactType == 'Income'
                                    ? primaryColor
                                    : Colors.black,
                                transactType == 'Income'
                                    ? primaryAccentColor
                                    : Colors.grey,
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Add ' + transactType,
                                style: GoogleFonts.raleway(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  Widget TransactTypeCard({final label, icon}) {
    return MaterialButton(
      onPressed: () {
        setState(() {
          transactType = label;
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
        side: transactType == label
            ? BorderSide(
                color: Colors.grey,
                width: 1,
              )
            : BorderSide.none,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 25,
          ),
          SizedBox(
            width: 7,
          ),
          Expanded(
            child: FittedBox(
              child: Text(
                label,
                style: GoogleFonts.openSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
