import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Functions/transactFunctions.dart';
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
  String transactMode = 'CASH';
  DateTime _selectedDate = DateTime.now();
  String _selectedTimeStamp = DateTime.now().toString();
  String _selectedTime =
      DateFormat().add_jm().format(DateTime.now()).toString();

  @override
  void initState() {
    super.initState();
    onPageLoad();
  }

  onPageLoad() {
    setState(() {
      var formatedDate = DateFormat.yMMMMd().format(DateTime.now());
      print('Formated Date (onPageLoad) -' + formatedDate);

      // var formatter = DateFormat('dd MMMM, yyyy - ').add_jm().format(DateTime.now());
      String currentTimeStamp = DateTime.now().toString();
      print('Current TS (onPageLoad) - ' + currentTimeStamp);
    });
  }

  convertTimeToTS(date, time) {
    var nowNanoSec = DateTime.now().toString().split('.').last;
    _selectedTimeStamp = date.toString().split(' ').first +
        ' ' +
        time.toString().split(' ').first +
        ':00.$nowNanoSec';

    return _selectedTimeStamp;
  }

  saveTransacts() {
    print(convertTimeToTS(_selectedDate, _selectedTime));
    if (amountField.text != '') {
      convertTimeToTS(_selectedDate, _selectedTime);
      Map<String, dynamic> transactMap = {
        'title': title.text,
        "amount": amountField.text,
        "source": sourceField.text,
        "transactMode": transactMode,
        "description": descriptionField.text,
        "type": transactType,
        'date': DateFormat.yMMMMd().format(_selectedDate),
        'time': _selectedTime,
        'ts': _selectedTimeStamp,
      };
      databaseMethods.uploadTransacts(UserDetails.uid, transactMap);
      if (transactType == 'Income') {
        //  UPDATING (Increment) THE CURRENT BALANCE IN DB
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

        //  UPDATING (Increment) THE CURRENT BALANCE IN DB
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

      transactType = 'Income';
      source = 'From';
    }
  }

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
                        padding:
                            EdgeInsets.symmetric(horizontal: 13, vertical: 20),
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
                                      _selectedDate =
                                          await selectDate(context, setState);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                      ),
                                      child: Text(
                                        DateFormat.yMMMMd()
                                            .format(_selectedDate),
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
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: Text(
                                      _selectedTime,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            ///////////////////////
                            // Text(
                            //   DateFormat('dd MMMM')
                            //           .format(_selectedDate)
                            //           .toString() +
                            //       ' at ' +
                            //       _selectedTime.hour.toString() +
                            //       ':' +
                            //       _selectedTime.minute.toString(),
                            // DateFormat()
                            //     .add_jm()
                            //     .format(_selectedTime)
                            //     .toString(),
                            //   style: TextStyle(
                            //     color: Colors.black,
                            //     fontWeight: FontWeight.w600,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 13, vertical: 10),
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
                    ],
                  ),
                ),
              ),
            ),
            Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          width: 200,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: amountField,
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
                            items: <String>['CASH', 'ONLINE']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
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
                              // formatter,
                              // currentTime,
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
                                color: transactType == 'Income'
                                    ? Colors.green.shade900
                                    : Colors.white,
                              ),
                              SizedBox(
                                width: 5,
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
