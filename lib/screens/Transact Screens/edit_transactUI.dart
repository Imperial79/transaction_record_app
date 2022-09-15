import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/services/user.dart';

import '../../Functions/transactFunctions.dart';
import '../../colors.dart';
import '../../services/database.dart';

class EditTransactUI extends StatefulWidget {
  final snap;
  const EditTransactUI({Key? key, this.snap}) : super(key: key);

  @override
  State<EditTransactUI> createState() => _EditTransactUIState();
}

class _EditTransactUIState extends State<EditTransactUI> {
  //  Variables -------------->

  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController amountField = TextEditingController();
  TextEditingController sourceField = TextEditingController();
  TextEditingController descriptionField = TextEditingController();
  final title = TextEditingController();
  final ValueNotifier<bool> _showAmountField = ValueNotifier<bool>(true);
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  //---------------
  String source = 'From';
  String transactType = "Income";
  String transactMode = 'CASH';
  String transactId = DateTime.now().toString();
  Map<String, dynamic> _selectedDateMap = {
    'displayDate': DateFormat.yMMMMd().format(DateTime.now()),
    'tsDate': DateTime.now().toString(),
  };
  String _selectedTimeStamp = DateTime.now().toString();
  String _selectedTime =
      DateFormat().add_jm().format(DateTime.now()).toString();

  //  Functions ----------------------------------------->
  @override
  void initState() {
    super.initState();
    title.text = widget.snap['title'];
    amountField.text = widget.snap['amount'];
    descriptionField.text = widget.snap['description'];
    source = widget.snap['source'];
    _selectedDateMap['displayDate'] = widget.snap['date'];
    _selectedDateMap['tsDate'] = widget.snap['ts'];
    _selectedTime = widget.snap['time'];
    _selectedTimeStamp = widget.snap['ts'];
    transactId = widget.snap['transactId'];
    transactType = widget.snap['type'];
    transactMode = widget.snap['transactMode'];
    setState(() {});
  }

  handleEditedNoteTransaction() {
    //  calculating the Income and Expense for edited transact
    if (transactType == 'Income') {
      //  If newType is INCOME
      //--------------------------------------------

      double _oldAmount = double.parse(widget.snap['amount']);
      double _newAmount = double.parse(amountField.text);
      String _oldType = widget.snap['type'];

      //--------------------------------------------

      if (_oldType == 'Income') {
        databaseMethods.updateBookTransactions(widget.snap['bookId'],
            {'income': FieldValue.increment((0.0 - _oldAmount) + _newAmount)});
      } else {
        //  if oldType was expense ----------->
        databaseMethods.updateBookTransactions(widget.snap['bookId'],
            {'expense': FieldValue.increment((0.0 - _oldAmount) + _newAmount)});
      }
    } else {
      //  If newType is Expense ---------------->

      double _oldAmount = double.parse(widget.snap['amount']);
      double _newAmount = double.parse(amountField.text);
      String _oldType = widget.snap['type'];

      //--------------------------------------------
      if (_oldType == 'Income') {
        databaseMethods.updateBookTransactions(widget.snap['bookId'],
            {'income': FieldValue.increment((0.0 - _oldAmount) + _newAmount)});
      } else {
        //  if oldType was expense ----------->
        databaseMethods.updateBookTransactions(widget.snap['bookId'],
            {'expense': FieldValue.increment((0.0 - _oldAmount) + _newAmount)});
      }
    }
  }

  saveTransacts() async {
    if (amountField.text != '') {
      _selectedTimeStamp =
          await convertTimeToTS(_selectedDateMap['tsDate'], _selectedTime);

      Map<String, dynamic> transactMap = {
        'transactId': widget.snap['transactId'],
        'title': title.text,
        "amount": amountField.text,
        "source": sourceField.text,
        "transactMode": transactMode,
        "description": descriptionField.text,
        "type": transactType,
        'date': _selectedDateMap['displayDate'],
        'time': _selectedTime,
        'bookId': widget.snap['bookId'],
        'ts': _selectedTimeStamp,
      };

      databaseMethods.updateTransacts(
          widget.snap['bookId'], widget.snap['transactId'], transactMap);

      handleEditedNoteTransaction();

      //  resetting the values
      amountField.clear();
      descriptionField.clear();
      sourceField.clear();
      transactType = 'Income';
      source = 'From';

      Navigator.pop(context);
    }
  }

