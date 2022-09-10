// import 'package:flutter/material.dart';
// import 'package:transaction_record_app/Functions/navigatorFns.dart';
// import 'package:transaction_record_app/screens/Book%20Screens/bookUI.dart';

// class TransactBookCard extends StatelessWidget {
//   final ds;
//   const TransactBookCard({
//     Key? key,
//     this.ds,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         NavPush(context, BookUI(snap: ds));
//       },
//       child: Container(
//         margin: EdgeInsets.only(bottom: 10),
//         padding: EdgeInsets.symmetric(
//           vertical: 17,
//           horizontal: 15,
//         ),
//         decoration: BoxDecoration(
//           color: Colors.blue.withOpacity(0.12),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               ds['bookName'],
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Visibility(
//               visible: ds['bookDescription'].toString().isNotEmpty,
//               child: Row(
//                 children: [
//                   Icon(Icons.segment),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   Text(ds['bookDescription']),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Text(
//               ds['createdOn'],
//               style: TextStyle(
//                 fontStyle: FontStyle.italic,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
