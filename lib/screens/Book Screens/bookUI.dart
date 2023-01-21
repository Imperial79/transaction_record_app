import 'dart:developer';
import 'dart:ffi';

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
import '../../components.dart';

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
  var items = ['All', 'Income', 'Expense'];
  List<Map<String, dynamic>> transactList = [];
  bool isFetching = true;

  //------------------------------------>

  @override
  void initState() {
    super.initState();
    fetchBookTransacts();
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

  Future<void> fetchBookTransacts() async {
    QuerySnapshot<Map<String, dynamic>> data = await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('transact_books')
        .doc(widget.snap['bookId'])
        .collection('transacts')
        .orderBy('ts', descending: true)
        .get();

    for (var i = 0; i < data.docs.length; i++) {
      transactList.add(data.docs[i].data());
    }

    setState(() {
      isFetching = false;
    });
  }

  ///------------------------------->

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  //------------------------------------>

  @override
  Widget build(BuildContext context) {
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
                      duration: Duration(milliseconds: 300),
                      reverseDuration: Duration(milliseconds: 300),
                      alignment: Alignment.centerLeft,
                      curve: Curves.ease,
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
                                color: isDark(context)
                                    ? primaryAccentColor
                                    : Colors.black,
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
                                        color: isDark(context)
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
                          color: isDark(context)
                              ? greyColorDarker
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(8),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          cursorColor: isDark(context)
                              ? Colors.greenAccent
                              : primaryColor,
                          style: TextStyle(
                            color: isDark(context) ? whiteColor : blackColor,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: isDark(context)
                                  ? greyColorAccent
                                  : Colors.grey,
                            ),
                            hintText: 'Search amount, description, etc',
                            prefixIcon: Icon(
                              Icons.search,
                              color: isDark(context) ? whiteColor : blackColor,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //  Created On Date ---------------->

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
                                              color: isDark(context)
                                                  ? darkGreyColor
                                                  : Colors.grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: Text(
                                              '${widget.snap['date']}',
                                              style: TextStyle(
                                                color: isDark(context)
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
                                              color: isDark(context)
                                                  ? Colors.blue.shade900
                                                  : Colors.blue.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: Text(
                                              '${widget.snap['time']}',
                                              style: TextStyle(
                                                color: isDark(context)
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
                                                color: isDark(context)
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
                                              color: isDark(context)
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
                                                color: isDark(context)
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
                                                color: isDark(context)
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
                                            color: isDark(context)
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
                          isFetching
                              ? DummyTransactList()
                              : TransactList(
                                  widget.snap['bookId'],
                                ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: isKeyboardOpen(context)
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
                  borderRadius: BorderRadius.circular(20),
                  color: isDark(context) ? Colors.greenAccent : blackColor,
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
                          horizontal: showFullAddBtn ? 15 : 12,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color:
                                  isDark(context) ? blackColor : Colors.white,
                              size: 30,
                            ),
                            if (showFullAddBtn) const SizedBox(width: 10),
                            if (showFullAddBtn)
                              Text(
                                'New Transact',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: isDark(context)
                                      ? blackColor
                                      : Colors.white,
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

  Widget DummyTransactList() {
    return ListView.builder(
      itemCount: 5,
      shrinkWrap: true,
      padding: EdgeInsets.all(0),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Container(
            padding: EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark(context) ? Color(0xFF333333) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                height: sdp(context, 30),
                                width: sdp(context, 30),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 200,
                                height: 20,
                                color: Colors.grey,
                              ),
                              Spacer(),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 200,
                            height: 20,
                            color: Colors.grey,
                          ),
                          Container(
                            width: 200,
                            height: 20,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: !isDark(context) ? greyColorAccent : darkGreyColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Container(
                    width: 200,
                    height: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget TransactList(String bookId) {
    // return StreamBuilder<dynamic>(
    //   stream: FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(FirebaseAuth.instance.currentUser!.uid)
    //       .collection('transact_books')
    //       .doc(bookId)
    //       .collection('transacts')
    //       .orderBy('ts', descending: true)
    //       .snapshots(),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       if (snapshot.data.docs.length == 0) {
    //         return FirstTransactCard(context, bookId);
    //       } else {
    //         int dataCounter = 0;
    //         int loopCounter = 0;
    //         dateTitle = '';
    //         return ListView.builder(
    //           physics: BouncingScrollPhysics(),
    //           itemCount: snapshot.data.docs.length,
    //           shrinkWrap: true,
    //           itemBuilder: (context, index) {
    //             loopCounter += 1;
    //             DocumentSnapshot ds = snapshot.data.docs[index];
    //             Transact currTransact = Transact.fromDocumentSnap(ds);
    //             final searchKey = _searchController.text.toLowerCase().trim();
    //             if (_selectedSortType == 'All') {
    //               if (_searchController.text.isEmpty) {
    //                 dataCounter++;
    //                 return TransactTile(currTransact);
    //               } else if (ds['amount'].toString().contains(searchKey) ||
    //                   ds['description']
    //                       .toString()
    //                       .toLowerCase()
    //                       .contains(searchKey) ||
    //                   ds['source']
    //                       .toString()
    //                       .toLowerCase()
    //                       .contains(searchKey)) {
    //                 dataCounter++;
    //                 return TransactTile(currTransact);
    //               }
    //             } else if (ds['type'].toLowerCase() ==
    //                 _selectedSortType.toLowerCase()) {
    //               if (_searchController.text.isEmpty) {
    //                 dataCounter++;
    //                 return TransactTile(currTransact);
    //               } else if (ds['amount'].toString().contains(searchKey) ||
    //                   ds['description']
    //                       .toString()
    //                       .toLowerCase()
    //                       .contains(searchKey) ||
    //                   ds['source']
    //                       .toString()
    //                       .toLowerCase()
    //                       .contains(searchKey)) {
    //                 dataCounter++;
    //                 return TransactTile(currTransact);
    //               }
    //             }
    //             if (dataCounter == 0 &&
    //                 loopCounter == snapshot.data.docs.length) {
    //               return Text('No Item Found');
    //             }
    //             return SizedBox();
    //           },
    //         );
    //       }
    //     }
    //     return Center(
    //       child: CircularProgressIndicator(),
    //     );
    //   },
    // );
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: transactList.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        Transact currTransact = Transact.fromMap(transactList[index]);
        final searchKey = _searchController.text.toLowerCase().trim();
        if (_selectedSortType == 'All') {
          if (_searchController.text.isEmpty) {
            return TransactTile(currTransact);
          } else if (currTransact.amount!.contains(searchKey) ||
              currTransact.description!.toLowerCase().contains(searchKey) ||
              currTransact.source!.toLowerCase().contains(searchKey)) {
            return TransactTile(currTransact);
          }
        } else if (currTransact.type!.toLowerCase() ==
            _selectedSortType.toLowerCase()) {
          if (_searchController.text.isEmpty) {
            return TransactTile(currTransact);
          } else if (currTransact.amount!.contains(searchKey) ||
              currTransact.description!.toLowerCase().contains(searchKey) ||
              currTransact.source!.toLowerCase().contains(searchKey)) {
            return TransactTile(currTransact);
          }
        }
        // if (dataCounter == 0 && loopCounter == snapshot.data.docs.length) {
        //   return Text('No Item Found');
        // }
        return SizedBox();
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
                color: isDark(context) ? whiteColor : blackColor,
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
            margin: EdgeInsets.only(bottom: 20),
            child: Container(
              padding: EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color:
                    isDark(context) ? Color(0xFF333333) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  height: sdp(context, 30),
                                  width: sdp(context, 30),
                                  decoration: BoxDecoration(
                                    color: data.type == 'Income'
                                        ? primaryAccentColor
                                        : Colors.black,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: data.type == 'Income'
                                            ? primaryAccentColor
                                                .withOpacity(0.5)
                                            : greyColorAccent.withOpacity(0.5),
                                        blurRadius: 30,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: FittedBox(
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
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: oCcy.format(
                                              double.parse(data.amount!)),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: data.type == 'Income'
                                                ? primaryColor
                                                : isDark(context)
                                                    ? Color(0xFFFFC1C1)
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
                                                : isDark(context)
                                                    ? Color(0xFFFF8787)
                                                    : lossColor,
                                            fontFamily: 'Product',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            StatsRow(
                              color: Colors.amber.shade900,
                              content: data.source!,
                              icon: Icons.person,
                            ),
                            StatsRow(
                              color: Colors.blue,
                              content: data.description!,
                              icon: Icons.short_text_rounded,
                            ),
                          ],
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: 45,
                        child: Text(
                          data.transactMode!,
                          style: TextStyle(
                            letterSpacing: 10,
                            fontWeight: FontWeight.w700,
                            color: data.transactMode! == 'CASH'
                                ? isDark(context)
                                    ? Colors.grey
                                    : Colors.white
                                : isDark(context)
                                    ? Color(0xFF9DC4FF)
                                    : Colors.blue.shade100,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: !isDark(context) ? greyColorAccent : darkGreyColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          color: isDark(context) ? whiteColor : darkGreyColor,
                          size: 15,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          data.time.toString(),
                          style: TextStyle(
                            color: isDark(context) ? whiteColor : darkGreyColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Padding StatsRow(
      {required String content, required IconData icon, required Color color}) {
    bool isEmpty = content.trim() == '';
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 10,
            child: Icon(
              icon,
              size: 15,
              color: isDark(context) ? whiteColor : darkGreyColor,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Flexible(
            child: Text(
              isEmpty ? 'No Information Provided' : content,
              style: TextStyle(
                fontSize: sdp(context, 11),
                fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w500,
                color: isDark(context)
                    ? isEmpty
                        ? Colors.grey
                        : whiteColor
                    : darkGreyColor,
                fontStyle: isEmpty ? FontStyle.italic : null,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
