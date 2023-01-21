import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/models/transactModel.dart';
import 'package:transaction_record_app/screens/Transact%20Screens/edit_transactUI.dart';
import 'package:transaction_record_app/screens/Transact%20Screens/new_transactUi.dart';
import 'package:transaction_record_app/services/size.dart';
import '../../Functions/navigatorFns.dart';
import '../../colors.dart';
import '../../services/database.dart';
import '../../services/user.dart';
import '../../widgets.dart';

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
  final ValueNotifier<bool> _showBookMenu = ValueNotifier<bool>(false);
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  bool _isLoading = false;
  final _searchController = TextEditingController();
  String _selectedSortType = 'All';
  // List of items in our dropdown menu
  var items = ['All', 'Income', 'Expense'];

  //------------------------------------>

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

  //--------- DELETE BOOK--------------------------->
  _deleteBook() async {
    final bookName = widget.snap['bookName'];
    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseMethods().deleteBookWithCollections(widget.snap['bookId']);
      setState(() {
        _isLoading = false;
      });
      ShowSnackBar(
        context,
        '"$bookName"' + ' book has been deleted',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ShowSnackBar(
        context,
        'Something went wrong. Please try again after sometime',
      );
    }

    Navigator.pop(context);
  }

  //------------------------------------>

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  //------------------------------------>

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark ? false : true;
    bool isKeyboardOpen =
        MediaQuery.of(context).viewInsets.bottom != 0 ? true : false;
    _searchController.text.isEmpty ? _showAdd.value = true : false;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedSize(
                      duration: Duration(milliseconds: 200),
                      child: Container(
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
                              ),
                              _searchController.text.isEmpty
                                  ? SizedBox(
                                      width: 10,
                                    )
                                  : SizedBox(),
                              _searchController.text.isEmpty
                                  ? Text(
                                      'Return',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode
                                            ? whiteColor
                                            : blackColor,
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.only(right: 10),
                        margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? greyColorDarker
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(8),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          cursorColor:
                              isDarkMode ? Colors.greenAccent : primaryColor,
                          style: TextStyle(
                            color: isDarkMode ? whiteColor : blackColor,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: isDarkMode ? greyColorAccent : Colors.grey,
                            ),
                            hintText: 'Search amount, description, etc',
                            prefixIcon: Icon(
                              Icons.search,
                              color: isDarkMode ? whiteColor : blackColor,
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
                  ],
                ),
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
                                    //  Created On Date -------------------------->

                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? darkGreyColor
                                                  : Colors.grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: Text(
                                              '${widget.snap['date']}',
                                              style: TextStyle(
                                                color: isDarkMode
                                                    ? greyColorAccent
                                                    : Colors.black,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 5),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? Colors.blue.shade900
                                                  : Colors.blue.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: Text(
                                              '${widget.snap['time']}',
                                              style: TextStyle(
                                                color: isDarkMode
                                                    ? whiteColor
                                                    : Colors.blue.shade900,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              widget.snap['bookName'],
                                              style: TextStyle(
                                                fontSize: sdp(context, 15),
                                                color: isDarkMode
                                                    ? whiteColor
                                                    : blackColor,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _showBookMenu.value =
                                                    !_showBookMenu.value;
                                              });
                                            },
                                            icon: Icon(
                                              Icons.more_horiz,
                                              color: isDarkMode
                                                  ? whiteColor
                                                  : blackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //  Book Menu -------------------------->

                                    AnimatedSize(
                                      duration: Duration(milliseconds: 300),
                                      child: ValueListenableBuilder<bool>(
                                        valueListenable: _showBookMenu,
                                        builder: (BuildContext context,
                                            bool showBookMenu, Widget? child) {
                                          return showBookMenu
                                              ? BookMenu(
                                                  widget.snap['bookId'],
                                                  context,
                                                )
                                              : Container();
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                        );
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'INR ',
                                              style: TextStyle(
                                                fontSize: sdp(context, 22),
                                                color: isDarkMode
                                                    ? whiteColor
                                                    : blackColor,
                                                fontFamily: 'Product',
                                                fontWeight: FontWeight.w200,
                                              ),
                                            ),
                                            TextSpan(
                                              text: oCcy.format(
                                                  ds['income'] - ds['expense']),
                                              style: TextStyle(
                                                fontSize: sdp(context, 22),
                                                color: isDarkMode
                                                    ? whiteColor
                                                    : blackColor,
                                                fontFamily: 'Product',
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: sdp(context, 30),
                                      width: sdp(context, 30),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: FittedBox(
                                        child: IconButton(
                                          onPressed: () {
                                            showMenu(
                                              context: context,
                                              color: Colors.blueGrey.shade800,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              position: RelativeRect.fromLTRB(
                                                  sdp(context, 100),
                                                  sdp(context, 120),
                                                  sdp(context, 0),
                                                  sdp(context, 0)),
                                              items: [
                                                MenuBtns(
                                                  setState: setState,
                                                  label: 'All',
                                                ),
                                                MenuBtns(
                                                  setState: setState,
                                                  label: 'Income',
                                                ),
                                                MenuBtns(
                                                  setState: setState,
                                                  label: 'Expense',
                                                ),
                                              ],
                                            );
                                          },
                                          icon: Icon(
                                            _selectedSortType == 'All'
                                                ? Icons.filter_list
                                                : _selectedSortType == 'Income'
                                                    ? Icons
                                                        .file_download_outlined
                                                    : Icons
                                                        .file_upload_outlined,
                                            color: isDarkMode
                                                ? whiteColor
                                                : blackColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
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
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        children: [
                          TransactList(widget.snap['bookId']),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.07,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Full Screen Loading ------------------------->
            Visibility(
              visible: _isLoading,
              child: Container(
                alignment: Alignment.center,
                height: double.infinity,
                width: double.infinity,
                color: Colors.white.withOpacity(0.9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Transform.scale(
                        scale: 0.7,
                        child: CircularProgressIndicator(
                          color: Colors.red,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Deleting Book',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isKeyboardOpen
          ? Container()
          : InkWell(
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
                  borderRadius: BorderRadius.circular(100),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black,
                      Colors.grey,
                    ],
                  ),
                ),
                child: AnimatedSize(
                  duration: Duration(milliseconds: 100),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _showAdd,
                    builder: (
                      BuildContext context,
                      bool showFullAddBtn,
                      Widget? child,
                    ) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: showFullAddBtn ? 15 : 12,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                              size: !_showAdd.value ? 30 : 24.0,
                            ),
                            if (showFullAddBtn) const SizedBox(width: 10),
                            if (showFullAddBtn)
                              Text(
                                'New Transact',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.white,
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
        if (snapshot.hasData) {
          if (snapshot.data.docs.length == 0) {
            return FirstTransactCard(context, bookId);
          } else {
            int dataCounter = 0;
            int loopCounter = 0;
            dateTitle = '';
            return ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                loopCounter += 1;
                DocumentSnapshot ds = snapshot.data.docs[index];
                Transact currTransact = Transact.fromDocumentSnap(ds);
                final searchKey = _searchController.text.toLowerCase().trim();
                if (_selectedSortType == 'All') {
                  if (_searchController.text.isEmpty) {
                    dataCounter++;
                    return TransactTile(currTransact);
                  } else if (ds['amount'].toString().contains(searchKey) ||
                      ds['description']
                          .toString()
                          .toLowerCase()
                          .contains(searchKey) ||
                      ds['source']
                          .toString()
                          .toLowerCase()
                          .contains(searchKey)) {
                    dataCounter++;
                    return TransactTile(currTransact);
                  }
                } else if (ds['type'].toLowerCase() ==
                    _selectedSortType.toLowerCase()) {
                  if (_searchController.text.isEmpty) {
                    dataCounter++;
                    return TransactTile(currTransact);
                  } else if (ds['amount'].toString().contains(searchKey) ||
                      ds['description']
                          .toString()
                          .toLowerCase()
                          .contains(searchKey) ||
                      ds['source']
                          .toString()
                          .toLowerCase()
                          .contains(searchKey)) {
                    dataCounter++;
                    return TransactTile(currTransact);
                  }
                }
                if (dataCounter == 0 &&
                    loopCounter == snapshot.data.docs.length) {
                  return Text('No Item Found');
                }
                return SizedBox();
              },
            );
          }
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget TransactTile(Transact data) {
    String dateLabel = '';
    var todayDate = DateFormat.yMMMMd().format(DateTime.now());
    if (dateTitle == data.date) {
      showDateWidget = false;
    } else {
      dateTitle = data.date!;
      showDateWidget = true;
    }
    String ts = DateFormat("yMMMMd").parse(data.date!).toString();

    if (dateTitle == todayDate) {
      dateLabel = 'Today';
    } else if (DateTime.now().difference(DateTime.parse(ts)).inDays == 1) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = dateTitle;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: showDateWidget,
          child: Padding(
            padding: EdgeInsets.only(bottom: 10, top: 5),
            child: Text(
              dateLabel,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? whiteColor : blackColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            NavPush(
              context,
              EditTransactUI(trData: data),
            );
          },
          child: Container(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkMode ? greyColorDarker : Colors.grey.shade200,
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
                            radius: 15,
                            backgroundColor: data.type == 'Income'
                                ? primaryAccentColor
                                : Colors.black,
                            child: Icon(
                              data.type == 'Income'
                                  ? Icons.file_download_outlined
                                  : Icons.file_upload_outlined,
                              color: data.type == 'Income'
                                  ? Colors.black
                                  : Colors.white,
                              size: 17,
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
                                    text:
                                        oCcy.format(double.parse(data.amount!)),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: data.type == 'Income'
                                          ? primaryColor
                                          : isDarkMode
                                              ? Colors.redAccent
                                              : lossColor,
                                      fontFamily: 'Product',
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' INR',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20,
                                      color: data.type == 'Income'
                                          ? primaryColor
                                          : isDarkMode
                                              ? Colors.redAccent
                                              : lossColor,
                                      fontFamily: 'Product',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: data.transactMode! == 'CASH'
                                  ? isDarkMode
                                      ? darkGreyColor
                                      : Colors.white
                                  : isDarkMode
                                      ? Color.fromARGB(255, 0, 34, 85)
                                      : Colors.blue.shade100,
                            ),
                            child: Text(
                              data.transactMode!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: data.transactMode! == 'CASH'
                                    ? isDarkMode
                                        ? greyColorAccent
                                        : Colors.black
                                    : isDarkMode
                                        ? Colors.blueAccent
                                        : Colors.blue.shade900,
                              ),
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
                            visible: data.source! != '',
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person,
                                    color:
                                        isDarkMode ? whiteColor : darkGreyColor,
                                    size: 15,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Text(
                                      data.source!,
                                      style: TextStyle(
                                        fontSize: sdp(context, 10),
                                        fontWeight: FontWeight.w500,
                                        color: isDarkMode
                                            ? whiteColor
                                            : darkGreyColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: data.description! != '',
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.short_text,
                                    size: 15,
                                    color:
                                        isDarkMode ? whiteColor : darkGreyColor,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Flexible(
                                    child: Text(
                                      data.description!,
                                      style: TextStyle(
                                        fontSize: sdp(context, 10),
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode
                                            ? whiteColor
                                            : darkGreyColor,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: isDarkMode ? whiteColor : darkGreyColor,
                                size: 15,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                data.time.toString(),
                                style: TextStyle(
                                  color:
                                      isDarkMode ? whiteColor : darkGreyColor,
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

  Container BookMenu(String bookId, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 10),
      width: double.infinity,
      color: Colors.grey.shade200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                size: 17,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Actions',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              BookMenuBtn(
                onPress: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return ALertBox(
                          context,
                          label: 'Delete Book',
                          content:
                              'Do you really want to delete this Book ? This cannot be undone!',
                          onPress: () {
                            _deleteBook();
                            Navigator.pop(context);
                          },
                        );
                      });
                },
                label: 'Delete Book',
                icon: Icons.delete,
                btnColor: Colors.black,
                textColor: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: BookMenuBtn(
                  onPress: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return ALertBox(
                            context,
                            label: 'Clear all Transacts ?',
                            content:
                                'Do you really want to delete all transacts in this Book ? This cannot be undone!',
                            onPress: () {
                              _clearAllTransacts();
                              Navigator.pop(context);
                            },
                          );
                        });
                  },
                  label: 'Clear all Transacts',
                  icon: Icons.restore,
                  btnColor: Colors.blueGrey.shade600,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _clearAllTransacts() async {
    setState(() => _isLoading = true);
    await DatabaseMethods().deleteAllTransacts(widget.snap['bookId']);
    await DatabaseMethods().updateBookTransactions(
        widget.snap['bookId'], {"income": 0, "expense": 0});
    setState(() => _isLoading = false);
  }

  PopupMenuItem MenuBtns({final label, required StateSetter setState}) {
    bool isSelected = _selectedSortType == label;
    return PopupMenuItem(
      onTap: () {
        _selectedSortType = label;
        setState(() {});
      },
      child: Row(
        children: [
          Visibility(
            visible: isSelected,
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.done, color: Colors.white),
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
