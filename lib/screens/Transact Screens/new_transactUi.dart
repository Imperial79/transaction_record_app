import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Functions/transactFunctions.dart';
import 'package:transaction_record_app/Utility/colors.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/models/transactModel.dart';
import 'package:transaction_record_app/services/user.dart';
import 'package:transaction_record_app/services/database.dart';
import 'package:transaction_record_app/Utility/components.dart';

import '../../Utility/sdp.dart';

class NewTransactUi extends StatefulWidget {
  final bookId;

  const NewTransactUi({
    Key? key,
    required this.bookId,
  }) : super(key: key);
  @override
  _NewTransactUiState createState() => _NewTransactUiState();
}

class _NewTransactUiState extends State<NewTransactUi> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController amountField = TextEditingController();
  TextEditingController sourceField = TextEditingController();
  TextEditingController descriptionField = TextEditingController();

  String source = 'From';
  String transactType = "Income";
  String transactMode = 'CASH';
  String transactId = DateTime.now().toString();
  Map<String, dynamic> _selectedDateMap = {
    'displayDate': DateFormat.yMMMMd().format(DateTime.now()),
    'tsDate': DateTime.now().toString(),
  };
  String _selectedTimeStamp = DateTime.now().toString();

  Map<String, dynamic> _selectedTimeMap = {
    'displayTime': DateFormat('hh:mm a').format(DateTime.now()),
    'tsTime': DateFormat('HH:mm').format(DateTime.now()),
  };
  Map<String, dynamic> _todayTimeMap = {
    'displayTime': DateFormat('hh:mm a').format(DateTime.now()),
    'tsTime': DateFormat('HH:mm').format(DateTime.now()),
  };

  @override
  void initState() {
    super.initState();
  }

  handleNewNoteTransaction(String uploadableAmount) {
    //  calculating the Income and Expense for new transact
    if (transactType == 'Income') {
      //  UPDATING INSIDE BOOK
      Map<String, dynamic> newMap = {
        'income': FieldValue.increment(double.parse(uploadableAmount)),
      };
      databaseMethods.updateBookTransactions(widget.bookId, newMap);
    } else {
      //  UPDATING INSIDE BOOK
      Map<String, dynamic> newMap = {
        'expense': FieldValue.increment(double.parse(uploadableAmount)),
      };
      databaseMethods.updateBookTransactions(widget.bookId, newMap);
    }
  }

  saveTransacts() async {
    if (amountField.text != '') {
      if (_todayTimeMap['displayDate'] != _selectedDateMap['displayDate'] ||
          _todayTimeMap['displayTime'] != _selectedTimeMap['displayTime']) {
        _selectedTimeStamp = await convertTimeToTS(
            _selectedDateMap['tsDate'], _selectedTimeMap['tsTime']);
      }
      transactId = _selectedTimeStamp;
      final _uploadableAmount =
          amountField.text.replaceAll(' ', '').replaceAll(',', '');

      Transact newTransact = Transact(
        uid: FirebaseRefs.myUID,
        transactId: transactId,
        amount: _uploadableAmount,
        source: sourceField.text,
        transactMode: transactMode,
        description: descriptionField.text,
        type: transactType,
        date: _selectedDateMap['displayDate'],
        time: _selectedTimeMap['displayTime'],
        bookId: widget.bookId,
        ts: _selectedTimeStamp,
      );

      databaseMethods.uploadTransacts(
        globalUser.uid,
        newTransact.toMap(),
        widget.bookId,
        transactId,
      );

      handleNewNoteTransaction(_uploadableAmount);

      //  resetting the values
      amountField.clear();
      descriptionField.clear();
      sourceField.clear();
      transactType = 'Income';
      source = 'From';

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    amountField.dispose();
    descriptionField.dispose();
    sourceField.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setSystemUIColors(context);
    isDark = Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: isDark ? whiteColor : Colors.black,
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
              height10,
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      CustomCard(
                        context,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.short_text_rounded,
                                color: whiteColor,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: TextField(
                                controller: descriptionField,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                maxLines: 5,
                                minLines: 1,
                                cursorColor: isDark ? whiteColor : Colors.black,
                                style: TextStyle(
                                  color: isDark ? whiteColor : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Add description (Optional)',
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
                      CustomCard(
                        context,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: sdp(context, 15),
                                  color: isDark ? whiteColor : Colors.black,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Created on',
                                  style: TextStyle(
                                    color: isDark ? whiteColor : Colors.black,
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
                                  child: InkWell(
                                    onTap: () async {
                                      _selectedDateMap = await selectDate(
                                          context, setState, DateTime.now());
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: isDark
                                            ? darkGreyColor
                                            : Colors.white,
                                      ),
                                      child: Text(
                                        _selectedDateMap['displayDate'],
                                        style: TextStyle(
                                          color:
                                              isDark ? whiteColor : blackColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                InkWell(
                                  onTap: () async {
                                    _selectedTimeMap = await selectTime(
                                        context, setState, TimeOfDay.now());
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color:
                                          isDark ? darkGreyColor : Colors.white,
                                    ),
                                    child: Text(
                                      _selectedTimeMap['displayTime'],
                                      style: TextStyle(
                                        color: isDark ? whiteColor : blackColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      CustomCard(
                        context,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.amber.shade900,
                              child: Icon(
                                Icons.person,
                                color: whiteColor,
                                size: sdp(context, 12),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: TextField(
                                controller: sourceField,
                                maxLines: 4,
                                minLines: 1,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                cursorColor: isDark ? whiteColor : Colors.black,
                                style: TextStyle(
                                  color: isDark ? whiteColor : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Add source (Optional)',
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
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RotatedBox(
                            quarterTurns: 45,
                            child: Text(
                              'CASH',
                              style: TextStyle(
                                color: transactMode == 'ONLINE'
                                    ? Colors.grey
                                    : isDark
                                        ? Colors.lightGreenAccent
                                        : Colors.lightGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: sdp(context, 6),
                          ),
                          transactTypeToggle(context),
                          SizedBox(
                            width: sdp(context, 6),
                          ),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Product',
                                color: transactMode == 'ONLINE'
                                    ? isDark
                                        ? Colors.blue.shade200
                                        : Colors.blue.shade700
                                    : Colors.grey,
                              ),
                              children: [
                                TextSpan(
                                  text: 'ON',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: sdp(context, 13),
                                  ),
                                ),
                                TextSpan(
                                  text: '\nLINE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: sdp(context, 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      BottomCard(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container BottomCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : whiteColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transactMode,
                  style: TextStyle(
                    letterSpacing: 10,
                    fontSize: sdp(context, 15),
                    fontWeight: FontWeight.w800,
                    color: transactMode == 'CASH'
                        ? isDark
                            ? Colors.lightGreenAccent
                            : Colors.lightGreen
                        : isDark
                            ? Colors.blue.shade200
                            : Colors.blue.shade700,
                  ),
                ),
                Text(
                  DateFormat('dd MMMM, yyyy').format(DateTime.now()),
                  style: TextStyle(color: isDark ? whiteColor : darkGreyColor),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDark ? Colors.grey.shade900 : whiteColor,
                  isDark ? Colors.grey.withOpacity(0) : Colors.grey.shade300,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: TextField(
              controller: amountField,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isDark ? whiteColor : Colors.black,
                fontSize: sdp(context, 20),
              ),
              cursorColor: isDark ? whiteColor : Colors.black,
              decoration: InputDecoration(
                prefixText: 'INR ',
                prefixStyle: TextStyle(
                  color: isDark ? whiteColor : Colors.grey.shade700,
                  fontSize: sdp(context, 20),
                  fontWeight: FontWeight.w300,
                ),
                border: InputBorder.none,
                hintText: '0.00',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade400,
                  fontSize: sdp(context, 20),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MediaQuery.of(context).viewInsets.bottom != 0
                    ? Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? darkGreyColor : cardColorlight,
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
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: transactType == 'Income'
                            ? isDark
                                ? darkProfitColorAccent.withOpacity(0.5)
                                : lightProfitColorAccent.withOpacity(0.2)
                            : isDark
                                ? Colors.redAccent.withOpacity(0.6)
                                : Colors.red.withOpacity(0.2),
                        blurRadius: 100,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      saveTransacts();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    child: Ink(
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 25,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            transactType == 'Income'
                                ? primaryColor
                                : Colors.redAccent,
                            transactType == 'Income'
                                ? Colors.lightGreenAccent
                                : Color.fromARGB(255, 189, 56, 56),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            transactType == 'Income'
                                ? Icons.file_download_outlined
                                : Icons.file_upload_outlined,
                            color: transactType == 'Income'
                                ? Colors.black
                                : Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Update ' + transactType,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: transactType == 'Income'
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 18,
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
        ],
      ),
    );
  }

  GestureDetector transactTypeToggle(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (transactMode == 'ONLINE') {
            transactMode = 'CASH';
            setState(() {});
          } else {
            transactMode = 'ONLINE';
            setState(() {});
          }
        });
      },
      child: Container(
        padding: EdgeInsets.all(10),
        width: sdp(context, 220),
        decoration: BoxDecoration(
          color: (transactMode == 'ONLINE' ? Colors.blue : Colors.lightGreen)
              .withOpacity(0.2),
          borderRadius: BorderRadius.circular(50),
        ),
        child: AnimatedAlign(
          curve: Curves.ease,
          duration: Duration(milliseconds: 250),
          alignment:
              transactMode == 'ONLINE' ? Alignment.topRight : Alignment.topLeft,
          child: CircleAvatar(
            backgroundColor: transactMode == 'ONLINE'
                ? Colors.blue.shade700
                : Colors.lightGreen,
            radius: sdp(context, 15),
            child: transactMode == 'ONLINE'
                ? Icon(
                    Icons.wallet,
                    color: Colors.white,
                    size: sdp(context, 13),
                  )
                : Text(
                    '₹',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: sdp(context, 13),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget TransactTypeCard({final label, icon}) {
    bool isIncome = label == 'Income';
    bool isSelected = transactType == label;
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          transactType = label;
        });
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(10),
        elevation: 0,
        backgroundColor: isIncome
            ? isSelected
                ? darkProfitColorAccent
                : isDark
                    ? cardColordark
                    : cardColorlight
            : isSelected
                ? isDark
                    ? Colors.redAccent
                    : blackColor
                : isDark
                    ? cardColordark
                    : cardColorlight,
      ),
      icon: Icon(
        icon,
        color: isIncome
            ? isSelected
                ? blackColor
                : Colors.grey
            : isSelected
                ? whiteColor
                : Colors.grey,
        size: sdp(context, 12),
      ),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          // fontSize: sdp(context, 8),
          color: isIncome
              ? isSelected
                  ? Colors.black
                  : Colors.grey
              : isSelected
                  ? Colors.white
                  : isDark
                      ? Colors.grey
                      : Colors.black,
        ),
      ),
    );
  }
}
