import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/screens/Transact%20Screens/edit_transactUI.dart';
import 'package:transaction_record_app/screens/Transact%20Screens/new_transactUi.dart';
import '../../Functions/navigatorFns.dart';
import '../../colors.dart';
import '../../services/database.dart';
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
  final ValueNotifier<bool> _showBookMenu = ValueNotifier<bool>(false);
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  bool _isLoading = false;

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

  //------------------------------------>
  _deleteBook() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseMethods().deleteBook(widget.snap['bookId']);
      setState(() {
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    setSystemUIColors();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                widget.snap['bookName'],
                                                style: TextStyle(
                                                  fontSize: 25,
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
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //  Book Menu -------------------------->

                                      AnimatedSize(
                                        duration: Duration(milliseconds: 200),
                                        child: ValueListenableBuilder<bool>(
                                          valueListenable: _showBookMenu,
                                          builder: (BuildContext context,
                                              bool showBookMenu,
                                              Widget? child) {
                                            return showBookMenu
                                                ? BookMenu(
                                                    widget.snap['bookId'],
                                                    context,
                                                  )
                                                : Container();
                                          },
                                        ),
                                      ),
                                      //  Date -------------------------->

                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 8.0, top: 0),
                                        child: Text(
                                          widget.snap['date'] +
                                              ', ' +
                                              widget.snap['time'],
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                          ),
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
                                            oCcy.format(
                                                ds['income'] - ds['expense']),
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
                  ),
                  SizedBox(
                    height: _showAdd.value ? 10 : 5,
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
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                    horizontal: showFullAddBtn ? 20 : 15,
                    vertical: 15,
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
                          'New Book',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (showFullAddBtn) const SizedBox(width: 2.5),
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
                              text: oCcy.format(double.parse(ds["amount"])),
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
                        return DeleteBookAlertBox(context);
                      });
                },
                label: 'Delete',
                icon: Icons.delete,
                btnColor: Colors.black,
                textColor: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: BookMenuBtn(
                  //TODO:
                  onPress: () {},
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

  Widget DeleteBookAlertBox(BuildContext context) {
    return StatefulBuilder(
      builder: (context, StateSetter setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          icon: Icon(
            Icons.delete,
            color: Colors.red,
            size: 30,
          ),
          title: Text(
            'Delete this Book ?',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          content: Text(
            'Do you really want to delete this Book ? This cannot be undone!',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
              ),
            ),
            MaterialButton(
              onPressed: () {
                _deleteBook();
                Navigator.pop(context);
              },
              color: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              elevation: 0,
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
