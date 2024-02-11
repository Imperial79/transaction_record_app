import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Utility/colors.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/screens/Account%20Screen/accountUI.dart';
import 'package:transaction_record_app/screens/Home%20Screens/homeMenuUI.dart';
import 'package:transaction_record_app/services/database.dart';
import '../../Utility/sdp.dart';
import '../../services/user.dart';
import '../../Utility/components.dart';
import '../Book Screens/bookUI.dart';

final ValueNotifier<bool> showAdd = ValueNotifier<bool>(true);
ValueNotifier<String> displayNameGlobal = ValueNotifier(globalUser.name);

class HomeUi extends StatefulWidget {
  @override
  _HomeUiState createState() => _HomeUiState();
}

class _HomeUiState extends State<HomeUi>
    with AutomaticKeepAliveClientMixin<HomeUi> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  List? data;
  String dateTitle = '';
  bool showDateWidget = false;

  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ValueNotifier<bool> _showAdd = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _showHomeMenu = ValueNotifier<bool>(false);

  bool isKeyboardOpen = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    dateTitle = '';

    _scrollFunction();
  }

  _scrollFunction() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        _showAdd.value = false;
        showAdd.value = false;
      } else {
        _showAdd.value = true;
        showAdd.value = true;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Widget BookList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('transactBooks')
          .where('uid', isEqualTo: FirebaseRefs.myUID)
          .orderBy('bookId', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        return (snapshot.hasData)
            ? (snapshot.data!.docs.length == 0)
                ? NewBookCard(context)
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _searchController.text.isEmpty
                            ? Center(
                                child: Text(
                                  'RECENT BOOKS',
                                  style: TextStyle(
                                    fontSize: sdp(context, 10),
                                    letterSpacing: 10,
                                    color: isDark
                                        ? DarkColors.fadeText
                                        : LightColors.fadeText,
                                  ),
                                ),
                              )
                            : Text(
                                'Searching for "${_searchController.text}"',
                                style: TextStyle(
                                  color: isDark
                                      ? DarkColors.fadeText
                                      : LightColors.fadeText,
                                ),
                              ),
                        height10,
                        ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            dateTitle = '';
                            Map<String, dynamic> ds =
                                snapshot.data!.docs[index].data();
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
                          separatorBuilder: (context, index) => height10,
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
    super.build(context);
    setSystemUIColors(context);
    _searchController.text.isEmpty ? _showAdd.value = true : false;
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
                                height10,
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
                                                name: globalUser.name,
                                                email: globalUser.email,
                                              ));
                                        },
                                        child: Hero(
                                          tag: 'profImg',
                                          child: CircleAvatar(
                                            backgroundColor:
                                                darkProfitColorAccent,
                                            radius: 15,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: globalUser.imgUrl == ''
                                                  ? Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color:
                                                            darkProfitColorAccent,
                                                        strokeWidth: 1.5,
                                                      ),
                                                    )
                                                  : CachedNetworkImage(
                                                      imageUrl:
                                                          globalUser.imgUrl,
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
                                        child: Row(
                                          children: [
                                            Text(
                                              'Hi',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w400,
                                                color: isDark
                                                    ? whiteColor
                                                    : blackColor,
                                              ),
                                            ),
                                            width10,
                                            ValueListenableBuilder(
                                              valueListenable:
                                                  displayNameGlobal,
                                              builder: (context, String name,
                                                  child) {
                                                return Text(
                                                  globalUser.name,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w900,
                                                    color: isDark
                                                        ? whiteColor
                                                        : blackColor,
                                                  ),
                                                );
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: isDark
                                            ? cardColordark
                                            : Colors.grey.shade200,
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
                physics: BouncingScrollPhysics(),
                controller: _scrollController,
                children: [
                  height10,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: KSearchBar(
                      context,
                      isDark: isDark,
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _showAdd.value = false;
                        });
                      },
                    ),
                  ),
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
    );
  }

  Widget TransactBookCard(Map<String, dynamic> bookData) {
    var todayDate = DateFormat.yMMMMd().format(DateTime.now());

    if (dateTitle == bookData['date']) {
      showDateWidget = false;
    } else {
      dateTitle = bookData['date'];
      showDateWidget = true;
    }

    // Change Card color -------------------->

    bool isCompleted =
        bookData['expense'] != 0 && (bookData['income'] == bookData['expense']);

    Color _kCardColor = cardColordark;
    if (isCompleted) {
      _kCardColor = isDark ? DarkColors.profitCard : LightColors.profitCard;
    } else {
      _kCardColor = isDark ? DarkColors.card : LightColors.card;
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
        OpenContainer(
          openBuilder: (context, closedContainer) {
            return BookUI(snap: bookData);
          },
          closedElevation: 0,
          closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          openElevation: 0,
          transitionType: ContainerTransitionType.fadeThrough,
          closedColor: isDark ? DarkColors.card : LightColors.card,
          openColor: isDark ? DarkColors.scaffold : LightColors.scaffold,
          middleColor: isDark ? Colors.black : Colors.white,
          closedBuilder: (context, openContainer) {
            return GestureDetector(
              onTap: () {
                openContainer();
              },
              onLongPress: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  builder: (context) {
                    return BookDeleteModal(
                      bookId: bookData['bookId'],
                      bookName: bookData['bookName'],
                    );
                  },
                );
              },
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Card(
                    color: _kCardColor,
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bookData['bookName'],
                                        style: TextStyle(
                                          fontSize: sdp(context, 15.5),
                                          fontWeight: FontWeight.w700,
                                          color:
                                              isDark ? whiteColor : blackColor,
                                        ),
                                      ),
                                      Visibility(
                                        visible: bookData['bookDescription']
                                            .toString()
                                            .isNotEmpty,
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 10),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.note,
                                                color: isDark
                                                    ? whiteColor
                                                    : blackColor,
                                                size: sdp(context, 11),
                                              ),
                                              width5,
                                              Text(
                                                bookData['bookDescription'],
                                                style: TextStyle(
                                                  color: isDark
                                                      ? whiteColor
                                                      : blackColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      height5,
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.schedule,
                                            color: isDark
                                                ? whiteColor
                                                : blackColor,
                                            size: sdp(context, 11),
                                          ),
                                          width5,
                                          Text(
                                            bookData['date'] +
                                                ' at ' +
                                                bookData['time'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? greyColorAccent
                                                  : blackColor,
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
                          Card(
                            color: isDark
                                ? DarkColors.scaffold
                                : LightColors.scaffold,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  TransactStatsCard(
                                    crossAlign: CrossAxisAlignment.start,
                                    textColor: Colors.black,
                                    amount:
                                        "₹ " + oCcy.format(bookData['income']),
                                    label: 'Income',
                                    cardColor: isDark
                                        ? Colors.lightGreen
                                        : Color(0xFFB5FFB7),
                                    amountColor: isDark
                                        ? Colors.lightGreenAccent
                                        : Colors.lightGreen.shade900,
                                  ),
                                  TransactStatsCard(
                                    crossAlign: CrossAxisAlignment.center,
                                    amount:
                                        "₹ " + oCcy.format(bookData['expense']),
                                    label: 'Expense',
                                    cardColor: isDark
                                        ? Colors.black
                                        : Colors.grey.shade300,
                                    textColor:
                                        isDark ? Colors.white : Colors.black,
                                    amountColor:
                                        isDark ? Colors.white : Colors.black,
                                  ),
                                  TransactStatsCard(
                                    crossAlign: CrossAxisAlignment.end,
                                    label: 'Current',
                                    amount: "₹ " +
                                        oCcy.format(bookData['income'] -
                                            bookData['expense']),
                                    cardColor: isDark
                                        ? Colors.blue.shade200
                                        : Color.fromARGB(255, 197, 226, 250),
                                    textColor: Colors.blue.shade900,
                                    amountColor: isDark
                                        ? Colors.blue.shade100
                                        : Colors.blue.shade900,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  bookData.containsKey('users') && bookData['users'].length > 0
                      ? Positioned(
                          top: 10,
                          right: 10,
                          child: CircleAvatar(
                            radius: sdp(context, 10),
                            backgroundColor:
                                isDark ? Colors.black : LightColors.profitCard,
                            child: Icon(
                              Icons.groups_2,
                              size: sdp(context, 10),
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget TransactStatsCard({
    final amount,
    final cardColor,
    final label,
    final textColor,
    final amountColor,
    required CrossAxisAlignment crossAlign,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Column(
          crossAxisAlignment: crossAlign,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: sdp(context, 10),
                ),
              ),
            ),
            height5,
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: sdp(context, 10),
                color: amountColor,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }
}
