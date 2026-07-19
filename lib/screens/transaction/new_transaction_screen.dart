import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart' hide PermissionStatus;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/helpers/transaction_helper.dart';
import 'package:transaction_record_app/repositories/auth_repository.dart';
import 'package:transaction_record_app/components/common/k_scaffold.dart';
import 'package:transaction_record_app/models/transactModel.dart';
import 'package:transaction_record_app/services/database.dart';
import 'package:transaction_record_app/components/common/widgets.dart';
import '../../utility/commons.dart';
import '../../utility/newColors.dart';
import '../../Utility/KButton.dart';
import '../../Utility/constants.dart';

class NewTransactionScreen extends ConsumerStatefulWidget {
  final String bookType;
  final String bookId;

  const NewTransactionScreen({
    super.key,
    required this.bookType,
    required this.bookId,
  });

  @override
  ConsumerState<NewTransactionScreen> createState() =>
      _NewTransactionScreenState();
}

class _NewTransactionScreenState extends ConsumerState<NewTransactionScreen> {
  final DatabaseMethods databaseMethods = DatabaseMethods();
  final TextEditingController amountField = TextEditingController();
  final TextEditingController sourceField = TextEditingController();
  final TextEditingController descriptionField = TextEditingController();

  String transactType = "Income";
  String transactMode = 'CASH';

  Map<String, dynamic> _selectedDateMap = {
    'displayDate': DateFormat.yMMMMd().format(DateTime.now()),
    'tsDate': DateTime.now().toString(),
  };

  Map<String, dynamic> _selectedTimeMap = {
    'displayTime': DateFormat('hh:mm a').format(DateTime.now()),
    'tsTime': DateFormat('HH:mm').format(DateTime.now()),
  };

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  late FocusNode _amountFocusNode;

