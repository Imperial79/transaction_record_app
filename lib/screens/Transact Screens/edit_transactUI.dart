// ignore_for_file: non_constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/KButton.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/KTextfield.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import '../../Functions/transactFunctions.dart';
import '../../Utility/commons.dart';
import '../../models/transactModel.dart';
import '../../services/database.dart';
import '../../Utility/components.dart';

class EditTransactUI extends ConsumerStatefulWidget {
  final Transact trData;
  const EditTransactUI({super.key, required this.trData});

  @override
  ConsumerState<EditTransactUI> createState() => _EditTransactUIState();
}

class _EditTransactUIState extends ConsumerState<EditTransactUI> {
  //  Variables -------------->

  DatabaseMethods databaseMethods = DatabaseMethods();
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
    amountField.text = widget.trData.amount;
    descriptionField.text = widget.trData.description;
    sourceField.text = widget.trData.source;
    _selectedDateMap['displayDate'] = widget.trData.date;
    _selectedDateMap['tsDate'] = widget.trData.ts;
    _selectedTimeMap['displayTime'] = widget.trData.time;
    _selectedTimeStamp = widget.trData.ts;
    transactId = widget.trData.transactId;
    transactType = widget.trData.type;
    transactMode = widget.trData.transactMode;
    setState(() {});
  }

  handleEditedNoteTransaction() {
    //  calculating the Income and Expense for edited transact
    if (transactType == 'Income') {
      //  If newType is INCOME
      //--------------------------------------------

      double oldAmount = double.parse(widget.trData.amount);
      double newAmount = double.parse(amountField.text);
      String oldType = widget.trData.type;

      //--------------------------------------------

      if (oldType == 'Income') {
        databaseMethods.updateBookTransactions(widget.trData.bookId,
            {'income': FieldValue.increment((0.0 - oldAmount) + newAmount)});
      } else {
        //  if oldType was expense ----------->
        databaseMethods.updateBookTransactions(widget.trData.bookId,
            {'expense': FieldValue.increment((0.0 - oldAmount) + newAmount)});
      }
    } else {
      //  If newType is Expense ---------------->

      double oldAmount = double.parse(widget.trData.amount);
      double newAmount = double.parse(amountField.text);
      String oldType = widget.trData.type;

      //--------------------------------------------
      if (oldType == 'Income') {
        databaseMethods.updateBookTransactions(widget.trData.bookId,
            {'income': FieldValue.increment((0.0 - oldAmount) + newAmount)});
      } else {
        //  if oldType was expense ----------->
        databaseMethods.updateBookTransactions(widget.trData.bookId,
            {'expense': FieldValue.increment((0.0 - oldAmount) + newAmount)});
      }
    }
  }

  updateTransacts(String uid) async {
    if (amountField.text != '') {
      if (widget.trData.date != _selectedDateMap['displayDate'] ||
          widget.trData.time != _selectedTimeMap['displayTime']) {
        _selectedTimeStamp = convertTimeToTS(
            _selectedDateMap['tsDate'], _selectedTimeMap['tsTime']);
      }

      Transact updatedTransact = Transact(
        uid: uid,
        transactId: widget.trData.transactId,
        amount: amountField.text,
        source: sourceField.text,
        transactMode: transactMode,
        description: descriptionField.text,
        type: transactType,
        date: _selectedDateMap['displayDate'],
        time: _selectedTimeMap['displayTime'],
        bookId: widget.trData.bookId,
        ts: _selectedTimeStamp,
      );
      databaseMethods.updateTransacts(
        widget.trData.bookId,
        widget.trData.transactId,
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
          // shape: RoundedRectangleBorder(
          //   borderRadius: kRadius(12),
          // ),
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
            size: 30,
          ),
          title: Text(
            'Delete Transact ?',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          content: const Text(
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
              child: const Text(
                'Cancel',
              ),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteTransact();
              },
              color: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: kRadius(5),
              ),
              elevation: 0,
              child: const Text(
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
    try {
      setState(() {
        _isLoading = true;
      });
      await DatabaseMethods()
          .deleteTransact(widget.trData.bookId, widget.trData.transactId);
      if (transactType == 'Income') {
        Map<String, dynamic> updatedMap = {
          'income':
              FieldValue.increment(0.0 - double.parse(widget.trData.amount)),
        };
        await DatabaseMethods().updateBookTransactions(
          widget.trData.bookId,
          updatedMap,
        );
      } else {
        Map<String, dynamic> updatedMap = {
          'expense':
              FieldValue.increment(0.0 - double.parse(widget.trData.amount)),
        };
        await DatabaseMethods().updateBookTransactions(
          widget.trData.bookId,
          updatedMap,
        );
      }

      Navigator.pop(context);
    } catch (e) {
      KSnackbar(context, content: "Something went wrong!", isDanger: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
    isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);
    return KScaffold(
      isLoading: _isLoading,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
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
                  const Spacer(),
                  _modeIndicatorPill(widget.trData.type),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KTextfield.regular(
                      isDark,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      controller: descriptionField,
                      maxLines: 4,
                      minLines: 1,
                      hintText: 'Add description (Optional)',
                      icon: const CircleAvatar(
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
                          const SizedBox(
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
                                        DateTime.parse(widget.trData.ts));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: kRadius(10),
                                      color:
                                          isDark ? Dark.scaffold : Colors.white,
                                    ),
                                    child: Text(
                                      _selectedDateMap['displayDate'],
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
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
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: kRadius(10),
                                    color:
                                        isDark ? Dark.scaffold : Light.scaffold,
                                  ),
                                  child: Text(
                                    _selectedTimeMap['displayTime'],
                                    style: const TextStyle(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      controller: sourceField,
                      maxLines: 4,
                      minLines: 1,
                      hintText: 'Add source (Optional)',
                      icon: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.amber.shade900,
                        child: const Icon(
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
                            children: const [
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
                    height20,
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
                        borderRadius: kRadius(10),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 25,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: kRadius(10),
                          gradient: LinearGradient(
                            colors: [
                              Colors.red,
                              Colors.red.shade900,
                            ],
                          ),
                        ),
                        child: const Row(
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
                    height20,
                    // BottomCard(context, date: _selectedDateMap['displayDate']),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10),
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
                            padding: const EdgeInsets.only(right: 10.0),
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
                              const BoxConstraints(minHeight: 0, minWidth: 0),
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
                    KButton.icon(
                      isDark,
                      isOutlined: true,
                      onPressed: () {
                        updateTransacts(user!.uid);
                      },
                      backgroundColor: transactType == "Income"
                          ? isDark
                              ? Dark.primaryAccent
                              : Light.primaryAccent
                          : isDark
                              ? Dark.lossCard
                              : Light.lossCard,
                      icon: Icon(
                        transactType == 'Income'
                            ? Icons.file_download_outlined
                            : Icons.file_upload_outlined,
                        color: transactType == "Income"
                            ? isDark
                                ? Dark.primaryAccent
                                : Light.primaryAccent
                            : isDark
                                ? Dark.lossCard
                                : Light.lossCard,
                      ),
                      label: "Update transact",
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

  Widget _modeIndicatorPill(String mode) {
    return _typeBtn(
      icon: mode == 'Income'
          ? Icons.file_download_outlined
          : Icons.file_upload_outlined,
      label: widget.trData.type,
    );
  }

  Widget _typeBtn({final label, icon}) {
    return MaterialButton(
      onPressed: () {},
      shape: RoundedRectangleBorder(
        borderRadius: kRadius(50),
      ),
      color: label == 'Expense'
          ? isDark
              ? Dark.lossCard
              : Light.lossCard
          : isDark
              ? Dark.profitCard
              : Light.profitCard,
      elevation: 0,
      highlightElevation: 0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: label == 'Expense' ? Colors.white : Colors.black,
          ),
          const SizedBox(
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
        padding: const EdgeInsets.all(10),
        width: 300,
        decoration: BoxDecoration(
          color: (transactMode == 'ONLINE' ? Colors.blue : Colors.lightGreen)
              .withOpacity(0.2),
          borderRadius: kRadius(50),
        ),
        child: AnimatedAlign(
          curve: Curves.ease,
          duration: const Duration(milliseconds: 250),
          alignment:
              transactMode == 'ONLINE' ? Alignment.topRight : Alignment.topLeft,
          child: CircleAvatar(
            backgroundColor: transactMode == 'ONLINE'
                ? Colors.blue.shade700
                : Colors.lightGreen,
            radius: 20,
            child: transactMode == 'ONLINE'
                ? const Icon(
                    Icons.webhook_sharp,
                    color: Colors.white,
                    size: 20,
                  )
                : const Text(
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
}
