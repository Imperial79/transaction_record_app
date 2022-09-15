import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/screens/Transact%20Screens/edit_transactUI.dart';
import 'package:transaction_record_app/screens/Transact%20Screens/new_transactUi.dart';
import '../../Functions/navigatorFns.dart';
import '../../colors.dart';
import '../../services/user.dart';
import '../../widgets.dart';
import '../Transact Screens/setBalanceUi.dart';

class BookUI extends StatefulWidget {
  final snap;
  const BookUI({Key? key, this.snap}) : super(key: key);

  @override
  State<BookUI> createState() => _BookUIState();
}

class _BookUIState extends State<BookUI> {
  String dateTitle = '';
  bool showDateWidget = false;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showAdd = ValueNotifier<bool>(true);
  final oCcy = new NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        _showAdd.value = false;
      } else {
        _showAdd.value = true;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSize(
                duration: Duration(milliseconds: 200),
                child: ValueListenableBuilder<bool>(
                    valueListenable: _showAdd,
                    builder: (BuildContext context, bool showFullAppBar,
                        Widget? child) {
                      return Container(
                        child: showFullAppBar
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: IconButton(
                                      color: textLinkColor,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.arrow_back,
                                            // size: 17,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Return',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    widget.snap['bookName'],
                                    style: TextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                  Text(
                                    widget.snap['date'] +
                                        ', ' +
                                        widget.snap['time'],
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                      );
                    }),
              ),
              Column(
                children: [
                  StreamBuilder<dynamic>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(UserDetails.uid)
                        .collection('transact_books')
                        .where('bookId', isEqualTo: widget.snap['bookId'])
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.docs.length == 0) {
                          return Text('No Data');
                        }
                        DocumentSnapshot ds = snapshot.data.docs[0];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                NavPush(context, SetBalanceUi());
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    Text(
                                      'INR ',
                                      style: TextStyle(
                                        fontSize: 35,
                                        fontWeight: FontWeight.w200,
                                      ),
                                    ),
                                    Expanded(
                                        child: Text(
                                      oCcy.format(ds['income'] - ds['expense']),
                                      style: TextStyle(
                                        fontSize: 35,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: StatsCard(
                                    label: 'Income',
                                    content: ds['income'].toString(),
                                    isBook: true,
                                    bookId: ds['bookId'],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: StatsCard(
                                    label: 'Expenses',
                                    content: ds['expense'].toString(),
                                    isBook: true,
                                    bookId: ds['bookId'],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      TransactList(widget.snap['bookId']),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.07,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: InkWell(
        onTap: () {
          NavPush(
            context,
            NewTransactUi(
              bookId: widget.snap['bookId'],
            ),
          );
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.0),
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Colors.grey,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 100),
              child: ValueListenableBuilder<bool>(
                valueListenable: _showAdd,
                builder: (
                  BuildContext context,
                  bool showFullAddBtn,
                  Widget? child,
                ) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      if (showFullAddBtn) const SizedBox(width: 10),
                      if (showFullAddBtn)
                        Text(
                          'Add',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (showFullAddBtn) const SizedBox(width: 2.5),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget TransactList(String bookId) {
    return StreamBuilder<dynamic>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('transact_books')
          .doc(bookId)
          .collection('transacts')
          .orderBy('ts', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        return (snapshot.hasData)
            ? (snapshot.data.docs.length == 0)
                ? FirstTransactCard(context, bookId)
                : ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: snapshot.data.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.docs[index];

                      return TransactTile(ds);
                    },
                  )
            : Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 1.5,
                  ),
                ),
              );
      },
    );
  }

  Widget TransactTile(ds) {
    var todayDate = DateFormat.yMMMMd().format(DateTime.now());
    if (dateTitle == ds['date']) {
      showDateWidget = false;
    } else {
      dateTitle = ds['date'];
      showDateWidget = true;
    }
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: showDateWidget,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              dateTitle == todayDate ? 'Today' : dateTitle,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            NavPush(
              context,
              EditTransactUI(
                snap: ds,
              ),
            );
          },
          child: Container(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundColor: ds["type"] == 'Income'
                                ? primaryAccentColor
                                : Colors.black,
                            child: Icon(
                              ds["type"] == 'Income'
                                  ? Icons.file_download_outlined
                                  : Icons.file_upload_outlined,
                              color: ds["type"] == 'Income'
                                  ? Colors.black
                                  : Colors.white,
                              size: 17,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: ds['transactMode'] == 'CASH'
                                  ? Colors.white
                                  : Colors.blue.shade100,
                            ),
                            child: Text(
                              ds['transactMode'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: ds['transactMode'] == 'CASH'
                                    ? Colors.black
                                    : Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: double.parse(ds["amount"]).toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: ds["type"] == 'Income'
                                    ? Color(0xFF01AF75)
                                    : Colors.red.shade900,
                                fontFamily: 'Product',
                              ),
                            ),
                            TextSpan(
                              text: ' INR',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 20,
                                color: ds["type"] == 'Income'
                                    ? Color(0xFF01AF75)
                                    : Colors.red.shade900,
                                fontFamily: 'Product',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: ds['source'] != '',
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: ds["type"] == 'Income'
                                          ? Colors.green.shade800
                                          : Colors.red,
                                    ),
                                    child: Text(
                                      ds["type"] == 'Income' ? 'From' : 'To',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    ds['source'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: ds["type"] == 'Income'
                                          ? Colors.green.shade800
                                          : Colors.red,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: ds["description"] != '',
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.short_text,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    ds["description"],
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 15,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                ds['time'].toString(),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
