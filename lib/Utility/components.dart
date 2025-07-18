// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/screens/Book%20Screens/New_Book_UI.dart';
import '../Helper/navigatorFns.dart';
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

Widget FirstTransactCard(BuildContext context, String bookId) {
  bool isDark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    margin: const EdgeInsets.only(top: 0),
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? Colors.amber : Colors.amber.shade100,
      borderRadius: kRadius(30),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create your first Transact',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Track your daily expenses by creating Transacts.',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
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
                  color: isDark ? Colors.amberAccent : Colors.orange,
                  blurRadius: 100,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                navPush(context, New_Book_UI());
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
                style: TextStyle(color: isDark ? Colors.black : Colors.white),
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

// Widget DummyTransactList(bool isDark) {
//   return Column(
//     children: [
//       for (int i = 0; i <= 10; i++)
//         Container(
//           margin: const EdgeInsets.only(bottom: 20),
//           child: Container(
//             padding: const EdgeInsets.all(10),
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: isDark ? const Color(0xFF333333) : Light.card,
//               borderRadius: kRadius(20),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(10),
//                                 height: 40,
//                                 width: 40,
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey.lighten(0.5),
//                                   shape: BoxShape.circle,
//                                 ),
//                               ),
//                               const SizedBox(
//                                 width: 10,
//                               ),
//                               Container(
//                                 width: 200,
//                                 height: 20,
//                                 color: Colors.grey.lighten(0.5),
//                               ),
//                               const Spacer(),
//                             ],
//                           ),
//                           const SizedBox(
//                             height: 10,
//                           ),
//                           Container(
//                             width: 200,
//                             height: 20,
//                             color: Colors.grey.lighten(0.5),
//                           ),
//                           Container(
//                             width: 200,
//                             height: 20,
//                             color: Colors.grey.lighten(0.5),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.lighten(0.5),
//                     borderRadius: kRadius(100),
//                   ),
//                   child: const SizedBox(
//                     width: 200,
//                     height: 20,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//     ],
//   );
// }

Widget StatsCard(
  BuildContext context, {
  required String label,
  required String content,
  required bool isBook,
  required String bookId,
}) {
  bool isExpense = label == 'Expenses';
  bool isDark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: kRadius(15),
      color: isExpense ? const Color(0xffca705f) : Dark.profitCard,
      border: Border.all(
        color:
            isExpense
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

Widget ConfirmDeleteModal({
  required String label,
  required String content,
  required VoidCallback onDelete,
}) {
  return StatefulBuilder(
    builder: (context, setState) {
      bool isDark = Theme.of(context).brightness == Brightness.dark;
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20),
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
                height10,
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
                height20,
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
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: onDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? Colors.black : Light.profitText,
                        foregroundColor:
                            isDark ? Dark.profitText : Colors.white,
                      ),
                      child: const Text('Yes'),
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
    icon: Icon(icon, size: iconSize),
    label: Text(label, style: TextStyle(fontSize: labelSize)),
  );
}

Widget kCard(
  BuildContext context, {
  required List<Widget> children,
  required IconData icon,
  required String title,
}) {
  bool isDark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: isDark ? Dark.card : Light.card,
      borderRadius: kRadius(15),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: isDark ? Colors.white : Colors.black),
            width10,
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
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
  bool isDark = Theme.of(context).brightness == Brightness.dark;
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );
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
        icon: const Icon(Icons.delete, color: Colors.red, size: 30),
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
      margin: const EdgeInsets.all(15),
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: kRadius(20),
        gradient: const LinearGradient(
          colors: [Light.profitCard, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Create your first Transact Book',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 30,
              letterSpacing: 1,
            ),
          ),
          height10,
          const Text(
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
                ref
                    .watch(pageControllerProvider)
                    .animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
              },
              child: const Text('Create'),
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
  bool isDark = Theme.of(context).brightness == Brightness.dark;
  return InkWell(
    onTap: onTap,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: kRadius(20),
        color: isDark ? Colors.greenAccent : Colors.black,
      ),
      child: AnimatedSize(
        reverseDuration: const Duration(milliseconds: 300),
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.centerLeft,
        curve: Curves.ease,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: showFullBtn ? 12 : 10,
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
              if (showFullBtn) const SizedBox(width: 10),
              if (showFullBtn)
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Dark.card : Light.card),
            borderRadius: kRadius(100),
          ),
          child: Row(
            children: [
              CircleAvatar(child: Icon(Icons.search)),
              width15,
              Flexible(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 15),
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
  bool isDark = Theme.of(context).brightness == Brightness.dark;
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