  deleteTransact() async {
    setState(() {
      _isLoading = true;
    });
    await DatabaseMethods().deleteTransact(
        UserDetails.uid, widget.snap['bookId'], widget.snap['transactId']);
    if (transactType == 'Income') {
      Map<String, dynamic> _updatedMap = {
        'income':
            FieldValue.increment(0.0 - double.parse(widget.snap['amount'])),
      };
      await DatabaseMethods().updateBookTransactions(
        widget.snap['bookId'],
        _updatedMap,
      );
    } else {
      Map<String, dynamic> _updatedMap = {
        'expense':
            FieldValue.increment(0.0 - double.parse(widget.snap['amount'])),
      };
      await DatabaseMethods().updateBookTransactions(
        widget.snap['bookId'],
        _updatedMap,
      );
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
  }

  //------------------------------------->

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    amountField.dispose();
    title.dispose();
    descriptionField.dispose();
    sourceField.dispose();
  }

  // -----------------------------------------

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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
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
                              TransactTypeCard(
                                icon: widget.snap['type'] == 'Income'
                                    ? Icons.file_download_outlined
                                    : Icons.file_upload_outlined,
                                label: widget.snap['type'],
                              ),
                            ],
                          ),
                          TextField(
                            controller: title,
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
                              hintText: 'Transact title',
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
                                    // focusNode: descriptionFocus,
                                    maxLines: 2,
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 13, vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.punch_clock,
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
                                              context,
                                              setState,
                                              DateTime.parse(
                                                  widget.snap['ts']));
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                        _selectedTime =
                                            await selectTime(context, setState);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                        ),
                                        child: Text(
                                          _selectedTime,
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 13, vertical: 10),
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
                                    maxLines: 4,
                                    minLines: 1,
                                    cursorColor: Colors.black,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Add source',
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
                          MaterialButton(
                            onPressed: () {
                              deleteTransact();
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            child: Ink(
                              padding: EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 25,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red,
                                    Colors.red.shade900,
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Delete Transact',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
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
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: Duration(milliseconds: 200),
                  child: ValueListenableBuilder<bool>(
                      valueListenable: _showAmountField,
                      builder: (BuildContext context, bool showFullAppBar,
                          Widget? child) {
                        return Container(
                          child: showFullAppBar
                              ? Container(
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
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              width: 200,
                                              child: TextField(
                                                controller: amountField,
                                                // focusNode: amountFocus,
                                                keyboardType:
                                                    TextInputType.number,
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
                                                  suffixText: 'INR',
                                                  suffixStyle: TextStyle(
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
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              DropdownButton(
                                                value: transactMode,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                                underline: const SizedBox(),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    transactMode = newValue!;
                                                  });
                                                },
                                                items: <String>[
                                                  'CASH',
                                                  'ONLINE'
                                                ].map<DropdownMenuItem<String>>(
                                                    (String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(
                                                      value,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          MediaQuery.of(context)
                                                      .viewInsets
                                                      .bottom !=
                                                  0
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
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                    },
                                                    icon: Icon(
                                                      Icons
                                                          .keyboard_arrow_down_rounded,
                                                      size: 20,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(
                                                  width: 20,
                                                ),
                                        ],
                                      ),
                                      MaterialButton(
                                        onPressed: () {
                                          saveTransacts();
                                        },
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        elevation: 0,
                                        padding: EdgeInsets.zero,
                                        child: Ink(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 15,
                                            horizontal: 25,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
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
                                                transactType == 'Income'
                                                    ? Icons
                                                        .file_download_outlined
                                                    : Icons
                                                        .file_upload_outlined,
                                                color: transactType == 'Income'
                                                    ? Colors.green.shade900
                                                    : Colors.white,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                'Update ' + transactType,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: transactType ==
                                                          'Income'
                                                      ? Colors.green.shade900
                                                      : Colors.white,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                        );
                      }),
                ),
              ],
            ),
            Visibility(
              visible: _isLoading,
              child: Container(
                alignment: Alignment.center,
                height: double.infinity,
                width: double.infinity,
                color: Colors.white.withOpacity(0.9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Transform.scale(
                        scale: 0.7,
                        child: CircularProgressIndicator(
                          color: Colors.red,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Deleting Transact',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget TransactTypeCard({final label, icon}) {
    return InkWell(
      onTap: () {
        setState(() {
          transactType = label;
        });
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: transactType == label
                ? label == 'Income'
                    ? Colors.green.shade700
                    : Colors.red
                : Colors.transparent,
          ),
          color: label == 'Income' ? Color(0xFFD7FFD9) : Color(0xFFFFDEDC),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: label == 'Income' ? Colors.green.shade700 : Colors.red,
            ),
            SizedBox(
              width: 7,
            ),
            Text(
              label,
              style: TextStyle(
                // fontSize: 16,
                fontWeight: FontWeight.w500,
                color: label == 'Income' ? Colors.green.shade700 : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