  @override
  void initState() {
    super.initState();
    _amountFocusNode = FocusNode();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _amountFocusNode.requestFocus();
    });

    if (widget.bookType == "savings") {
      transactType = "Income";
    }
  }

  @override
  void dispose() {
    _amountFocusNode.dispose();
    amountField.dispose();
    descriptionField.dispose();
    sourceField.dispose();
    super.dispose();
  }

  void handleBookStatsUpdate(String uploadableAmount) {
    Map<String, dynamic> updateMap = {
      transactType == 'Income' ? 'income' : 'expense': FieldValue.increment(
        double.parse(uploadableAmount),
      ),
    };
    databaseMethods.updateBookTransactions(widget.bookId, updateMap);
  }

  Future<void> saveTransaction(String uid) async {
    if (amountField.text.isEmpty) return;

    FocusScope.of(context).unfocus();
    try {
      isLoading.value = true;

      final String timestamp = convertTimeToTS(
        _selectedDateMap['tsDate'],
        _selectedTimeMap['tsTime'],
      );

      final uploadableAmount = amountField.text
          .replaceAll(' ', '')
          .replaceAll(',', '');

      Transact newTransact = Transact(
        uid: uid,
        transactId: timestamp,
        amount: uploadableAmount,
        source: sourceField.text,
        transactMode: transactMode,
        description: descriptionField.text,
        type: transactType,
        date: _selectedDateMap['displayDate'],
        time: _selectedTimeMap['displayTime'],
        bookId: widget.bookId,
        ts: timestamp,
      );

      databaseMethods.uploadTransacts(
        newTransact.toMap(),
        widget.bookId,
        timestamp,
      );

      await FirebaseFirestore.instance
          .collection('transactBooks')
          .doc(widget.bookId)
          .update({"createdAt": "${DateTime.now()}"});

      handleBookStatsUpdate(uploadableAmount);

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        KSnackbar(
          context,
          content: "Unable to create transaction!",
          isDanger: true,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _pickContact() async {
    PermissionStatus status = await Permission.contacts.status;
    if (status.isDenied) status = await Permission.contacts.request();

    if (status.isGranted) {
      final contact = await FlutterContacts.native.showPicker();
      if (contact != null) {
        setState(() => sourceField.text = contact.displayName ?? '');
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        kAlertDialog(
          context,
          title: "PERMISSION REQUIRED",
          subTitle:
              "Contacts permission is required to pick a contact. Please enable it in settings.",
          actions: [
            KButton.text(
              context,
              onTap: () => Navigator.pop(context),
              label: "CANCEL",
            ),
            KButton.themed(
              context,
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              label: "SETTINGS",
              color: context.primaryColor,
            ),
          ],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isIncome = transactType == 'Income';
    final accentColor = isIncome ? context.profitColor : context.lossColor;

    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(APP_PADDING),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x),
                  ),
                  if (widget.bookType != "savings")
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.textColor.lighten(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _typeTab('Income', LucideIcons.arrowDownLeft),
                          _typeTab('Expense', LucideIcons.arrowUpRight),
                        ],
                      ),
                    ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      "ENTER AMOUNT (INR)",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: context.fadeTextColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountField,
                      focusNode: _amountFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        letterSpacing: -2,
                      ),
                      decoration: InputDecoration(
                        hintText: "0",
                        hintStyle: TextStyle(color: accentColor.lighten(0.2)),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 48),
                    _inputBox(
                      label: "DESCRIPTION",
                      icon: LucideIcons.fileText,
                      child: TextField(
                        controller: descriptionField,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: "What's this for?",
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _inputBox(
                      label: "SOURCE / PERSON",
                      icon: LucideIcons.user,
                      child: TextField(
                        controller: sourceField,
                        decoration: InputDecoration(
                          hintText: "Who is this from/to?",
                          border: InputBorder.none,
                          isDense: true,
                          suffixIcon: IconButton(
                            onPressed: _pickContact,
                            icon: const Icon(LucideIcons.contact, size: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _inputBox(
                            label: "DATE",
                            icon: LucideIcons.calendar,
                            onTap: () async {
                              final res = await selectDate(
                                context,
                                setState,
                                DateTime.now(),
                              );
                              setState(() => _selectedDateMap = res);
                            },
                            child: Text(
                              _selectedDateMap['displayDate'].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: APP_PADDING),
                        Expanded(
                          child: _inputBox(
                            label: "TIME",
                            icon: LucideIcons.clock,
                            onTap: () async {
                              final res = await selectTime(
                                context,
                                setState,
                                TimeOfDay.now(),
                              );
                              setState(() => _selectedTimeMap = res);
                            },
                            child: Text(
                              _selectedTimeMap['displayTime'].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _inputBox(
                      label: "PAYMENT MODE",
                      icon: LucideIcons.banknote,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            transactMode,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: transactMode == 'ONLINE'
                                  ? Colors.blue
                                  : context.profitColor,
                            ),
                          ),
                          _modeToggle(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: KButton.full(
                context,
                label: "SAVE TRANSACTION",
                onPressed: () => saveTransaction(user!.uid),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeTab(String label, IconData icon) {
    final isSelected = transactType == label;
    final isIncome = label == 'Income';
    return GestureDetector(
      onTap: () => setState(() => transactType = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: APP_PADDING,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isIncome ? context.profitColor : context.lossColor)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? context.scaffoldColor : context.fadeTextColor,
            ),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isSelected
                    ? context.scaffoldColor
                    : context.fadeTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputBox({
    required String label,
    required IconData icon,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(APP_PADDING),
        decoration: BoxDecoration(
          border: Border.all(color: context.textColor.lighten(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: context.fadeTextColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: context.fadeTextColor,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _modeToggle() {
    final isOnline = transactMode == 'ONLINE';
    return GestureDetector(
      onTap: () => setState(() => transactMode = isOnline ? 'CASH' : 'ONLINE'),
      child: Container(
        width: 60,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: context.textColor.lighten(0.2)),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: isOnline
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 30,
                height: 28,
                color: isOnline ? Colors.blue : context.profitColor,
                child: Icon(
                  isOnline ? LucideIcons.globe : LucideIcons.banknote,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
