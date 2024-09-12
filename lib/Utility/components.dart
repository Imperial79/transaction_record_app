// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transaction_record_app/Functions/bookFunctions.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/screens/Home%20Screens/Home_UI.dart';
import 'package:transaction_record_app/screens/rootUI.dart';
import '../Functions/navigatorFns.dart';
import '../screens/Transact Screens/new_transactUi.dart';

const String appLogoPath = 'lib/assets/logo/logo.png';

Widget get height5 => SizedBox(height: 5);
Widget get height10 => SizedBox(height: 10);
Widget get height15 => SizedBox(height: 15);
Widget get height20 => SizedBox(height: 20);
Widget get width5 => SizedBox(width: 5);
Widget get width10 => SizedBox(width: 10);
Widget get width15 => SizedBox(width: 15);
Widget get width20 => SizedBox(width: 20);

Widget kHeight(double height) => SizedBox(height: height);
Widget kWidth(double width) => SizedBox(width: width);

BorderRadius kRadius(double radius) => BorderRadius.circular(radius);

Widget kPill({
  required Widget child,
  EdgeInsetsGeometry? padding,
  Color? color,
}) {
  return Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: kRadius(100),
    ),
    child: child,
  );
}

Widget FirstTransactCard(BuildContext context, String bookId) {
  return Container(
    margin: EdgeInsets.only(top: 0),
    width: double.infinity,
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? Colors.amber : Colors.amber.shade100,
      borderRadius: kRadius(30),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create your first Transact',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Track your daily expenses by creating Transacts.',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: 15,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.amberAccent : Colors.orange,
                  blurRadius: 100,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                navPush(
                  context,
                  New_Transact_UI(
                    bookId: bookId,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.amber.shade100 : Colors.orange,
                elevation: 0,
              ),
              icon: Icon(
                Icons.bolt,
                color: isDark ? Colors.black : Colors.white,
              ),
              label: Text(
                'Create',
                style: TextStyle(
                  color: isDark ? Colors.black : Colors.white,
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
  const AppTitle({
    Key? key,
  }) : super(key: key);

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
          )
        ],
      ),
    );
  }
}

Widget DummyTransactList(BuildContext context) {
  return Column(
    children: [
      for (int i = 0; i <= 10; i++)
        Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Container(
            padding: EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF333333) : Light.card,
              borderRadius: kRadius(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 200,
                                height: 20,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              Spacer(),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 200,
                            height: 20,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          Container(
                            width: 200,
                            height: 20,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: kRadius(100),
                  ),
                  child: Container(
                    width: 200,
                    height: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

Widget StatsCard({final label, content, isBook, bookId}) {
  bool isExpense = label == 'Expenses';
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: kRadius(15),
      color: isExpense ? Color(0xffca705f) : Dark.profitCard,
      border: Border.all(
        color: isExpense
            ? isDark
                ? Colors.red.shade100
                : Colors.red.shade900
            : isDark
                ? Colors.white
                : Colors.teal.shade700,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(
              isExpense
                  ? Icons.file_upload_outlined
                  : Icons.file_download_outlined,
              color: isExpense ? Colors.white : Colors.black,
            ),
            width5,
            Expanded(
              child: Text(
                '${kMoneyFormat(content)} INR',
                style: TextStyle(
                  color: isExpense ? Colors.white : Colors.black,
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

Widget kRenameModal({
  required String bookId,
  required String oldBookName,
}) {
  final newBookName = new TextEditingController(text: oldBookName);
  return StatefulBuilder(
    builder: (context, setState) {
      return SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          margin: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: isDark ? Dark.card : Light.card,
            borderRadius: kRadius(20),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                      isDark ? Colors.blue.shade100 : Colors.blueAccent,
                  child: Text(
                    'Aa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.blue.shade800 : Colors.white,
                    ),
                  ),
                ),
                height10,
                Text(
                  'Rename Book',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Change the book name',
                  style: TextStyle(
                    color: isDark ? Colors.blue.shade300 : Colors.blueAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                height20,
                TextField(
                  controller: newBookName,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  cursorWidth: 1,
                  cursorColor: isDark ? Colors.white : Colors.black,
                  decoration: InputDecoration(
                    focusColor: isDark ? Colors.white : Colors.black,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Dark.scaffold : Colors.black,
                        width: 2,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Dark.scaffold : Colors.grey.shade300,
                      ),
                    ),
                    hintText: 'Book title',
                    hintStyle: TextStyle(
                      fontSize: 30,
                      color: isDark ? Dark.scaffold : Colors.grey.shade400,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      newBookName.text = value;
                    });
                  },
                ),
                height20,
                ElevatedButton.icon(
                  onPressed: () async {
                    await BookMethods.editBookName(
                      context,
                      newBookName: newBookName.text,
                      bookId: bookId,
                    );
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.file_upload_outlined),
                  label: Text('Update'),
                ),
              ],
            ),
          ),
        ),
      );
    },
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
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? Dark.card : Light.card,
            borderRadius: kRadius(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                      isDark ? Colors.red.shade100 : Colors.redAccent,
                  child: Text(
                    '!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.red.shade800 : Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  content,
                  style: TextStyle(
                    color: isDark ? Colors.red.shade300 : Colors.redAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.black : Light.lossCard,
                        foregroundColor:
                            isDark ? Colors.red.shade300 : Colors.white,
                      ),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: onDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? Colors.black : Light.profitText,
                        foregroundColor:
                            isDark ? Dark.profitText : Colors.white,
                      ),
                      child: Text('Yes'),
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
    ),
    icon: Icon(
      icon,
      size: iconSize,
    ),
    label: Text(
      label,
      style: TextStyle(
        fontSize: labelSize,
      ),
    ),
  );
}

Widget kCard(BuildContext context, {required Widget child}) {
  return Container(
    padding: EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: isDark ? Dark.card : Light.card,
      borderRadius: kRadius(15),
    ),
    child: child,
  );
}

setSystemUIColors(BuildContext context) {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ),
  );
}

