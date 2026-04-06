// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/helpers/navigation_helper.dart';
import 'package:transaction_record_app/models/transactModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transaction_record_app/repositories/auth_repository.dart';
import 'package:transaction_record_app/screens/book/new_book_screen.dart';
import 'CustomLoading.dart';
import 'commons.dart';

Widget kPill({
  required Widget child,
  EdgeInsetsGeometry? padding,
  Color? color,
}) {
  return Container(
    padding: padding,
    decoration: BoxDecoration(color: color, borderRadius: kRadius(100)),
    child: child,
  );
}

void showRenameBookModal(
  BuildContext context,
  WidgetRef ref, {
  required String bookId,
  required String initialName,
}) {
  final controller = TextEditingController(text: initialName);
  bool isLoading = false;
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    isScrollControlled: true,
    builder: (modalContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              margin: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: kRadius(20),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: context.isDarkMode
                          ? Colors.blue.shade100
                          : Colors.blueAccent,
                      child: Text(
                        'Aa',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: context.isDarkMode
                              ? Colors.blue.shade800
                              : Colors.white,
                        ),
                      ),
                    ),
                    height10,
                    Text(
                      'Rename Book',
                      style: TextStyle(
                        color: context.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Change the book name',
                      style: TextStyle(
                        color: context.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    height20,
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      autofocus: true,
                      enabled: !isLoading,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: context.textColor,
                      ),
                      cursorColor: context.primaryColor,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: context.primaryColor,
                            width: 2,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: context.fadeTextColor.withAlpha(50),
                          ),
                        ),
                        hintText: 'Book title',
                        hintStyle: TextStyle(
                          fontSize: 24,
                          color: context.fadeTextColor.withAlpha(100),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    height25,
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.fadeTextColor.withAlpha(
                                20,
                              ),
                              foregroundColor: context.textColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        width15,
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (controller.text.trim().isNotEmpty) {
                                      setState(() => isLoading = true);
                                      final name = controller.text.trim();
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('transactBooks')
                                            .doc(bookId)
                                            .update({'bookName': name});
                                        Navigator.pop(modalContext);
                                        Navigator.pop(context);
                                        KSnackbar(
                                          context,
                                          content: "Book Renamed!",
                                        );
                                      } catch (e) {
                                        setState(() => isLoading = false);
                                        KSnackbar(
                                          context,
                                          content: "Failed to rename book!",
                                          isDanger: true,
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kColor(context).tertiary,
                              foregroundColor: kColor(context).onTertiary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: isLoading
                                ? const CustomLoading()
                                : const Text('Update'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget FirstTransactCard(BuildContext context, String bookId) {
  return Container(
    margin: const EdgeInsets.only(top: 0),
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: context.isDarkMode
          ? context.primaryColor.withAlpha(40)
          : context.primaryColor.withAlpha(30),
      borderRadius: kRadius(30),
      border: Border.all(color: context.primaryColor.withAlpha(50)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create your first Transact',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: context.isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Track your daily expenses by creating Transacts.',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: context.isDarkMode ? Colors.white70 : Colors.black87,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: context.isDarkMode
                      ? Colors.amberAccent
                      : Colors.orange,
                  blurRadius: 100,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                navPush(context, NewBookScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                elevation: 0,
              ),
              icon: Icon(
                LucideIcons.bolt,
                color: context.isDarkMode ? Colors.black : Colors.white,
              ),
              label: Text(
                'Create',
                style: TextStyle(
                  color: context.isDarkMode ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Transact ",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 25,
                    color: Colors.grey.shade600,
                  ),
                ),
                TextSpan(
                  text: "Record",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 25,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Made by Avishek Verma',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

Widget StatsCard(
  BuildContext context, {
  required String label,
  required String content,
  required bool isBook,
  required String bookId,
}) {
  bool isExpense = label == 'Expenses';
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: kRadius(15),
      color: isExpense ? context.lossCardColor : context.profitCardColor,
      border: Border.all(
        color: (isExpense ? context.lossColor : context.profitColor).withAlpha(
          50,
        ),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(
              isExpense ? LucideIcons.upload : LucideIcons.download,
              color: isExpense ? Colors.white : Colors.black,
            ),
            width5,
            Expanded(
              child: Text(
                '${kMoneyFormat(content)} INR',
                style: TextStyle(
                  color: isExpense ? context.lossColor : context.profitColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget ConfirmDeleteModal({
  required String label,
  required String content,
  required VoidCallback onDelete,
}) {
  return StatefulBuilder(
    builder: (context, setState) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: kRadius(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: context.lossCardColor,
                  child: Text(
                    '!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: context.lossColor,
                    ),
                  ),
                ),
                height10,
                Text(
                  label,
                  style: TextStyle(
                    color: context.colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  content,
                  style: TextStyle(
                    color: context.lossColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                height20,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.isDarkMode
                            ? Colors.black
                            : Colors.grey.shade200,
                        foregroundColor: context.isDarkMode
                            ? Colors.white70
                            : Colors.black87,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text('CANCEL'),
                    ),
                    ElevatedButton(
                      onPressed: onDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.lossColor,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text('YES'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget BookMenuBtn({
  required void Function()? onPressed,
  required String label,
  required IconData icon,
  required Color btnColor,
  required Color textColor,
  double? labelSize,
  double? iconSize,
}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: btnColor,
      foregroundColor: textColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    icon: Icon(icon, size: iconSize),
    label: Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: labelSize ?? 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
    ),
  );
}

Widget kCard(
  BuildContext context, {
  required List<Widget> children,
  required IconData icon,
  required String title,
}) {
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: context.cardColor,
      borderRadius: kRadius(15),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: context.colorScheme.onSurface),
            width10,
            Text(
              title,
              style: TextStyle(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        height15,
        ...children,
      ],
    ),
  );
}

void setSystemUIColors(BuildContext context) {
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      statusBarBrightness: context.isDarkMode
          ? Brightness.dark
          : Brightness.light,
      statusBarIconBrightness: context.isDarkMode
          ? Brightness.light
          : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: context.isDarkMode
          ? Brightness.light
          : Brightness.dark,
    ),
  );
}

bool isKeyboardOpen(BuildContext context) {
  return MediaQuery.of(context).viewInsets.bottom != 0;
}

Widget kDeleteAlertDialog(
  BuildContext context, {
  final label,
  content,
  onPress,
}) {
  return StatefulBuilder(
    builder: (context, StateSetter setState) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: kRadius(12)),
        icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 30),
        title: Text(label, style: const TextStyle(color: Colors.black)),
        content: Text(
          content,
          style: const TextStyle(
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
            onPressed: onPress,
            color: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: kRadius(5)),
            elevation: 0,
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

Widget NewBookCard(BuildContext context) => Consumer(
  builder: (context, ref, _) {
    return Container(
      margin: const EdgeInsets.all(APP_PADDING),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            context.primaryColor,
            context.primaryColor.withAlpha(200),
            Colors.black,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ready to Track?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 28,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first book and start managing your finances with ease.',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                ref
                    .watch(pageControllerProvider)
                    .animateToPage(
                      1,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn,
                    );
              },
              icon: const Icon(LucideIcons.plus),
              label: const Text('Create Book'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  },
);

Widget AnimatedFloatingButton(
  BuildContext context, {
  void Function()? onTap,
  required Widget icon,
  required String label,
  required bool showFullBtn,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(border: Border.all(color: context.textColor)),
      padding: EdgeInsets.symmetric(
        horizontal: showFullBtn ? 20 : 15,
        vertical: 12,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.plus, color: context.textColor, size: 18),
          if (showFullBtn) const SizedBox(width: 8),
          if (showFullBtn)
            Text(
              'NEW BOOK',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 2,
                color: context.textColor,
              ),
            ),
        ],
      ),
    ),
  );
}

Widget KSearchBar(
  BuildContext context, {
  TextEditingController? controller,
  void Function(String)? onChanged,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: context.isDarkMode
          ? context.cardColor.lighten(0.05)
          : context.cardColor,
      border: Border.all(color: context.textColor.lighten(0.1)),
    ),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      cursorColor: context.primaryColor,
      decoration: InputDecoration(
        prefixIcon: Icon(
          LucideIcons.search,
          color: context.textColor.lighten(0.4),
          size: 18,
        ),
        hintText: 'SEARCH TRANSACTIONS...',
        hintStyle: TextStyle(
          color: context.fadeTextColor.lighten(0.4),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: APP_PADDING,
          vertical: 15,
        ),
      ),
    ),
  );
}

Widget NoData(BuildContext context, {String customText = "No Data"}) {
  return Center(
    child: Text(
      customText,
      style: TextStyle(fontSize: 30, color: context.fadeTextColor),
    ),
  );
}

class TransactTile extends ConsumerWidget {
  final Transact data;
  final bool showUser;
  final VoidCallback onTap;
  final bool isDark;

  const TransactTile({
    super.key,
    required this.data,
    this.showUser = false,
    required this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isIncome = data.type == 'Income';
    final user = ref.watch(userProvider);
    final isMine = data.uid == user?.uid;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(APP_PADDING),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.fadeTextColor.withAlpha(15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 0 : 5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isIncome
                        ? context.profitColor.withAlpha(30)
                        : context.lossColor.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isIncome
                        ? LucideIcons.arrowDownLeft
                        : LucideIcons.arrowUpRight,
                    size: 18,
                    color: isIncome ? context.profitColor : context.lossColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "₹${kMoneyFormat(data.amount)}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isIncome
                                  ? context.profitColor
                                  : context.lossColor,
                            ),
                          ),
                          _buildModeBadge(context, data.transactMode),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 12,
                            color: context.fadeTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data.time,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.fadeTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (data.source.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Icon(
                              LucideIcons.user,
                              size: 12,
                              color: context.fadeTextColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              data.source,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.fadeTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (data.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.scaffoldColor.withAlpha(
                    context.isDarkMode ? 100 : 150,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.isDarkMode ? Colors.white70 : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            if (showUser && !isMine) ...[
              const SizedBox(height: 12),
              FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(data.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final userData = snapshot.data!.data();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Added by ${userData?['name'] ?? 'User'}",
                          style: TextStyle(
                            fontSize: 10,
                            color: context.fadeTextColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 10,
                          backgroundImage: NetworkImage(
                            userData?['imgUrl'] ?? '',
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeBadge(BuildContext context, String mode) {
    bool isCash = mode.toUpperCase() == 'CASH';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCash ? Colors.amber.withAlpha(30) : Colors.blue.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        mode.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: isCash ? Colors.amber.shade700 : Colors.blue.shade700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
