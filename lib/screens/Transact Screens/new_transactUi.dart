import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Functions/transactFunctions.dart';
import 'package:transaction_record_app/colors.dart';
import 'package:transaction_record_app/services/size.dart';
import 'package:transaction_record_app/services/user.dart';
import 'package:transaction_record_app/services/database.dart';
import 'package:transaction_record_app/widgets.dart';

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
  final title = TextEditingController();
  final ValueNotifier<bool> _showAmountField = ValueNotifier<bool>(true);
  final ScrollController _scrollController = ScrollController();

  String source = 'From';
  String transactType = "Income";
  String transactMode = 'CASH';
  String transactId = DateTime.now().toString();
  Map<String, dynamic> _selectedDateMap = {
    'displayDate': DateFormat.yMMMMd().format(DateTime.now()),
    'tsDate': DateTime.now().toString(),
  };
  String _selectedTimeStamp = DateTime.now().toString();
  // String _selectedTime =
  //     DateFormat().add_jm().format(DateTime.now()).toString();

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
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        _showAmountField.value = false;
      } else {
        _showAmountField.value = true;
      }
    });
  }

  handleNewNoteTransaction(String uploadableAmount) {
    //  calculating the Income and Expense for new transact
    if (transactType == 'Income') {
      Map<String, dynamic> newMap = {
        'currentBalance': FieldValue.increment(double.parse(uploadableAmount)),
        'income': FieldValue.increment(double.parse(uploadableAmount)),
      };

      //  UPDATING GLOBALLY
      databaseMethods.updateGlobalCurrentBal(UserDetails.uid, newMap);

      //  UPDATING INSIDE BOOK
      newMap = {
        'income': FieldValue.increment(double.parse(uploadableAmount)),
      };
      databaseMethods.updateBookTransactions(widget.bookId, newMap);
    } else {
      final amount = double.parse(uploadableAmount);

      //  UPDATING GLOBALLY
      Map<String, dynamic> newMap = {
        'currentBalance': FieldValue.increment(0.0 - amount),
        'expense': FieldValue.increment(double.parse(uploadableAmount)),
      };
      databaseMethods.updateGlobalCurrentBal(UserDetails.uid, newMap);

      //  UPDATING INSIDE BOOK
      newMap = {
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
      Map<String, dynamic> transactMap = {
        'transactId': transactId,
        'title': title.text,
        "amount": _uploadableAmount,
        "source": sourceField.text,
        "transactMode": transactMode,
        "description": descriptionField.text,
        "type": transactType,
        'date': _selectedDateMap['displayDate'],
        'time': _selectedTimeMap['displayTime'],
        'bookId': widget.bookId,
        'ts': _selectedTimeStamp,
      };

      databaseMethods.uploadTransacts(
          UserDetails.uid, transactMap, widget.bookId, transactId);

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
    _scrollController.dispose();
    amountField.dispose();
    title.dispose();
    descriptionField.dispose();
    sourceField.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setSystemUIColors();

    return Scaffold(
      body: SafeArea(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(sdp(context, 10)),
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
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 2,
                            minLines: 1,
                            cursorColor: Colors.black,
                            style: TextStyle(
                              color: Colors.black,
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
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 13, vertical: 20),
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
                              child: InkWell(
                                onTap: () async {
                                  _selectedDateMap = await selectDate(
                                      context, setState, DateTime.now());
                                  // _selectedTimeStamp =
                                  //     await convertTimeToTS(
                                  //         _selectedDateMap['tsDate'],
                                  //         _selectedTimeMap['tsTime']);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  ),
                                  child: Text(
                                    _selectedDateMap['displayDate'],
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
                                  color: Colors.white,
                                ),
                                child: Text(
                                  _selectedTimeMap['displayTime'],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 4,
                            minLines: 1,
                            cursorColor: Colors.black,
                            style: TextStyle(
                              color: Colors.black,
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
                  SizedBox(
                    height: sdp(context, 10),
                  ),
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
                                : Colors.black,
                            fontWeight: FontWeight.w900,
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
                                ? Colors.blue.shade700
                                : Colors.grey,
                          ),
                          children: [
                            TextSpan(
                              text: 'ON',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
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
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: sdp(context, 140),
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(10),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '₹ ',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: amountField,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            fontSize: 40,
                          ),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade400,
                              fontSize: 40,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: sdp(context, 10),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                        decoration: BoxDecoration(
                          color: transactMode == 'ONLINE'
                              ? Colors.blue.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          transactMode,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: transactMode == 'ONLINE'
                                ? Colors.blue.shade900
                                : Colors.black,
                          ),
                        ),
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
                      AnimatedSize(
                        duration: Duration(milliseconds: 100),
                        child: MaterialButton(
                          onPressed: () {
                            saveTransacts();
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  transactType == 'Income'
                                      ? Icons.file_download_outlined
                                      : Icons.file_upload_outlined,
                                  color: transactType == 'Income'
                                      ? Colors.green.shade900
                                      : Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Add ' + transactType,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: transactType == 'Income'
                                        ? Colors.green.shade900
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
                ],
              ),
            ),
          ],
        ),
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
          color: transactMode == 'ONLINE'
              ? Colors.blue.shade100
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(50),
        ),
        child: AnimatedAlign(
          duration: Duration(milliseconds: 250),
          alignment:
              transactMode == 'ONLINE' ? Alignment.topRight : Alignment.topLeft,
          child: CircleAvatar(
            backgroundColor:
                transactMode == 'ONLINE' ? Colors.blue.shade700 : Colors.black,
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
    return MaterialButton(
      onPressed: () {
        setState(() {
          transactType = label;
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      color: isIncome
          ? isSelected
              ? primaryAccentColor
              : Colors.grey.shade200
          : isSelected
              ? Colors.black
              : Colors.grey.shade200,
      elevation: 0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: isIncome
                ? Colors.black
                : isSelected
                    ? Colors.white
                    : Colors.black,
          ),
          SizedBox(
            width: 7,
          ),
          Flexible(
            child: FittedBox(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isIncome
                      ? Colors.black
                      : isSelected
                          ? Colors.white
                          : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
