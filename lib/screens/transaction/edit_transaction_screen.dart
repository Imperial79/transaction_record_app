import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/utility/KButton.dart';
import 'package:transaction_record_app/helpers/transaction_helper.dart';
import 'package:transaction_record_app/repositories/auth_repository.dart';
import 'package:transaction_record_app/components/common/k_scaffold.dart';
import 'package:transaction_record_app/models/transactModel.dart';
import 'package:transaction_record_app/services/database.dart';
import '../../utility/commons.dart';
import '../../utility/newColors.dart';
import '../../Utility/constants.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  final Transact trData;
  const EditTransactionScreen({super.key, required this.trData});

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  //  Variables -------------->

  DatabaseMethods databaseMethods = DatabaseMethods();
  TextEditingController amountField = TextEditingController();
  TextEditingController sourceField = TextEditingController();
  TextEditingController descriptionField = TextEditingController();
  final isLoading = ValueNotifier(false);

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
  late FocusNode _amountFocusNode;
  @override
  void initState() {
    super.initState();
    _amountFocusNode = FocusNode();
    // Delay focus to prevent jank during page transition
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _amountFocusNode.requestFocus();
    });
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

  void handleEditedNoteTransaction() {
    //  calculating the Income and Expense for edited transact
    if (transactType == 'Income') {
      //  If newType is INCOME
      //--------------------------------------------

      double oldAmount = double.parse(widget.trData.amount);
      double newAmount = double.parse(amountField.text);
      String oldType = widget.trData.type;

      //--------------------------------------------

      if (oldType == 'Income') {
        databaseMethods.updateBookTransactions(widget.trData.bookId, {
          'income': FieldValue.increment((0.0 - oldAmount) + newAmount),
        });
      } else {
        //  if oldType was expense ----------->
        databaseMethods.updateBookTransactions(widget.trData.bookId, {
          'expense': FieldValue.increment((0.0 - oldAmount) + newAmount),
        });
      }
    } else {
      //  If newType is Expense ---------------->

      double oldAmount = double.parse(widget.trData.amount);
      double newAmount = double.parse(amountField.text);
      String oldType = widget.trData.type;

      //--------------------------------------------
      if (oldType == 'Income') {
        databaseMethods.updateBookTransactions(widget.trData.bookId, {
          'income': FieldValue.increment((0.0 - oldAmount) + newAmount),
        });
      } else {
        //  if oldType was expense ----------->
        databaseMethods.updateBookTransactions(widget.trData.bookId, {
          'expense': FieldValue.increment((0.0 - oldAmount) + newAmount),
        });
      }
    }
  }

  Future<void> updateTransacts(String uid) async {
    try {
      isLoading.value = true;
      if (amountField.text != '') {
        if (widget.trData.date != _selectedDateMap['displayDate'] ||
            widget.trData.time != _selectedTimeMap['displayTime']) {
          _selectedTimeStamp = convertTimeToTS(
            _selectedDateMap['tsDate'],
            _selectedTimeMap['tsTime'],
          );
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

        if (context.mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        KSnackbar(context, content: "Something went wrong!", isDanger: true);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Widget AlertBox(bool isDark) {
    return StatefulBuilder(
      builder: (context, StateSetter setState) {
        return AlertDialog(
          // shape: RoundedRectangleBorder(
          //   borderRadius: kRadius(12),
          // ),
          icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 30),
          title: Text(
            'Delete Transact ?',
            style: TextStyle(color: context.colorScheme.onSurface),
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
              child: const Text('Cancel'),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteTransact();
              },
              color: Colors.red,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
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

  Future<void> _deleteTransact() async {
    try {
      isLoading.value = true;

      await DatabaseMethods().deleteTransact(
        widget.trData.bookId,
        widget.trData.transactId,
      );
      if (transactType == 'Income') {
        Map<String, dynamic> updatedMap = {
          'income': FieldValue.increment(
            0.0 - double.parse(widget.trData.amount),
          ),
        };
        await DatabaseMethods().updateBookTransactions(
          widget.trData.bookId,
          updatedMap,
        );
      } else {
        Map<String, dynamic> updatedMap = {
          'expense': FieldValue.increment(
            0.0 - double.parse(widget.trData.amount),
          ),
        };
        await DatabaseMethods().updateBookTransactions(
          widget.trData.bookId,
          updatedMap,
        );
      }

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        KSnackbar(context, content: "Something went wrong!", isDanger: true);
      }
    } finally {
      if (mounted) {
        isLoading.value = false;
      }
    }
  }

  Future<void> _pickContact() async {
    PermissionStatus status = await Permission.contacts.status;

    if (status.isDenied) {
      status = await Permission.contacts.request();
    }

    if (status.isGranted) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        setState(() {
          sourceField.text = contact.displayName;
        });
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Permission Required"),
            content: const Text(
              "Contacts permission is required to pick a contact. Please enable it in app settings.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text("Open Settings"),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        KSnackbar(
          context,
          content: "Contacts permission denied!",
          isDanger: true,
        );
      }
    }
  }

  //------------------------------------->

  @override
  void dispose() {
    _amountFocusNode.dispose();
    amountField.dispose();
    descriptionField.dispose();
    sourceField.dispose();
    super.dispose();
  }

  // -----------------------------------------

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isIncome = transactType == 'Income';
    final primaryColor = isIncome ? context.profitColor : context.lossColor;

    return KScaffold(
      isLoading: isLoading,
      body: Column(
        children: [
          // Standard App Bar for Revision UI
          Container(
            padding: EdgeInsets.fromLTRB(
              APP_PADDING,
              MediaQuery.of(context).padding.top + 10,
              APP_PADDING,
              APP_PADDING,
            ),
            decoration: BoxDecoration(
              color: context.cardColor,
              border: Border(
                bottom: BorderSide(color: context.textColor.lighten(0.1)),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.arrowLeft),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Edit Transaction",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertBox(context.isDarkMode),
                  ),
                  icon: const Icon(
                    LucideIcons.trash2,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const .all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Amount Input - Cleaner and less dominant
                  _entryCard(
                    icon: LucideIcons.banknote,
                    title: "AMOUNT",
                    child: TextField(
                      controller: amountField,
                      focusNode: _amountFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: primaryColor,
                      ),
                      decoration: InputDecoration(
                        prefixText: "₹ ",
                        prefixStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: primaryColor,
                        ),
                        hintText: "0",
                        hintStyle: TextStyle(color: primaryColor.lighten(0.3)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _entryCard(
                    icon: LucideIcons.fileText,
                    title: "Description",
                    child: TextField(
                      controller: descriptionField,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: "Add description...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _entryCard(
                    icon: LucideIcons.user,
                    title: "Source / Person",
                    child: TextField(
                      controller: sourceField,
                      decoration: InputDecoration(
                        hintText: "Who is this from/to?",
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          onPressed: _pickContact,
                          icon: const Icon(LucideIcons.contact),
                          color: context.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _entryCard(
                          icon: LucideIcons.calendar,
                          title: "Date",
                          onTap: () async {
                            _selectedDateMap = await selectDate(
                              context,
                              setState,
                              DateFormat.yMMMMd().parse(
                                _selectedDateMap['displayDate'],
                              ),
                            );
                          },
                          child: Text(
                            _selectedDateMap['displayDate'],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _entryCard(
                          icon: LucideIcons.clock,
                          title: "Time",
                          onTap: () async {
                            _selectedTimeMap = await selectTime(
                              context,
                              setState,
                              TimeOfDay.fromDateTime(
                                DateFormat(
                                  'hh:mm a',
                                ).parse(_selectedTimeMap['displayTime']),
                              ),
                            );
                          },
                          child: Text(
                            _selectedTimeMap['displayTime'],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _entryCard(
                    icon: LucideIcons.wallet,
                    title: "Payment Mode",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          transactMode,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: transactMode == 'ONLINE'
                                ? Colors.blue.shade700
                                : context.profitColor,
                          ),
                        ),
                        _modeToggle(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Action Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: KButton.full(
              context,
              label: "UPDATE TRANSACTION",
              onPressed: () {
                updateTransacts(user!.uid);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _entryCard({
    required IconData icon,
    required String title,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(APP_PADDING),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: context.textColor.lighten(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: context.fadeTextColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: context.fadeTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _modeToggle() {
    bool isOnline = transactMode == 'ONLINE';
    return GestureDetector(
      onTap: () {
        setState(() {
          transactMode = isOnline ? 'CASH' : 'ONLINE';
        });
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        width: 70,
        height: 32,
        decoration: BoxDecoration(
          color: isOnline
              ? Colors.blue.lighten(0.15)
              : context.profitColor.lighten(0.15),
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: isOnline ? Colors.blue : context.profitColor,
            width: 1,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isOnline ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 32,
            height: 24,
            decoration: BoxDecoration(
              color: isOnline ? Colors.blue : context.profitColor,
              borderRadius: BorderRadius.zero,
            ),
            child: Icon(
              isOnline ? LucideIcons.globe : LucideIcons.banknote,
              size: 14,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
