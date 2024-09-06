// ignore_for_file: non_constant_identifier_names, duplicate_ignore
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import 'package:transaction_record_app/screens/Account%20Screen/accountUI.dart';
import 'package:transaction_record_app/screens/Book%20Screens/Due_Book_UI.dart';
import 'package:transaction_record_app/screens/Home%20Screens/homeMenuUI.dart';
import 'package:transaction_record_app/services/database.dart';
import '../../services/user.dart';
import '../../Utility/components.dart';
import '../Book Screens/bookUI.dart';

final ValueNotifier<bool> showAdd = ValueNotifier<bool>(true);
ValueNotifier<String> displayNameGlobal = ValueNotifier(globalUser.name);

class Home_UI extends StatefulWidget {
  @override
  _Home_UIState createState() => _Home_UIState();
}

class _Home_UIState extends State<Home_UI>
    with AutomaticKeepAliveClientMixin<Home_UI> {
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
    _init();
  }

  void _init() async {
    await Constants.getUserDetailsFromPreference()
        .then((value) => setState(() {}));
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
          .where(
            Filter.or(
              Filter(
                'users',
                arrayContains: globalUser.uid,
              ),
              Filter('uid', isEqualTo: globalUser.uid),
            ),
          )
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        dateTitle = '';
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
                                    fontSize: 12,
                                    letterSpacing: 7,
                                    color:
                                        isDark ? Dark.fadeText : Light.fadeText,
                                  ),
                                ),
                              )
                            : Text(
                                'Searching for "${_searchController.text}"',
                                style: TextStyle(
                                  color:
                                      isDark ? Dark.fadeText : Light.fadeText,
                                ),
                              ),
                        height10,
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            Book newBook =
                                Book.fromMap(snapshot.data!.docs[index].data());

                            if (_searchController.text.isEmpty) {
                              return _bookTile(newBook);
                            } else {
                              if (kCompare(_searchController.text,
                                      newBook.bookName) ||
                                  kCompare(_searchController.text,
                                      newBook.bookDescription)) {
                                return _bookTile(newBook);
                              }
                              return SizedBox();
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
    _showAdd.value = _searchController.text.isEmpty;
    isDark = Theme.of(context).brightness == Brightness.dark;
    return KScaffold(
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
                builder:
                    (BuildContext context, bool showFullAppBar, Widget? child) {
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
                                        navPush(context, AccountUI());
                                      },
                                      child: Hero(
                                        tag: 'profImg',
                                        child: CircleAvatar(
                                          radius: 12,
                                          child: ClipRRect(
                                            borderRadius: kRadius(50),
                                            child: globalUser.imgUrl == ''
                                                ? Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Dark.profitCard,
                                                      strokeWidth: 1.5,
                                                    ),
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl: globalUser.imgUrl,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    width10,
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(
                                            'Hi',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          width10,
                                          ValueListenableBuilder(
                                            valueListenable: displayNameGlobal,
                                            builder:
                                                (context, String name, child) {
                                              return Text(
                                                globalUser.name,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _showHomeMenu.value =
                                              !_showHomeMenu.value;
                                        });
                                      },
                                      borderRadius: kRadius(100),
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor: isDark
                                            ? Dark.card
                                            : Colors.grey.shade200,
                                        child: Icon(
                                          _showHomeMenu.value
                                              ? Icons.keyboard_arrow_up_rounded
                                              : Icons
                                                  .keyboard_arrow_down_rounded,
                                          size: 20,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              height10,
                            ],
                          )
                        : Container(),
                  );
                },
              ),
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
                  height15,
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

  Widget _bookTile(Book bookData) {
    var todayDate = DateFormat.yMMMMd().format(DateTime.now());

    if (dateTitle == bookData.date) {
      showDateWidget = false;
    } else {
      dateTitle = bookData.date;
      showDateWidget = true;
    }

    // Change Card color -------------------->

    bool isCompleted =
        bookData.expense != 0 && (bookData.income == bookData.expense);

    Color _kCardColor = Dark.card;
    Color _textColor = Colors.black;

    if (isCompleted) {
      _kCardColor = isDark ? Dark.completeCard : Light.completeCard;
      _textColor = Colors.white;
    } else {
      _kCardColor = isDark ? Dark.card : Light.card;
      _textColor = isDark ? Colors.white : Colors.black;
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        OpenContainer(
          openBuilder: (context, closedContainer) {
            if (bookData.type == "regular") return BookUI(snap: bookData);
            return Due_Book_UI(
              bookData: bookData,
            );
          },
          closedElevation: 0,
          closedShape: RoundedRectangleBorder(
            borderRadius: kRadius(20),
          ),
          openElevation: 0,
          transitionType: ContainerTransitionType.fadeThrough,
          closedColor: isDark ? Dark.card : Light.card,
          openColor: isDark ? Dark.scaffold : Light.scaffold,
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
                      bookId: bookData.bookId,
                      bookName: bookData.bookName,
                    );
                  },
                );
              },
              child: Card(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          bookData.bookName,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500,
                                            color: _textColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      width10,
                                      bookData.users != null &&
                                              bookData.users!.length > 0
                                          ? CircleAvatar(
                                              radius: 12,
                                              child: Icon(
                                                Icons.groups_2,
                                                size: 12,
                                              ),
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                  Visibility(
                                    visible: bookData.bookDescription
                                        .toString()
                                        .isNotEmpty,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.note,
                                            color: _textColor,
                                            size: 12,
                                          ),
                                          width5,
                                          Text(
                                            bookData.bookDescription,
                                            style: TextStyle(
                                              color: _textColor,
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
                                        color: _textColor,
                                        size: 12,
                                      ),
                                      width5,
                                      Text(
                                        bookData.date + ' | ' + bookData.time,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _textColor,
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
                        padding: EdgeInsets.all(0),
                        child: bookData.type == "due"
                            ? Row(
                                children: [
                                  _bookStats(
                                    index: 0,
                                    crossAlign: CrossAxisAlignment.start,
                                    textColor:
                                        isDark ? Colors.white : Colors.black,
                                    amount: "₹ " +
                                        oCcy.format(
                                            bookData.income - bookData.expense),
                                    label: 'Received',
                                    cardColor: isDark
                                        ? Color(0xFF223B05)
                                        : Color(0xFFB5FFB7),
                                    amountColor: isDark
                                        ? Colors.lightGreenAccent
                                        : Colors.lightGreen.shade900,
                                  ),
                                  _bookStats(
                                    index: 2,
                                    crossAlign: CrossAxisAlignment.end,
                                    label: "Due",
                                    amount:
                                        "₹ " + oCcy.format(bookData.expense),
                                    cardColor: isDark
                                        ? Color(0xFF0B2A43)
                                        : Color.fromARGB(255, 197, 226, 250),
                                    textColor: isDark
                                        ? Colors.white
                                        : Colors.blue.shade900,
                                    amountColor: isDark
                                        ? Colors.blue.shade100
                                        : Colors.blue.shade900,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  _bookStats(
                                    index: 0,
                                    crossAlign: CrossAxisAlignment.start,
                                    textColor:
                                        isDark ? Colors.white : Colors.black,
                                    amount: "₹ " + oCcy.format(bookData.income),
                                    label: 'Income',
                                    cardColor: isDark
                                        ? Color(0xFF223B05)
                                        : Color(0xFFB5FFB7),
                                    amountColor: isDark
                                        ? Colors.lightGreenAccent
                                        : Colors.lightGreen.shade900,
                                  ),
                                  width5,
                                  _bookStats(
                                    index: 1,
                                    crossAlign: CrossAxisAlignment.center,
                                    amount:
                                        "₹ " + oCcy.format(bookData.expense),
                                    label: 'Expense',
                                    cardColor: isDark
                                        ? Colors.black
                                        : Colors.grey.shade300,
                                    textColor:
                                        isDark ? Colors.white : Colors.black,
                                    amountColor:
                                        isDark ? Colors.white : Colors.black,
                                  ),
                                  width5,
                                  _bookStats(
                                    index: 2,
                                    crossAlign: CrossAxisAlignment.end,
                                    label: 'Current',
                                    amount: "₹ " +
                                        oCcy.format(
                                            bookData.income - bookData.expense),
                                    cardColor: isDark
                                        ? const Color(0xFF0B2A43)
                                        : Color.fromARGB(255, 197, 226, 250),
                                    textColor: isDark
                                        ? Colors.white
                                        : Colors.blue.shade900,
                                    amountColor: isDark
                                        ? Colors.blue.shade100
                                        : Colors.blue.shade900,
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        height10,
      ],
    );
  }

  Widget _bookStats({
    required int index,
    String amount = "0",
    required Color cardColor,
    String label = "label",
    required Color textColor,
    final amountColor,
    required CrossAxisAlignment crossAlign,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: index == 0
              ? BorderRadius.horizontal(
                  left: Radius.circular(10),
                )
              : index == 1
                  ? null
                  : BorderRadius.horizontal(right: Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: crossAlign,
          children: [
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
            height5,
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
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
