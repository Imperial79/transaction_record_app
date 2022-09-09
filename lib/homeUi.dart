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
import 'package:transaction_record_app/homeMenuUI.dart';
import 'package:transaction_record_app/newTransactUi.dart';
import 'package:transaction_record_app/services/database.dart';
import 'package:transaction_record_app/setBalanceUi.dart';

import 'services/user.dart';

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
  bool _isMenuOpen = false;
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

  Widget transactList() {
    return StreamBuilder<dynamic>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('transacts')
          .orderBy('ts', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        return (snapshot.hasData)
            ? (snapshot.data.docs.length == 0)
                ? FirstCard(context)
                : ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: snapshot.data.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.docs[index];

                      return transactTile(ds: ds);
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

  Container FirstCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create your first Transact',
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
            'Track your daily expenses by creating Transacts.',
            style: TextStyle(
              fontWeight: FontWeight.w600,
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
                NavPush(context, NewTransactUi());
              },
              color: Colors.white,
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
                      color: Colors.amber.shade800,
                    ),
                    Text(
                      'Create',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.amber.shade800,
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
                                                onPressed: () {
                                                  setState(
                                                      () => _isMenuOpen = true);
                                                },
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
                    child: Column(
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
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: StatsCard(
                                        label: 'Income',
                                        content: ds['income'].toString(),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: StatsCard(
                                        label: 'Expenses',
                                        content: ds['expense'].toString(),
                                      ),
                                    ),
                                  ],
                                ),
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
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: transactList(),
                        ),
                        SizedBox(
                          height: size.height * 0.07,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isMenuOpen)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.all(20),
                alignment: Alignment.center,
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _isMenuOpen = !_isMenuOpen;
                          });
                        },
                        icon: Icon(Icons.close),
                      ),
                    ),
                    Text(
                      'data',
                      style: TextStyle(fontSize: 30),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: InkWell(
        onTap: () {
          NavPush(
            context,
            NewTransactUi(),
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
                          'Add',
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

  Widget StatsCard({final label, content}) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: label == 'Expenses'
                  ? Colors.red.shade100.withOpacity(0.6)
                  : primaryColor.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              label == 'Expenses' ? Colors.red : primaryColor,
              label == 'Expenses' ? Colors.red.shade100 : Color(0xFF1FFFB4),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  label == 'Expenses'
                      ? Icons.file_upload_outlined
                      : Icons.file_download_outlined,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              content + ' INR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

//-----------------------------------------------------------------------
  Widget transactTile({final ds}) {
    var todayDate = DateFormat.yMMMMd().format(DateTime.now());
    // print('Todays date = ' + todayDate);
    // print('Incoming Date = ' + ds['date']);
    Size size = MediaQuery.of(context).size;

    // if (todayDate == ds['date']) {
    //   dateTitle = 'Today';
    // } else {
    //   dateTitle = ds['date'];
    // }

    if (dateTitle == ds['date']) {
      showDateWidget = false;
      print({'DateTitle - ' + dateTitle, 'amt - ' + ds['amount']});
    } else {
      dateTitle = ds['date'];
      showDateWidget = true;
      print({'DateTitle - ' + dateTitle, 'amt - ' + ds['amount']});
    }
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
          onTap: () {},
          child: Container(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: ds['transactMode'] == 'CASH'
                              ? Colors.grey.shade800
                              : Colors.blue.shade800,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ds['transactMode'] == 'CASH'
                                ? Text(
                                    '₹ ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontFamily: 'default',
                                    ),
                                  )
                                : Icon(
                                    Icons.payment,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                            SizedBox(
                              width: ds['transactMode'] == 'CASH' ? 0 : 7,
                            ),
                            Text(
                              ds['transactMode'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Container(
                      //   color: Colors.black,
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(Icons.abc),
                      //     ],
                      //   ),
                      // ),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              ds["type"] == 'Income'
                                  ? Icons.file_download_outlined
                                  : Icons.file_upload_outlined,
                              color: ds["type"] == 'Income'
                                  ? Color(0xFF01AF75)
                                  : Colors.red,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: double.parse(ds["amount"]).toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: size.height * 0.03,
                                    color: ds["type"] == 'Income'
                                        ? Color(0xFF01AF75)
                                        : Colors.red.shade900,
                                  ),
                                ),
                                TextSpan(
                                  text: ' INR',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: size.height * 0.03,
                                    color: ds["type"] == 'Income'
                                        ? Color(0xFF01AF75)
                                        : Colors.red.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                          // Text(
                          //   ds['date'].toString().split(' ')[5] +
                          //       ' ' +
                          //       ds['date'].toString().split(' ')[6],
                          //   style: TextStyle(
                          //     color: Colors.grey.shade600,
                          //     fontSize: 13,
                          //     fontWeight: FontWeight.w700,
                          //   ),
                          // ),
                          Text(
                            ds['date'].toString() +
                                ' | ' +
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

//-----------------------------------------------------------------------
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