bool isKeyboardOpen(BuildContext context) {
  return MediaQuery.of(context).viewInsets.bottom != 0;
}

Widget ALertBox(BuildContext context, {final label, content, onPress}) {
  return StatefulBuilder(
    builder: (context, StateSetter setState) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: kRadius(12),
        ),
        icon: Icon(
          Icons.delete,
          color: Colors.red,
          size: 30,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        content: Text(
          content,
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
            onPressed: onPress,
            color: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: kRadius(5),
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

Widget NewBookCard(BuildContext context) => Container(
      margin: EdgeInsets.all(15),
      width: double.infinity,
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: kRadius(20),
        gradient: LinearGradient(
          colors: [
            Light.profitCard,
            Colors.black,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Create your first Transact Book',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 30,
              letterSpacing: 1,
            ),
          ),
          height10,
          Text(
            'Track your daily expenses by creating categorised Transact Book',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          height10,
          Align(
            alignment: Alignment.topRight,
            child: ElevatedButton(
              onPressed: () {
                pageControllerGlobal.value.animateToPage(
                  1,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
              child: Text('Create'),
            ),
          ),
        ],
      ),
    );

Widget BookDeleteModal({
  required String bookName,
  required String bookId,
}) {
  return StatefulBuilder(
    builder: (context, setState) {
      return SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: isDark ? Dark.card : Light.card,
            borderRadius: kRadius(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: isDark ? Colors.grey.shade300 : Colors.black,
                  child: SvgPicture.asset(
                    'lib/assets/icons/options.svg',
                    colorFilter: svgColor(
                      isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Book Options",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      await BookMethods.deleteBook(
                        context,
                        bookName: bookName,
                        bookId: bookId,
                      );
                      Navigator.pop(context);
                      kSnackbar(context,
                          content: "\"$bookName\" Book Deleted!");
                    } catch (e) {
                      kSnackbar(
                        context,
                        content:
                            "Unable to delete book! Check your connection or try again later.",
                        isDanger: true,
                      );
                    }
                  },
                  child: Card(
                    elevation: 0,
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Card(
                            color: isDark ? Colors.red.shade100 : Colors.red,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: SvgPicture.asset(
                                'lib/assets/icons/delete.svg',
                                colorFilter: svgColor(
                                  isDark ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Text(
                              "Delete book",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color:
                                    isDark ? Colors.red.shade200 : Colors.red,
                              ),
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
        ),
      );
    },
  );
}

Widget AnimatedFloatingButton(
  BuildContext context, {
  void Function()? onTap,
  required Widget icon,
  required String label,
}) {
  return InkWell(
    onTap: onTap,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: kRadius(20),
        color: isDark ? Colors.greenAccent : Colors.black,
      ),
      child: AnimatedSize(
        reverseDuration: Duration(milliseconds: 300),
        duration: Duration(milliseconds: 300),
        alignment: Alignment.centerLeft,
        curve: Curves.ease,
        child: ValueListenableBuilder<bool>(
          valueListenable: showAdd,
          builder: (
            BuildContext context,
            bool showFullAddBtn,
            Widget? child,
          ) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: showFullAddBtn ? 12 : 10,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: isDark ? Colors.black : Colors.white,
                    size: 30,
                  ),
                  if (showFullAddBtn) const SizedBox(width: 10),
                  if (showFullAddBtn)
                    Text(
                      'Create Book',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}

Widget KSearchBar(
  BuildContext context, {
  required bool isDark,
  TextEditingController? controller,
  void Function(String)? onChanged,
}) {
  return Row(
    children: [
      Flexible(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Dark.card : Light.card,
            borderRadius: kRadius(100),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isDark ? Dark.primary : Light.primary,
                child: SvgPicture.asset(
                  "lib/assets/icons/search.svg",
                  height: 20,
                  colorFilter: svgColor(isDark ? Colors.black : Colors.white),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Flexible(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search by name or amount',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: isDark ? Dark.fadeText : Light.fadeText,
                      fontSize: 17,
                    ),
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget NoData(BuildContext context, {String customText = "No Data"}) {
  return Center(
    child: Text(
      customText,
      style: TextStyle(
        fontSize: 30,
        color: isDark ? Dark.fadeText : Light.fadeText,
      ),
    ),
  );
}
