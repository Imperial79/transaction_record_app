// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class TransactTile extends StatefulWidget {
//   final snap;
//   const TransactTile({Key? key, this.snap}) : super(key: key);

//   @override
//   State<TransactTile> createState() => _TransactTileState();
// }

// class _TransactTileState extends State<TransactTile> {
//   var todayDate = DateFormat.yMMMMd().format(DateTime.now());
//   String dateTitle = '';
//   bool showDateWidget = false;

//   @override
//   void initState() {
//     super.initState();
//     todayDate = DateFormat.yMMMMd().format(DateTime.now());
//     if (dateTitle == widget.snap['date']) {
//       showDateWidget = false;
//     } else {
//       dateTitle = widget.snap['date'];
//       showDateWidget = true;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Visibility(
//           visible: showDateWidget,
//           child: Padding(
//             padding: EdgeInsets.symmetric(vertical: 10),
//             child: Text(
//               dateTitle == todayDate ? 'Today' : dateTitle,
//               style: TextStyle(
//                 fontSize: 15,
//                 color: Colors.black,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//         GestureDetector(
//           onTap: () {},
//           child: Container(
//             child: Column(
//               children: [
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 15,
//                     vertical: 15,
//                   ),
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade200,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         margin: EdgeInsets.only(bottom: 10),
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(5),
//                           color: widget.snap['transactMode'] == 'CASH'
//                               ? Colors.grey.shade800
//                               : Colors.blue.shade800,
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             widget.snap['transactMode'] == 'CASH'
//                                 ? Text(
//                                     '₹ ',
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       color: Colors.white,
//                                       fontFamily: 'default',
//                                     ),
//                                   )
//                                 : Icon(
//                                     Icons.payment,
//                                     color: Colors.white,
//                                     size: 20,
//                                   ),
//                             SizedBox(
//                               width:
//                                   widget.snap['transactMode'] == 'CASH' ? 0 : 7,
//                             ),
//                             Text(
//                               widget.snap['transactMode'],
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w700,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           CircleAvatar(
//                             backgroundColor: Colors.white,
//                             child: Icon(
//                               widget.snap["type"] == 'Income'
//                                   ? Icons.file_download_outlined
//                                   : Icons.file_upload_outlined,
//                               color: widget.snap["type"] == 'Income'
//                                   ? Color(0xFF01AF75)
//                                   : Colors.red,
//                             ),
//                           ),
//                           SizedBox(
//                             width: 10,
//                           ),
//                           RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: double.parse(widget.snap["amount"])
//                                       .toString(),
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w700,
//                                     fontSize: size.height * 0.03,
//                                     color: widget.snap["type"] == 'Income'
//                                         ? Color(0xFF01AF75)
//                                         : Colors.red.shade900,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                   text: ' INR',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w400,
//                                     fontSize: size.height * 0.03,
//                                     color: widget.snap["type"] == 'Income'
//                                         ? Color(0xFF01AF75)
//                                         : Colors.red.shade900,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Visibility(
//                             visible: widget.snap['source'] != '',
//                             child: Padding(
//                               padding: EdgeInsets.only(bottom: 5),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: 10,
//                                       vertical: 5,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(5),
//                                       color: widget.snap["type"] == 'Income'
//                                           ? Colors.green.shade800
//                                           : Colors.red,
//                                     ),
//                                     child: Text(
//                                       widget.snap["type"] == 'Income'
//                                           ? 'From'
//                                           : 'To',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 10,
//                                   ),
//                                   Text(
//                                     widget.snap['source'],
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w600,
//                                       color: widget.snap["type"] == 'Income'
//                                           ? Colors.green.shade800
//                                           : Colors.red,
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Visibility(
//                             visible: widget.snap["description"] != '',
//                             child: Padding(
//                               padding: EdgeInsets.only(bottom: 10),
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     Icons.short_text,
//                                     size: 20,
//                                   ),
//                                   SizedBox(
//                                     width: 5,
//                                   ),
//                                   Text(
//                                     widget.snap["description"],
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.grey.shade800,
//                                     ),
//                                     maxLines: 3,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Text(
//                             widget.snap['date'].toString() +
//                                 ' | ' +
//                                 widget.snap['time'].toString(),
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                               fontSize: 13,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
