import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Helper/transactFunctions.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/KButton.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/models/transactModel.dart';
import 'package:transaction_record_app/services/database.dart';
import '../../Utility/commons.dart';
import '../../Utility/newColors.dart';

class New_Transact_UI extends ConsumerStatefulWidget {
  final String bookType;
  final String bookId;

  const New_Transact_UI({
    super.key,
    required this.bookType,
    required this.bookId,
  });
  @override
  ConsumerState<New_Transact_UI> createState() =>
      _New_Transact_UIState(bookType, bookId);
}

class _New_Transact_UIState extends ConsumerState<New_Transact_UI> {
  final String bookType;
  final String bookId;
  _New_Transact_UIState(this.bookType, this.bookId);

  DatabaseMethods databaseMethods = DatabaseMethods();
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
  final Map<String, dynamic> _todayTimeMap = {
    'displayTime': DateFormat('hh:mm a').format(DateTime.now()),
    'tsTime': DateFormat('HH:mm').format(DateTime.now()),
  };
  final isLoading = ValueNotifier(false);
  late FocusNode _amountFocusNode;

  @override
  void initState() {
    super.initState();
    _amountFocusNode = FocusNode();
    // Delay focus to prevent jank during page transition
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountFocusNode.dispose();
    amountField.dispose();
    descriptionField.dispose();
    sourceField.dispose();
    super.dispose();
  }

  void handleNewNoteTransaction(String uploadableAmount) {
    if (transactType == 'Income') {
      Map<String, dynamic> newMap = {
        'income': FieldValue.increment(double.parse(uploadableAmount)),
      };
      databaseMethods.updateBookTransactions(bookId, newMap);
    } else {
      Map<String, dynamic> newMap = {
        'expense': FieldValue.increment(double.parse(uploadableAmount)),
      };
      databaseMethods.updateBookTransactions(bookId, newMap);
    }
  }

  Future<void> saveTransacts(String uid) async {
    FocusScope.of(context).unfocus();
    try {
      isLoading.value = true;
      if (amountField.text != '') {
        if (_todayTimeMap['displayDate'] != _selectedDateMap['displayDate'] ||
            _todayTimeMap['displayTime'] != _selectedTimeMap['displayTime']) {
          _selectedTimeStamp = convertTimeToTS(
            _selectedDateMap['tsDate'],
            _selectedTimeMap['tsTime'],
          );
        }
        transactId = _selectedTimeStamp;
        final uploadableAmount = amountField.text
            .replaceAll(' ', '')
            .replaceAll(',', '');

        Transact newTransact = Transact(
          uid: uid,
          transactId: transactId,
          amount: uploadableAmount,
          source: sourceField.text,
          transactMode: transactMode,
          description: descriptionField.text,
          type: bookType == "savings" ? "Income" : transactType,
          date: _selectedDateMap['displayDate'],
          time: _selectedTimeMap['displayTime'],
          bookId: bookId,
          ts: _selectedTimeStamp,
        );

        databaseMethods.uploadTransacts(
          newTransact.toMap(),
          bookId,
          transactId,
        );

        await FirebaseFirestore.instance
            .collection('transactBooks')
            .doc(bookId)
            .update({"createdAt": "${DateTime.now()}"});

        handleNewNoteTransaction(uploadableAmount);

        amountField.clear();
        descriptionField.clear();
        sourceField.clear();
        transactType = 'Income';
        source = 'From';

        if (context.mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        KSnackbar(context, content: "Unable to create Transact!", isDanger: true);
      }
    } finally {
      isLoading.value = false;
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isIncome = transactType == 'Income';
    final primaryColor = isIncome ? context.profitColor : context.lossColor;
    final primaryBg = isIncome
        ? kColor(context).primaryContainer
        : kColor(context).errorContainer;

    return KScaffold(
      isLoading: isLoading,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 30),
            decoration: BoxDecoration(
              color: primaryBg,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                      if (bookType != "savings")
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _typeTab('Income', Icons.south_west_rounded),
                              _typeTab('Expense', Icons.north_east_rounded),
                            ],
                          ),
                        ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "ENTER AMOUNT",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: primaryColor.withAlpha(180),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextField(
                      controller: amountField,
                      focusNode: _amountFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                      decoration: InputDecoration(
                        prefixText: "₹ ",
                        prefixStyle: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w400,
                          color: primaryColor,
                        ),
                        hintText: "0",
                        hintStyle: TextStyle(
                          color: primaryColor.withAlpha(100),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _entryCard(
                    icon: Icons.notes_rounded,
                    title: "Description",
                    child: TextField(
                      controller: descriptionField,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: "What was this for?",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _entryCard(
                    icon: Icons.person_rounded,
                    title: "Source / Person",
                    child: TextField(
                      controller: sourceField,
                      decoration: InputDecoration(
                        hintText: "Who is this from/to?",
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          onPressed: _pickContact,
                          icon: const Icon(Icons.contact_page_rounded),
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
                          icon: Icons.calendar_today_rounded,
                          title: "Date",
                          onTap: () async {
                            _selectedDateMap = await selectDate(
                              context,
                              setState,
                              DateTime.now(),
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
                          icon: Icons.schedule_rounded,
                          title: "Time",
                          onTap: () async {
                            _selectedTimeMap = await selectTime(
                              context,
                              setState,
                              TimeOfDay.now(),
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
                    icon: Icons.account_balance_wallet_rounded,
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
                                ? Colors.blue
                                : Colors.green,
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: KButton.full(
              context,
              label: "SAVE TRANSACTION",
              onPressed: () => saveTransacts(user!.uid),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeTab(String label, IconData icon) {
    bool isSelected = transactType == label;
    bool isIncome = label == 'Income';
    return GestureDetector(
      onTap: () => setState(() => transactType = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isIncome
                    ? kColor(context).primaryContainer
                    : context.lossCardColor)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : context.fadeTextColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : context.fadeTextColor,
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.fadeTextColor.withAlpha(20)),
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
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          color: isOnline
              ? Colors.blue.withAlpha(40)
              : Colors.green.withAlpha(40),
          borderRadius: BorderRadius.circular(50),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isOnline ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isOnline ? Colors.blue : Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isOnline ? Colors.blue : Colors.green).withAlpha(100),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              isOnline ? Icons.language_rounded : Icons.payments_rounded,
              size: 14,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
