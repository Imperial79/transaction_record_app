import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transaction_record_app/Functions/homeFunctions.dart';
import 'package:transaction_record_app/colors.dart';
import 'package:transaction_record_app/newTranactUi.dart';
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

  @override
  void initState() {
    getUserDetailsFromPreference(setState);
    super.initState();
  }

  Widget transactList() {
    return StreamBuilder<dynamic>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('transacts')
          .orderBy('date', descending: true)
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
            style: GoogleFonts.raleway(
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
            style: GoogleFonts.raleway(
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
                PageRouteTransition.push(context, NewTransactUi());
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
                      style: GoogleFonts.raleway(
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
        systemNavigationBarColor: Colors.white,
        statusBarBrightness: Brightness.light,
      ),
    );

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 15,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: UserDetails.userProfilePic == ''
                          ? Center(
                              child: CircularProgressIndicator(
                                color: primaryAccentColor,
                                strokeWidth: 1.5,
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: UserDetails.userProfilePic,
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
                            style: GoogleFonts.raleway(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: UserDetails.userDisplayName.split(' ').first,
                            style: GoogleFonts.raleway(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
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
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  PageRouteTransition.push(context, SetBalanceUi());
                },
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Text(
                        'INR ',
                        style: GoogleFonts.openSans(
                          fontSize: 40,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      StreamBuilder<dynamic>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            DocumentSnapshot ds = snapshot.data;
                            double currBal =
                                double.parse(ds['currentBalance'].toString());
                            return Text(
                              currBal.toStringAsFixed(2),
                              style: GoogleFonts.openSans(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
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
            Expanded(
              child: SingleChildScrollView(
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        child: Container(
          width: 60,
          height: 60,
          child: Icon(Icons.add),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                // primaryColor,
                // primaryAccentColor,
                Colors.black,
                Colors.grey,
              ],
            ),
          ),
        ),
        onPressed: () {
          PageRouteTransition.effect = TransitionEffect.rightToLeft;
          PageRouteTransition.push(context, NewTransactUi()).then((value) {
            setState(() {
              dateTitle = '';
            });
          });
        },
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
                  style: GoogleFonts.openSans(
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
    var todayDate = DateFormat('dd MMMM').format(DateTime.now());

    Size size = MediaQuery.of(context).size;

    if (dateTitle == ds['date'].toString().split(',').first) {
      showDateWidget = false;
    } else {
      dateTitle = ds['date'].toString().split(',').first;
      showDateWidget = true;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        showDateWidget
            ? Padding(
                padding: EdgeInsets.only(bottom: 10, top: 15),
                child: Text(
                  dateTitle == todayDate ? 'Today' : dateTitle,
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            : Container(),
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
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: 10),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.grey.shade900,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.attach_money_rounded,
                              color: Colors.white,
                            ),
                            Text(
                              'Cash',
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                  style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: size.height * 0.03,
                                    color: ds["type"] == 'Income'
                                        ? Color(0xFF01AF75)
                                        : Colors.red.shade900,
                                  ),
                                ),
                                TextSpan(
                                  text: ' INR',
                                  style: GoogleFonts.openSans(
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
                          ds['source'] == ''
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    ds["type"] == 'Income'
                                        ? 'From: ' + ds['source']
                                        : 'To: ' + ds['source'],
                                    style: GoogleFonts.raleway(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: ds["type"] == 'Income'
                                          ? Colors.green.shade800
                                          : Colors.red,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                          ds["description"] == ''
                              ? Container()
                              : Padding(
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
                                        style: GoogleFonts.raleway(
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
                          Text(
                            ds['date'].toString().split(' ')[5] +
                                ' ' +
                                ds['date'].toString().split(' ')[6],
                            style: GoogleFonts.jost(
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
                  style: GoogleFonts.raleway(
                    fontWeight: FontWeight.w700,
                    fontSize: 25,
                    color: Colors.grey.shade600,
                  ),
                ),
                TextSpan(
                  text: "Record",
                  style: GoogleFonts.raleway(
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
            style: GoogleFonts.raleway(
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
