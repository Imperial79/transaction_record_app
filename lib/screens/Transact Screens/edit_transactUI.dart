import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/services/size.dart';
import '../../Functions/transactFunctions.dart';
import '../../Utility/colors.dart';
import '../../models/transactModel.dart';
import '../../services/database.dart';
import '../../Utility/components.dart';

class EditTransactUI extends StatefulWidget {
  final Transact trData;
  const EditTransactUI({Key? key, required this.trData}) : super(key: key);

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
  Map<String, dynamic> _selectedTimeMap = {
    'displayTime': DateFormat('hh:mm a').format(DateTime.now()),
    'tsTime': DateFormat('HH:mm').format(DateTime.now()),
  };

  //  Functions ----------------------------------------->
  @override
  void initState() {
    super.initState();
    // title.text = widget.snap['title'];
    amountField.text = widget.trData.amount!;
    descriptionField.text = widget.trData.description!;
    sourceField.text = widget.trData.source!;
    _selectedDateMap['displayDate'] = widget.trData.date!;
    _selectedDateMap['tsDate'] = widget.trData.ts!;
    _selectedTimeMap['displayTime'] = widget.trData.time!;
    _selectedTimeStamp = widget.trData.ts!;
    transactId = widget.trData.transactId!;
    transactType = widget.trData.type!;
    transactMode = widget.trData.transactMode!;
    setState(() {});
  }

  handleEditedNoteTransaction() {
    //  calculating the Income and Expense for edited transact
    if (transactType == 'Income') {
      //  If newType is INCOME
      //--------------------------------------------

      double _oldAmount = double.parse(widget.trData.amount!);
      double _newAmount = double.parse(amountField.text);
      String _oldType = widget.trData.type!;

      //--------------------------------------------

      if (_oldType == 'Income') {
        databaseMethods.updateBookTransactions(widget.trData.bookId!,
            {'income': FieldValue.increment((0.0 - _oldAmount) + _newAmount)});
      } else {
        //  if oldType was expense ----------->
        databaseMethods.updateBookTransactions(widget.trData.bookId!,
            {'expense': FieldValue.increment((0.0 - _oldAmount) + _newAmount)});
      }
    } else {
      //  If newType is Expense ---------------->

      double _oldAmount = double.parse(widget.trData.amount!);
      double _newAmount = double.parse(amountField.text);
      String _oldType = widget.trData.type!;

      //--------------------------------------------
      if (_oldType == 'Income') {
        databaseMethods.updateBookTransactions(widget.trData.bookId!,
            {'income': FieldValue.increment((0.0 - _oldAmount) + _newAmount)});
      } else {
        //  if oldType was expense ----------->
        databaseMethods.updateBookTransactions(widget.trData.bookId!,
            {'expense': FieldValue.increment((0.0 - _oldAmount) + _newAmount)});
      }
    }
  }

  updateTransacts() async {
    if (amountField.text != '') {
      if (widget.trData.date! != _selectedDateMap['displayDate'] ||
          widget.trData.time! != _selectedTimeMap['displayTime']) {
        _selectedTimeStamp = await convertTimeToTS(
            _selectedDateMap['tsDate'], _selectedTimeMap['tsTime']);
      }

      Transact updatedTransact = Transact(
        transactId: widget.trData.transactId!,
        amount: amountField.text,
        source: sourceField.text,
        transactMode: transactMode,
        description: descriptionField.text,
        type: transactType,
        date: _selectedDateMap['displayDate'],
        time: _selectedTimeMap['displayTime'],
        bookId: widget.trData.bookId!,
        ts: _selectedTimeStamp,
      );

      databaseMethods.updateTransacts(
        widget.trData.bookId!,
        widget.trData.transactId!,
        updatedTransact.toMap(),
      );

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

  Widget AlertBox(BuildContext context) {
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
            'Delete Transact ?',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          content: Text(
            'Do you really want to delete this Transact ? This cannot be undone!',
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
              onPressed: () {
                _deleteTransact();
                Navigator.pop(context);
              },
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

  _deleteTransact() async {
    setState(() {
      _isLoading = true;
    });
    await DatabaseMethods()
        .deleteTransact(widget.trData.bookId!, widget.trData.transactId!);
    if (transactType == 'Income') {
      Map<String, dynamic> _updatedMap = {
        'income':
            FieldValue.increment(0.0 - double.parse(widget.trData.amount!)),
      };
      await DatabaseMethods().updateBookTransactions(
        widget.trData.bookId!,
        _updatedMap,
      );
    } else {
      Map<String, dynamic> _updatedMap = {
        'expense':
            FieldValue.increment(0.0 - double.parse(widget.trData.amount!)),
      };
      await DatabaseMethods().updateBookTransactions(
        widget.trData.bookId!,
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
    amountField.dispose();
    title.dispose();
    descriptionField.dispose();
    sourceField.dispose();
  }

  // -----------------------------------------

  @override
  Widget build(BuildContext context) {
    setSystemUIColors();
    isDark = Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
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
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
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
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.trData.type! == 'Income'
                                        ? primaryAccentColor.withOpacity(0.3)
                                        : isDark
                                            ? Colors.grey.shade600
                                            : Colors.grey.shade200,
                                    blurRadius: 50,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: TransactTypeCard(
                                icon: widget.trData.type! == 'Income'
                                    ? Icons.file_download_outlined
                                    : Icons.file_upload_outlined,
                                label: widget.trData.type!,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),

                        /// description Box ----------->
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
                                  maxLines: 5,
                                  minLines: 1,
                                  cursorColor:
                                      isDark ? whiteColor : Colors.black,
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
                                            context,
                                            setState,
                                            DateTime.parse(widget.trData.ts!));
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: isDark
                                              ? darkGreyColor
                                              : Colors.white,
                                        ),
                                        child: Text(
                                          _selectedDateMap['displayDate'],
                                          style: TextStyle(
                                            color: isDark
                                                ? whiteColor
                                                : blackColor,
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
                                        context,
                                        setState,
                                        TimeOfDay.fromDateTime(
                                          DateTime.parse(
                                            _selectedDateMap['tsDate'],
                                          ),
                                        ),
                                      );
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
                                        _selectedTimeMap['displayTime'],
                                        style: TextStyle(
                                          color:
                                              isDark ? whiteColor : blackColor,
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
                                  cursorColor:
                                      isDark ? whiteColor : Colors.black,
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
                        SizedBox(
                          height: 10,
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
                        SizedBox(
                          height: sdp(context, 10),
                        ),
                        MaterialButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertBox(context);
                              },
                            );
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
                        BottomCard(context,
                            date: _selectedDateMap['displayDate']),
                      ],
                    ),
                  ),
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

  Container BottomCard(BuildContext context, {String? date}) {
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
                  date!,
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
                                ? primaryAccentColor.withOpacity(0.5)
                                : primaryAccentColor.withOpacity(0.2)
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
                      updateTransacts();
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

  Widget TransactTypeCard({final label, icon}) {
    return MaterialButton(
      onPressed: () {},
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      color: label == 'Expense' ? Colors.black : primaryAccentColor,
      elevation: 0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: label == 'Expense' ? Colors.white : Colors.black,
          ),
          SizedBox(
            width: 7,
          ),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: label == 'Expense' ? Colors.white : Colors.black,
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
}
