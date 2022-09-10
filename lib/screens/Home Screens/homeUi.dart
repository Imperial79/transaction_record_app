import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Functions/homeFunctions.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/colors.dart';
import 'package:transaction_record_app/screens/Home%20Screens/homeMenuUI.dart';
import 'package:transaction_record_app/screens/Transact%20Screens/newTransactUi.dart';
import 'package:transaction_record_app/screens/Book%20Screens/newBookUI.dart';
import 'package:transaction_record_app/services/database.dart';
import 'package:transaction_record_app/screens/Transact%20Screens/setBalanceUi.dart';
import 'package:transaction_record_app/transactBookCard.dart';

import '../../services/user.dart';
import '../../widgets.dart';
import '../Book Screens/bookUI.dart';

class HomeUi extends StatefulWidget {
  @override
  _HomeUiState createState() => _HomeUiState();
}

class _HomeUiState extends State<HomeUi> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  List? data;
  int? currentBalance;
  String dateTitle = '';
  bool showDateWidget = false;

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showAdd = ValueNotifier<bool>(true);

  @override
  void initState() {
    getUserDetailsFromPreference(setState);
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        _showAdd.value = false;
      } else {
        _showAdd.value = true;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Widget BookList() {
    return StreamBuilder<dynamic>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('transact_books')
          .orderBy('bookId', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        return (snapshot.hasData)
            ? (snapshot.data.docs.length == 0)
                ? NewBookCard()
                : ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: snapshot.data.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.docs[index];

                      return TransactBookCard(ds);
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
      ),
    );

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
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
                                  children: [
                                    SizedBox(
                                      height: size.height * 0.02,
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          CircleAvatar(
                                            radius: 15,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child:
                                                  UserDetails.userProfilePic ==
                                                          ''
                                                      ? Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            color:
                                                                primaryAccentColor,
                                                            strokeWidth: 1.5,
                                                          ),
                                                        )
                                                      : CachedNetworkImage(
                                                          imageUrl: UserDetails
                                                              .userProfilePic,
                                                          fit: BoxFit.cover,
                                                        ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Hi ',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: UserDetails
                                                        .userDisplayName
                                                        .split(' ')
                                                        .first,
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          CircleAvatar(
                                            radius: 21,
                                            backgroundColor: Colors.grey,
                                            child: CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.white,
                                              child: IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons
                                                      .keyboard_arrow_down_rounded,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: GestureDetector(
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
                                                  fontSize: 40,
                                                  fontWeight: FontWeight.w200,
                                                ),
                                              ),
                                              StreamBuilder<dynamic>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('users')
                                                    .doc(FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    DocumentSnapshot ds =
                                                        snapshot.data;
                                                    double currBal =
                                                        double.parse(
                                                            ds['currentBalance']
                                                                .toString());
                                                    return Text(
                                                      currBal
                                                          .toStringAsFixed(2),
                                                      style: TextStyle(
                                                        fontSize: 40,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                    );
                                                  }
                                                  return CircularProgressIndicator(
                                                    color: primaryColor,
                                                    strokeWidth: 1.5,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                        );
                      }),
                ),

                //  Scrollable body
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          StreamBuilder<dynamic>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .where('uid', isEqualTo: UserDetails.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data.docs.length == 0) {
                                  return Text('No Data');
                                }
                                DocumentSnapshot ds = snapshot.data.docs[0];
                                return Row(
                                  children: [
                                    Expanded(
                                      child: StatsCard(
                                        label: 'Income',
                                        content: ds['income'].toString(),
                                        isBook: false,
                                        bookId: '',
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: StatsCard(
                                        label: 'Expenses',
                                        content: ds['expense'].toString(),
                                        isBook: false,
                                        bookId: '',
                                      ),
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
                            height: 20,
                          ),
                          Divider(
                            color: Colors.grey.shade600,
                          ),
                          Text(
                            'Transact Book',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          BookList(),
                          SizedBox(
                            height: size.height * 0.07,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // HomeMenuUI(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: InkWell(
        onTap: () {
          NavPush(
            context,
            NewBookUI(),
          );
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            // color: Theme.of(context).cardColor,
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
                          'New Book',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
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

  Widget TransactBookCard(ds) {
    var todayDate = DateFormat.yMMMMd().format(DateTime.now());

    if (dateTitle == ds['date']) {
      showDateWidget = false;
    } else {
      dateTitle = ds['date'];
      showDateWidget = true;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: showDateWidget,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0),
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
            NavPush(context, BookUI(snap: ds));
          },
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.symmetric(
              vertical: 17,
              horizontal: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 17,
                  child: Icon(
                    Icons.book,
                    size: 18,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ds['bookName'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Visibility(
                      visible: ds['bookDescription'].toString().isNotEmpty,
                      child: Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Icon(Icons.segment),
                            SizedBox(
                              width: 5,
                            ),
                            Text(ds['bookDescription']),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      ds['date'],
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Container NewBookCard() => Container(
        width: double.infinity,
        padding: EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create your first Transact Book',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Track your daily expenses by creating categorised Transact Book',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topRight,
              child: MaterialButton(
                onPressed: () {
                  NavPush(context, NewBookUI());
                },
                color: Colors.grey,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  alignment: Alignment.center,
                  width: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bolt_outlined,
                        color: Colors.yellow,
                      ),
                      Text(
                        'Create',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
