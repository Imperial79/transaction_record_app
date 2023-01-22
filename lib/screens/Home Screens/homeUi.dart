import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Functions/homeFunctions.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/colors.dart';
import 'package:transaction_record_app/screens/Account%20Screen/accountUI.dart';
import 'package:transaction_record_app/screens/Home%20Screens/homeMenuUI.dart';
import 'package:transaction_record_app/screens/Book%20Screens/newBookUI.dart';
import 'package:transaction_record_app/services/database.dart';
import 'package:transaction_record_app/services/size.dart';
import '../../services/user.dart';
import '../../components.dart';
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

  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ValueNotifier<bool> _showAdd = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _showHomeMenu = ValueNotifier<bool>(false);

  bool isKeyboardOpen = false;

  @override
  void initState() {
    dateTitle = '';
    getUserDetailsFromPreference(setState);
    _scrollFunction();
    super.initState();
  }

  _scrollFunction() {
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
                ? NewBookCard(context)
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _searchController.text.isEmpty
                            ? Text(
                                'Recent Books',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: isDark ? whiteColor : blackColor,
                                ),
                              )
                            : Text(
                                'Searching for "${_searchController.text}"',
                                style: TextStyle(
                                  color:
                                      isDark ? greyColorAccent : darkGreyColor,
                                ),
                              ),
                        SizedBox(
                          height: 5,
                        ),
                        ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: snapshot.data.docs.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            dateTitle = '';
                            DocumentSnapshot ds = snapshot.data.docs[index];
                            if (_searchController.text.isEmpty) {
                              return TransactBookCard(ds);
                            } else {
                              if (ds['bookName'].toLowerCase().contains(
                                      _searchController.text
                                          .toLowerCase()
                                          .trim()) ||
                                  ds['bookDescription'].toLowerCase().contains(
                                      _searchController.text
                                          .toLowerCase()
                                          .trim())) {
                                return TransactBookCard(ds);
                              }
                              return Container();
                            }
                          },
                        ),
                      ],
                    ),
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
    setSystemUIColors();
    _searchController.text.isEmpty ? _showAdd.value = true : false;
    isDark = Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AnimatedSize(
              reverseDuration: Duration(milliseconds: 300),
              duration: Duration(milliseconds: 300),
              alignment: Alignment.topCenter,
              curve: Curves.ease,
              child: ValueListenableBuilder<bool>(
                valueListenable: _showHomeMenu,
                builder: (BuildContext context, bool showFullHomeMenu,
                    Widget? child) {
                  return AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    reverseDuration: Duration(milliseconds: 100),
                    child: showFullHomeMenu ? HomeMenuUI() : Container(),
                  );
                },
              ),
            ),
            AnimatedSize(
              reverseDuration: Duration(milliseconds: 300),
              duration: Duration(milliseconds: 300),
              alignment: Alignment.topCenter,
              curve: Curves.ease,
              child: ValueListenableBuilder<bool>(
                  valueListenable: _showAdd,
                  builder: (BuildContext context, bool showFullAppBar,
                      Widget? child) {
                    return Container(
                      child: showFullAppBar
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          NavPush(
                                              context,
                                              AccountUI(
                                                name:
                                                    UserDetails.userDisplayName,
                                                email: UserDetails.userEmail,
                                              ));
                                        },
                                        child: Hero(
                                          tag: 'profImg',
                                          child: CircleAvatar(
                                            backgroundColor: primaryAccentColor,
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
                                                  fontWeight: FontWeight.w400,
                                                  color: isDark
                                                      ? whiteColor
                                                      : blackColor,
                                                ),
                                              ),
                                              TextSpan(
                                                text: UserDetails
                                                    .userDisplayName
                                                    .split(' ')
                                                    .first,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900,
                                                  color: isDark
                                                      ? whiteColor
                                                      : blackColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: isDark
                                            ? cardColordark
                                            : Colors.grey.shade300,
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _showHomeMenu.value =
                                                  !_showHomeMenu.value;
                                            });
                                          },
                                          icon: Icon(
                                            _showHomeMenu.value
                                                ? Icons
                                                    .keyboard_arrow_up_rounded
                                                : Icons
                                                    .keyboard_arrow_down_rounded,
                                            size: 17,
                                            color: isDark
                                                ? whiteColor
                                                : blackColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    );
                  }),
            ),
            Expanded(
              child: ListView(
                controller: _scrollController,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  SearchBar(),
                  SizedBox(
                    height: 15,
                  ),
                  BookList(),
                  SizedBox(
                    height: 70,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: isKeyboardOpen
          ? Container()
          : InkWell(
              onTap: () {
                NavPush(
                  context,
                  NewBookUI(),
                );
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark ? Colors.greenAccent : blackColor,
                ),
                child: AnimatedSize(
                  reverseDuration: Duration(milliseconds: 300),
                  duration: Duration(milliseconds: 300),
                  alignment: Alignment.centerLeft,
                  curve: Curves.ease,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _showAdd,
                    builder: (
                      BuildContext context,
                      bool showFullAddBtn,
                      Widget? child,
                    ) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: showFullAddBtn
                              ? sdp(context, 11)
                              : sdp(context, 9),
                          vertical: sdp(context, 9),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: isDark ? blackColor : Colors.white,
                              size: 30,
                            ),
                            if (showFullAddBtn) const SizedBox(width: 10),
                            if (showFullAddBtn)
                              Text(
                                'Create Book',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: sdp(context, 11),
                                  color: isDark ? blackColor : Colors.white,
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
            ),
    );
  }

  Widget TransactBookCard(ds) {
    var todayDate = DateFormat.yMMMMd().format(DateTime.now());
    int amtPercentage = 0;
    Color bgColor = Colors.white;
    Color fgColor = Colors.white;

    if (ds['expense'] != 0 && ds['income'] != 0) {
      amtPercentage = ((ds['expense'] / ds['income']) * 100).round();
    } else {
      amtPercentage = 0;
    }

    if (amtPercentage == 0) {
      bgColor = Colors.grey.shade300;
    } else if (amtPercentage <= 40) {
      bgColor = primaryAccentColor;
      fgColor = primaryColor;
    } else if (amtPercentage > 40 && amtPercentage <= 60) {
      bgColor = Colors.amber.shade100;
      fgColor = Colors.amber;
    } else {
      bgColor = Colors.red.shade100;
      fgColor = Colors.red;
    }

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
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              dateTitle == todayDate ? 'Today' : dateTitle,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? greyColorAccent : blackColor,
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
            decoration: BoxDecoration(
              color: amtPercentage > 100
                  ? isDark
                      ? Colors.red.shade700
                      : Colors.red.shade100
                  : isDark
                      ? Color(0xFF303030)
                      : cardColorlight,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: sdp(context, 8.5),
                    right: sdp(context, 8.5),
                    top: sdp(context, 10),
                    bottom: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: amtPercentage / 100,
                            backgroundColor: bgColor.withOpacity(0.2),
                            color: fgColor,
                          ),
                          amtPercentage < 100
                              ? Text(
                                  amtPercentage.toString() + '%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: sdp(context, 8.5),
                                    color: isDark ? whiteColor : blackColor,
                                  ),
                                )
                              : Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red,
                                ),
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ds['bookName'],
                              style: TextStyle(
                                fontSize: sdp(context, 15.5),
                                fontWeight: FontWeight.w700,
                                color: isDark ? whiteColor : blackColor,
                              ),
                            ),
                            Visibility(
                              visible:
                                  ds['bookDescription'].toString().isNotEmpty,
                              child: Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.segment,
                                      color: isDark ? whiteColor : blackColor,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      ds['bookDescription'],
                                      style: TextStyle(
                                        color: isDark ? whiteColor : blackColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: isDark ? whiteColor : blackColor,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  ds['date'] + ' at ' + ds['time'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isDark ? greyColorAccent : blackColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8, right: 8, bottom: 10),
                  child: Row(
                    children: [
                      TransactStatsCard(
                        crossAlign: CrossAxisAlignment.start,
                        amount: "₹ " + oCcy.format(ds['income']),
                        label: 'Income',
                        cardColor: isDark
                            ? Color.fromARGB(255, 0, 66, 2)
                            : Color.fromARGB(255, 181, 255, 183),
                        icon: Icons.file_download_outlined,
                      ),
                      Text(
                        ' - ',
                        style: TextStyle(
                          fontSize: sdp(context, 20),
                          color: isDark ? whiteColor : blackColor,
                        ),
                      ),
                      TransactStatsCard(
                        crossAlign: CrossAxisAlignment.center,
                        amount: "₹ " + oCcy.format(ds['expense']),
                        label: 'Expense',
                        cardColor: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        icon: Icons.file_upload_outlined,
                      ),
                      Text(
                        ' = ',
                        style: TextStyle(
                          fontSize: sdp(context, 15),
                          color: isDark ? whiteColor : blackColor,
                        ),
                      ),
                      TransactStatsCard(
                        crossAlign: CrossAxisAlignment.end,
                        label: 'Final',
                        amount:
                            "₹ " + oCcy.format(ds['income'] - ds['expense']),
                        icon: Icons.wallet,
                        cardColor: isDark
                            ? Color.fromARGB(255, 0, 82, 150)
                            : Color.fromARGB(255, 197, 226, 250),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget TransactStatsCard({
    final amount,
    cardColor,
    label,
    icon,
    required CrossAxisAlignment crossAlign,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
          // border: Border.all(color: )
        ),
        child: Column(
          crossAxisAlignment: crossAlign,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark ? greyColorAccent : blackColor,
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: sdp(context, 10),
                color: isDark ? greyColorAccent : blackColor,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }

  Widget SearchBar() {
    return Row(
      children: [
        Flexible(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isDark ? cardColordark : cardColorlight,
              borderRadius: BorderRadius.horizontal(
                right:
                    Radius.circular(_searchController.text.isNotEmpty ? 15 : 0),
              ),
            ),
            child: TextField(
              controller: _searchController,
              keyboardType: TextInputType.text,
              style: TextStyle(
                fontSize: sdp(context, 15),
                color: isDark ? whiteColor : blackColor,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(15),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  size: sdp(context, 20),
                  color: isDark ? greyColorAccent : Colors.grey.shade600,
                ),
                hintText: 'Search for Name or Description',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: isDark ? greyColorAccent : Colors.grey.shade600,
                  fontSize: sdp(context, 15),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _showAdd.value = false;
                });
              },
            ),
          ),
        ),
        Visibility(
          visible: _searchController.text.isNotEmpty,
          child: IconButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
              });
            },
            icon: Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}
