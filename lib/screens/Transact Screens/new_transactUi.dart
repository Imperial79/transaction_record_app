// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Functions/transactFunctions.dart';
import 'package:transaction_record_app/Utility/KButton.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/KTextfield.dart';
import 'package:transaction_record_app/models/transactModel.dart';
import 'package:transaction_record_app/services/database.dart';
import 'package:transaction_record_app/Utility/components.dart';
import '../../Utility/commons.dart';
import '../../Utility/newColors.dart';
import '../../services/user.dart';

class New_Transact_UI extends StatefulWidget {
  final bookId;

  const New_Transact_UI({
    Key? key,
    required this.bookId,
  }) : super(key: key);
  @override
  _New_Transact_UIState createState() => _New_Transact_UIState();
}

class _New_Transact_UIState extends State<New_Transact_UI> {
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
  bool isLoading = false;

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
    FocusScope.of(context).unfocus();
    try {
      setState(() {
        isLoading = true;
      });
      if (amountField.text != '') {
        if (_todayTimeMap['displayDate'] != _selectedDateMap['displayDate'] ||
            _todayTimeMap['displayTime'] != _selectedTimeMap['displayTime']) {
          _selectedTimeStamp = convertTimeToTS(
              _selectedDateMap['tsDate'], _selectedTimeMap['tsTime']);
        }
        transactId = _selectedTimeStamp;
        final _uploadableAmount =
            amountField.text.replaceAll(' ', '').replaceAll(',', '');

        Transact newTransact = Transact(
          uid: globalUser.uid,
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
          newTransact.toMap(),
          widget.bookId,
          transactId,
        );

        await FirebaseFirestore.instance
            .collection('transactBooks')
            .doc(widget.bookId)
            .update({"createdAt": "${DateTime.now()}"});

        handleNewNoteTransaction(_uploadableAmount);

        //  resetting the values
        amountField.clear();
        descriptionField.clear();
        sourceField.clear();
        transactType = 'Income';
        source = 'From';

        Navigator.pop(context);
      }
    } catch (e) {
      kSnackbar(
        context,
        content: "Unable to create Transact!",
        isDanger: true,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
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
    isDark = Theme.of(context).brightness == Brightness.dark;
    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Dark.card : Light.card,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Spacer(),
                  _typeBtn(
                    icon: Icons.file_download_outlined,
                    label: 'Income',
                  ),
                  width10,
                  _typeBtn(
                    icon: Icons.file_upload_outlined,
                    label: 'Expense',
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 12),
                physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KTextfield.regular(
                      isDark,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      controller: descriptionField,
                      maxLines: 4,
                      minLines: 1,
                      hintText: 'Add description (Optional)',
                      icon: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.short_text_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    height10,
                    kCard(
                      context,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 20,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              width10,
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
                                child: InkWell(
                                  onTap: () async {
                                    _selectedDateMap = await selectDate(
                                        context, setState, DateTime.now());
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: kRadius(10),
                                      color: isDark
                                          ? Dark.scaffold
                                          : Light.scaffold,
                                    ),
                                    child: Text(
                                      _selectedDateMap['displayDate'],
                                      style: TextStyle(
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
                                    borderRadius: kRadius(10),
                                    color:
                                        isDark ? Dark.scaffold : Light.scaffold,
                                  ),
                                  child: Text(
                                    _selectedTimeMap['displayTime'],
                                    style: TextStyle(
                                      color:
                                          isDark ? Colors.white : Colors.black,
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
                    height10,
                    KTextfield.regular(
                      isDark,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      controller: sourceField,
                      maxLines: 4,
                      minLines: 1,
                      hintText: 'Add source (Optional)',
                      icon: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.amber.shade900,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                    height10,
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
                        width10,
                        _modeToggle(context),
                        width10,
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
                                  fontSize: 15,
                                ),
                              ),
                              TextSpan(
                                text: '\nLINE',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    height10,
                    Text(
                      transactMode,
                      style: TextStyle(
                        letterSpacing: 5,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
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
                    ),
                    height10,
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            isDark ? Dark.scaffold : Light.scaffold,
                            isDark
                                ? Colors.grey.withOpacity(0)
                                : Colors.grey.shade300,
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
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 30,
                        ),
                        cursorColor: isDark ? Colors.white : Colors.black,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Text(
                              "INR",
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                fontSize: 30,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          prefixIconConstraints:
                              BoxConstraints(minHeight: 0, minWidth: 0),
                          border: InputBorder.none,
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    height20,
                    KButton.icon(isDark,
                        onPressed: saveTransacts,
                        backgroundColor: transactType == "Income"
                            ? isDark
                                ? Dark.profitCard
                                : Light.profitCard
                            : isDark
                                ? Dark.lossCard
                                : Light.lossCard,
                        icon: Icon(
                          transactType == 'Income'
                              ? Icons.file_download_outlined
                              : Icons.file_upload_outlined,
                          color: transactType == 'Income'
                              ? Colors.black
                              : Colors.white,
                        ),
                        textColor: transactType == 'Income'
                            ? Colors.black
                            : Colors.white,
                        label: "Save"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeToggle(BuildContext context) {
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
        width: 300,
        decoration: BoxDecoration(
          color: (transactMode == 'ONLINE' ? Colors.blue : Colors.lightGreen)
              .withOpacity(0.2),
          borderRadius: kRadius(50),
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
            radius: 20,
            child: transactMode == 'ONLINE'
                ? Icon(
                    Icons.webhook_sharp,
                    color: Colors.white,
                    size: 20,
                  )
                : Text(
                    '₹',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _typeBtn({final label, icon}) {
    bool isIncome = label == 'Income';
    bool isSelected = transactType == label;
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          transactType = label;
        });
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        elevation: 0,
        backgroundColor: isIncome
            ? isSelected
                ? Dark.profitCard
                : isDark
                    ? Dark.card
                    : Light.card
            : isSelected
                ? isDark
                    ? Colors.redAccent
                    : Colors.black
                : isDark
                    ? Dark.card
                    : Light.card,
      ),
      icon: Icon(
        icon,
        color: isIncome
            ? isSelected
                ? Colors.black
                : Colors.grey
            : isSelected
                ? Colors.white
                : Colors.grey,
        size: 20,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          // fontSize: 12,
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
