// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Functions/bookFunctions.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import 'package:transaction_record_app/models/transactModel.dart';
import 'package:transaction_record_app/models/userModel.dart';
import 'package:transaction_record_app/screens/Book%20Screens/Users_UI.dart';
import 'package:transaction_record_app/screens/Transact%20Screens/edit_transactUI.dart';
import 'package:transaction_record_app/screens/Transact%20Screens/New_Transact_UI.dart';
import '../../Components/WIdgets.dart';
import '../../Functions/navigatorFns.dart';
import '../../Utility/commons.dart';
import '../../services/database.dart';
import '../../Utility/components.dart';

class BookUI extends ConsumerStatefulWidget {
  final BookModel bookData;
  const BookUI({super.key, required this.bookData});

  @override
  ConsumerState<BookUI> createState() => _BookUIState(bookData: bookData);
}

class _BookUIState extends ConsumerState<BookUI> {
  final BookModel bookData;
  _BookUIState({required this.bookData});
  String dateTitle = '';
  bool showDateWidget = false;
  final ScrollController _scrollController = ScrollController();

  final ValueNotifier<bool> _showThings = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _showBookMenu = ValueNotifier<bool>(false);
  final ValueNotifier<int> bookListCounter = ValueNotifier<int>(20);
  bool _isLoading = false;
  final _searchController = TextEditingController();
  String _selectedSortType = 'All';
  var items = ['All', 'Income', 'Expense'];

  // int bookListCounter = 5;
  int searchingBookListCounter = 50;
  bool isSearching = false;

  //------------------------------------>

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        _showThings.value = false;
      } else {
        _showThings.value = true;
      }

      if (_scrollController.position.atEdge) {
        bookListCounter.value += 5;
      }
    });
  }

  Future<void> distribute(bool isDark) async {
    setState(() {
      isLoading = true;
    });
    await FirebaseRefs.transactBookRef(bookData.bookId)
        .get()
        .then((value) async {
      List<dynamic> groupMembers = [];

      groupMembers.addAll(value.data()!['users']);
      groupMembers.add(value.data()!['uid']);

      Map<String, double> expenseMap = {
        for (var item in groupMembers) item: 0.0
      };
      double totalExpense = value.data()!['expense'];

      await FirebaseRefs.transactsRef(bookData.bookId)
          .get()
          .then((snapshot) async {
        for (var element in snapshot.docs) {
          final transact = element.data();

          if (expenseMap.containsKey(transact['uid'])) {
            if (transact['type'] == "income") {
              expenseMap["${transact['uid']}"] =
                  expenseMap["${transact['uid']}"]! +
                      double.parse(transact['amount']);
            } else {
              expenseMap["${transact['uid']}"] =
                  expenseMap["${transact['uid']}"]! -
                      double.parse(transact['amount']);
            }
          }
        }
        double perHead = totalExpense / groupMembers.length;

        List<Map<String, dynamic>> payer = [];
        List<Map<String, dynamic>> reciever = [];
        List<String> payGetUsers = [];
        Map<String, dynamic> balanceSheetUsers = {};

        expenseMap.forEach((key, value) {
          double spent = perHead - value.abs();

          if (spent > 0) {
            payer.add({'uid': key, 'amount': spent.abs()});
            payGetUsers.add(key);
          } else if (spent < 0) {
            reciever.add({'uid': key, 'amount': spent.abs()});
            payGetUsers.add(key);
          }
        });

        await FirebaseRefs.userRef
            .where('uid', whereIn: payGetUsers)
            .get()
            .then((value) {
          for (var element in value.docs) {
            balanceSheetUsers[element.data()['uid']] = {
              'name': element.data()['name'],
              'imgUrl': element.data()['imgUrl'],
            };
          }
        });

        List<Map<String, dynamic>> balanceSheet = [];
        for (var i = 0; i < reciever.length; i++) {
          String recieverUid = reciever[i]['uid'];
          double recieverSpent = reciever[i]['amount'];

          for (var j = 0; j < payer.length; j++) {
            String payerUid = payer[j]['uid'];
            double payerPay = payer[j]['amount'];
            if (recieverSpent - payerPay < 0) {
              // reciever (multiple recievers) got money and payer is left with some money
              payerPay -= recieverSpent;
              balanceSheet.add({
                'payerUid': payerUid,
                'amount': payerPay,
                'recieverUid': recieverUid
              });
              recieverSpent = 0;
            } else if (recieverSpent - payerPay > 0) {
              recieverSpent -= payerPay;
              balanceSheet.add({
                'payerUid': payerUid,
                'amount': payerPay,
                'recieverUid': recieverUid
              });
              payerPay = 0;
              // payer gave all money reciever is yet to get money
            } else {
              balanceSheet.add({
                'payerUid': payerUid,
                'amount': payerPay,
                'recieverUid': recieverUid
              });
              recieverSpent = 0;
              payerPay = 0;
              // no due
            }
          }
        }

        // balanceSheet.forEach((element) {
        //   print(object)
        // });
        showModalBottomSheet(
          context: context,
          elevation: 0,
          backgroundColor: isDark ? Dark.card : Light.card,
          builder: (context) {
            return DistributeModal(
              isDark,
              balanceSheet: balanceSheet,
              balanceSheetUsers: balanceSheetUsers,
            );
          },
        );
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  ///------------------------------->

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _searchController.dispose();
  }

  //------------------------------------>

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    _showThings.value = _searchController.text.isEmpty;
    isSearching = _searchController.text.isNotEmpty;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.read(userProvider);
    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSize(
                  reverseDuration: const Duration(milliseconds: 300),
                  duration: const Duration(milliseconds: 300),
                  alignment: Alignment.topCenter,
                  curve: Curves.ease,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _showThings,
                    builder: (BuildContext context, bool showFullAppBar,
                        Widget? child) {
                      return Container(
                        child: showFullAppBar
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      AnimatedSize(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        reverseDuration:
                                            const Duration(milliseconds: 300),
                                        alignment: Alignment.centerLeft,
                                        curve: Curves.ease,
                                        child: IconButton(
                                          color: isDark
                                              ? Dark.profitText
                                              : Light.profitText,
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.arrow_back,
                                                color: isDark
                                                    ? Dark.profitCard
                                                    : Colors.black,
                                              ),
                                              _searchController.text.isEmpty
                                                  ? const SizedBox(
                                                      width: 10,
                                                    )
                                                  : const SizedBox(),
                                              _searchController.text.isEmpty
                                                  ? Text(
                                                      'Return',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isDark
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: _SearchBar(isDark),
                                      ),
                                    ],
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            bookData.bookName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        width10,
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _showBookMenu.value =
                                                  !_showBookMenu.value;
                                            });
                                          },
                                          borderRadius: kRadius(100),
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: isDark
                                                ? Dark.card
                                                : Colors.grey.shade200,
                                            child: FittedBox(
                                              child: Icon(
                                                _showBookMenu.value
                                                    ? Icons
                                                        .keyboard_arrow_up_rounded
                                                    : Icons
                                                        .keyboard_arrow_down_rounded,
                                                size: 20,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        width10,
                                        InkWell(
                                          borderRadius: kRadius(100),
                                          onTap: () {
                                            navPush(
                                                context,
                                                UsersUI(
                                                  users: bookData.users!,
                                                  ownerUid: bookData.uid,
                                                  bookId: bookData.bookId,
                                                ));
                                          },
                                          child: const FittedBox(
                                            child: CircleAvatar(
                                              radius: 12,
                                              child: Icon(
                                                Icons.groups_2,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  //  Book Menu -------------------------->
                                  height10,
                                  AnimatedSize(
                                    reverseDuration:
                                        const Duration(milliseconds: 300),
                                    duration: const Duration(milliseconds: 300),
                                    alignment: Alignment.topCenter,
                                    curve: Curves.ease,
                                    child: ValueListenableBuilder<bool>(
                                      valueListenable: _showBookMenu,
                                      builder: (BuildContext context,
                                          bool showBookMenu, Widget? child) {
                                        return showBookMenu
                                            ? BookMenu(
                                                isDark,
                                                bookId: bookData.bookId,
                                                uid: user!.uid,
                                              )
                                            : Container();
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseRefs.transactBookRef(bookData.bookId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            switchInCurve: Curves.easeIn,
                            switchOutCurve: Curves.easeOut,
                            child: snapshot.hasData &&
                                    snapshot.data!.data() != null
                                ? _header(isDark, data: snapshot.data!.data()!)
                                : _dummyStatsCard(isDark),
                          );
                        },
                      ),
                      height10,
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TransactList(
                            isDark,
                            bookId: bookData.bookId,
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
                color: isDark
                    ? Colors.grey.shade800.withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Transform.scale(
                        scale: 0.7,
                        child: CircularProgressIndicator(
                          color: isDark ? Colors.red.shade200 : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
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
      floatingActionButton: isKeyboardOpen(context) || _isLoading
          ? const SizedBox.shrink()
          : InkWell(
              onTap: () {
                navPush(
                  context,
                  New_Transact_UI(
                    bookId: bookData.bookId,
                    bookType: bookData.type,
                  ),
                ).then((value) {
                  setState(() {
                    // fetchBookTransacts();
                  });
                });
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: kRadius(20),
                  color: isDark ? Dark.profitCard : Colors.black,
                ),
                child: AnimatedSize(
                  reverseDuration: const Duration(milliseconds: 300),
                  duration: const Duration(milliseconds: 300),
                  alignment: Alignment.centerLeft,
                  curve: Curves.ease,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _showThings,
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
                              color: isDark ? Colors.black : Colors.white,
                              size: 30,
                            ),
                            if (showFullAddBtn) const SizedBox(width: 10),
                            if (showFullAddBtn)
                              Text(
                                'Transact',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: isDark ? Colors.black : Colors.white,
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

  Widget DistributeModal(
    bool isDark, {
    required List<dynamic> balanceSheet,
    required Map<String, dynamic> balanceSheetUsers,
  }) {
    return StatefulBuilder(
      builder: (context, setState) => SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: SizedBox(
          width: double.infinity,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Settlement',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                height20,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(child: Text('Will Pay')),
                    Expanded(
                        child: CircleAvatar(
                      radius: 12,
                      backgroundColor: isDark ? Dark.primary : Light.primary,
                      child: FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            '₹',
                            style: TextStyle(
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )),
                    const Expanded(
                      child: Text(
                        'To',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                height20,
                ListView.separated(
                  itemCount: balanceSheet.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    String payerName =
                        balanceSheetUsers[balanceSheet[index]['payerUid']]
                                ['name']
                            .split(" ")
                            .first;
                    String payerImg =
                        balanceSheetUsers[balanceSheet[index]['payerUid']]
                            ['imgUrl'];
                    String recieverName =
                        balanceSheetUsers[balanceSheet[index]['recieverUid']]
                                ['name']
                            .split(" ")
                            .first;
                    String recieverImg =
                        balanceSheetUsers[balanceSheet[index]['recieverUid']]
                            ['imgUrl'];
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: kRadius(10),
                        color: isDark ? Dark.scaffold : Light.scaffold,
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundImage: NetworkImage(payerImg),
                                ),
                                width10,
                                Expanded(
                                    child: Text(
                                  payerName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                              ],
                            ),
                          ),
                          width10,
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: kRadius(100),
                              color: isDark ? Light.card : Dark.card,
                            ),
                            child: Text(
                              "₹ ${balanceSheet[index]['amount'].toStringAsFixed(2)}",
                              style: TextStyle(
                                  color: isDark ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          width10,
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Text(
                                      recieverName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                width10,
                                CircleAvatar(
                                  radius: 12,
                                  backgroundImage: NetworkImage(recieverImg),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => height10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(
    bool isDark, {
    required Map<String, dynamic> data,
  }) {
    return Builder(builder: (context) {
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
                          fontSize: 25,
                          color: isDark ? Colors.white : Colors.black,
                          fontFamily: 'Product',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      TextSpan(
                        text: kMoneyFormat(data['income'] - data['expense']),
                        style: TextStyle(
                          fontSize: 25,
                          color: isDark ? Colors.white : Colors.black,
                          fontFamily: 'Product',
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _filterButton(isDark),
            ],
          ),
          height15,
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  context,
                  label: 'Income',
                  content: data['income'].toString(),
                  isBook: true,
                  bookId: data['bookId'],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: StatsCard(
                  context,
                  label: 'Expenses',
                  content: data['expense'].toString(),
                  isBook: true,
                  bookId: data['bookId'],
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _dummyStatsCard(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: isDark ? Dark.card : Light.card,
            child: const SizedBox(height: 100),
          ),
        ),
        width10,
        Expanded(
          child: Card(
            color: isDark ? Dark.card : Light.card,
            child: const SizedBox(height: 100),
          ),
        ),
      ],
    );
  }

  Container _filterButton(bool isDark) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? _selectedSortType == 'All'
                ? Dark.fadeText
                : _selectedSortType == 'Income'
                    ? Dark.profitCard
                    : Colors.red
            : _selectedSortType == 'All'
                ? Colors.black
                : _selectedSortType == 'Income'
                    ? Dark.profitCard
                    : Colors.red,
        boxShadow: [
          BoxShadow(
            color: _selectedSortType == 'All'
                ? Colors.grey.shade500
                : _selectedSortType == 'Income'
                    ? Dark.profitCard
                    : Colors.red,
            blurRadius: 100,
            spreadRadius: 10,
          ),
        ],
      ),
      child: FittedBox(
        child: IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              enableDrag: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              builder: (context) {
                return FilterBottomSheet(isDark, setState);
              },
            ).then((value) {
              setState(() {});
            });
          },
          icon: Icon(
            _selectedSortType == 'All'
                ? Icons.filter_list
                : _selectedSortType == 'Income'
                    ? Icons.file_download_outlined
                    : Icons.file_upload_outlined,
            color: isDark
                ? _selectedSortType == 'Income' || _selectedSortType == 'All'
                    ? Colors.black
                    : Colors.white
                : _selectedSortType == 'All' || _selectedSortType == 'Expense'
                    ? Colors.white
                    : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget TransactList(bool isDark, {required String bookId}) {
    dateTitle = '';
    return ValueListenableBuilder(
      valueListenable: bookListCounter,
      builder: (context, int bookCount, child) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: firestore
              .collection('transactBooks')
              .doc(bookId)
              .collection('transacts')
              .orderBy('ts', descending: true)
              .limit(bookCount)
              .snapshots(),
          builder: (context, snapshot) {
            dateTitle = '';

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: snapshot.hasData
                  ? snapshot.data!.docs.isNotEmpty
                      ? ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            Transact transact = Transact.fromMap(
                                snapshot.data!.docs[index].data());
                            final searchKey = Constants.getSearchString(
                                _searchController.text);

                            if (_selectedSortType == 'All') {
                              if (_searchController.text.isEmpty) {
                                return TransactTile(
                                  isDark,
                                  data: transact,
                                );
                              } else if (transact.amount.contains(searchKey) ||
                                  transact.description
                                      .toLowerCase()
                                      .contains(searchKey) ||
                                  transact.source
                                      .toLowerCase()
                                      .contains(searchKey)) {
                                return TransactTile(isDark, data: transact);
                              }
                            } else if (transact.type.toLowerCase() ==
                                _selectedSortType.toLowerCase()) {
                              if (searchKey.isEmpty) {
                                return TransactTile(isDark, data: transact);
                              } else if (transact.amount.contains(searchKey) ||
                                  transact.description
                                      .toLowerCase()
                                      .contains(searchKey) ||
                                  transact.source
                                      .toLowerCase()
                                      .contains(searchKey)) {
                                return TransactTile(isDark, data: transact);
                              }
                            }
                            return const SizedBox.shrink();
                          },
                        )
                      : Text(
                          'No Transacts',
                          style: TextStyle(
                            fontSize: 30,
                            color: isDark ? Dark.fadeText : Light.fadeText,
                          ),
                        )
                  : DummyTransactList(isDark),
            );
          },
        );
      },
    );
  }

  Container _SearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
      margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Dark.card : Light.card,
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(100),
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'lib/assets/icons/search.svg',
            height: 20,
            colorFilter: svgColor(
              isDark ? Dark.text : Light.text,
            ),
          ),
          width10,
          Flexible(
            child: TextField(
              controller: _searchController,
              cursorColor: isDark ? Dark.primary : Light.primary,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: isDark ? Dark.fadeText : Light.fadeText,
                ),
                hintText: 'Search amount, description, etc',
              ),
              onChanged: (val) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget DummyTransactList(bool isDark) {
    return Column(
      children: [
        for (int i = 0; i <= 5; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Dark.card : Light.card,
                borderRadius: kRadius(20),
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
                                  padding: const EdgeInsets.all(10),
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width: 200,
                                  height: 20,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 200,
                              height: 20,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            Container(
                              width: 200,
                              height: 20,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5),
                      borderRadius: kRadius(100),
                    ),
                    child: const SizedBox(
                      width: 200,
                      height: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget TransactTile(bool isDark, {required Transact data}) {
    bool isIncome = data.type == 'Income';
    String dateLabel = '';
    var todayDate = DateFormat.yMMMMd().format(DateTime.now());
    if (dateTitle == data.date) {
      showDateWidget = false;
    } else {
      dateTitle = data.date;
      showDateWidget = true;
    }
    String ts = DateFormat("yMMMMd").parse(data.date).toString();

    if (dateTitle == todayDate) {
      dateLabel = 'Today';
    } else if (DateTime.now().difference(DateTime.parse(ts)).inDays == 1) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = dateTitle;
    }

    return Consumer(builder: (context, ref, _) {
      final user = ref.watch(userProvider)!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: showDateWidget,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 5),
              child: Text(
                dateLabel,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              data.uid != user.uid &&
                      bookData.users != null &&
                      bookData.users!.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child:
                          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(data.uid)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return CircleAvatar(
                              radius: 12,
                              backgroundImage: NetworkImage(
                                  snapshot.data!.data()!['imgUrl']),
                            );
                          }

                          return const CircleAvatar(
                            radius: 12,
                          );
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    if (data.uid == user.uid) {
                      navPush(context, EditTransactUI(trData: data));
                    } else {
                      KSnackbar(
                        context,
                        content: "You cannot edit other's transactions",
                        isDanger: true,
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? Dark.card : Light.card,
                        borderRadius: kRadius(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                            color: isIncome
                                                ? isDark
                                                    ? Dark.profitText
                                                    : Light.profitText
                                                : isDark
                                                    ? Dark.lossText
                                                    : Light.lossText,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              isDark
                                                  ? BoxShadow(
                                                      color: isIncome
                                                          ? isDark
                                                              ? Dark.profitCard
                                                                  .withOpacity(
                                                                      .5)
                                                              : Light.profitCard
                                                                  .withOpacity(
                                                                      .5)
                                                          : isDark
                                                              ? Dark.lossCard
                                                              : Light.lossCard,
                                                      blurRadius: 30,
                                                      spreadRadius: 1,
                                                    )
                                                  : const BoxShadow(),
                                            ],
                                          ),
                                          child: FittedBox(
                                            child: Icon(
                                              isIncome
                                                  ? Icons.file_download_outlined
                                                  : Icons.file_upload_outlined,
                                              color: isIncome
                                                  ? isDark
                                                      ? Colors.black
                                                      : Colors.white
                                                  : isDark
                                                      ? Colors.red.shade900
                                                      : Colors.white,
                                            ),
                                          ),
                                        ),
                                        width10,
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  text:
                                                      kMoneyFormat(data.amount),
                                                  style: TextStyle(
                                                    fontFamily: "Product",
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w800,
                                                    color: isIncome
                                                        ? isDark
                                                            ? Dark.profitText
                                                            : Light.profitText
                                                        : isDark
                                                            ? Dark.lossText
                                                            : Light.lossText,
                                                  ),
                                                  children: const [
                                                    TextSpan(
                                                      text: " INR",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: data.transactMode ==
                                                          'CASH'
                                                      ? isDark
                                                          ? Dark.profitText
                                                          : Colors.black
                                                      : isDark
                                                          ? const Color(
                                                              0xFF9DC4FF)
                                                          : Colors
                                                              .blue.shade900,
                                                  borderRadius: kRadius(100),
                                                ),
                                                child: Text(
                                                  data.transactMode,
                                                  style: TextStyle(
                                                    letterSpacing: 1,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w900,
                                                    color: isDark
                                                        ? Colors.black
                                                        : Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    StatsRow(
                                      color: Colors.amber.shade900,
                                      content: data.source,
                                      icon: Icons.person,
                                    ),
                                    Visibility(
                                      visible:
                                          data.description.trim().isNotEmpty,
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        padding: const EdgeInsets.all(8),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Dark.scaffold
                                              : Light.scaffold,
                                          borderRadius: kRadius(10),
                                        ),
                                        child: Text(data.description),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          height10,
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 15,
                              ),
                              width5,
                              Text(
                                data.time.toString(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: data.uid == user.uid &&
                    bookData.users != null &&
                    bookData.users!.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(user.imgUrl),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget StatsRow({
    required String content,
    required IconData icon,
    required Color color,
  }) {
    bool isEmpty = content.trim() == '';
    return Visibility(
      visible: !isEmpty,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 10,
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Icon(
                    icon,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            width5,
            Flexible(
              child: Text(
                isEmpty ? 'No Information Provided' : content,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w500,
                  fontStyle: isEmpty ? FontStyle.italic : null,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget BookMenu(
    bool isDark, {
    required String uid,
    required String bookId,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Dark.card : Light.card,
        borderRadius: kRadius(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ACTIONS',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              width10,
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
                  borderRadius: kRadius(50),
                ),
                child: Text(
                  bookData.date,
                  style: TextStyle(
                    color: isDark ? Dark.fadeText : Light.fadeText,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          height10,
          Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 5,
            runSpacing: 5,
            children: [
              BookMenuBtn(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    isScrollControlled: true,
                    builder: (context) {
                      return kRenameModal(
                        context,
                        bookId: bookData.bookId,
                        oldBookName: bookData.bookName,
                      );
                    },
                  );
                },
                label: 'Edit',
                icon: Icons.edit,
                iconSize: 12,
                btnColor: Colors.black,
                textColor: Colors.white,
              ),
              BookMenuBtn(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    builder: (context) {
                      return ConfirmDeleteModal(
                        onDelete: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          await BookMethods.deleteBook(
                            context,
                            bookName: bookData.bookName,
                            bookId: bookData.bookId,
                          );
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.pop(context);
                        },
                        label: 'Really want to delete this Book?',
                        content: 'This action cannot be undone !',
                      );
                    },
                  );
                },
                label: 'Delete Book',
                iconSize: 12,
                labelSize: 12,
                icon: Icons.delete,
                btnColor: Colors.black,
                textColor: Colors.white,
              ),
              BookMenuBtn(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    builder: (context) {
                      return ConfirmDeleteModal(
                        onDelete: () {
                          _clearAllTransacts();
                          Navigator.pop(context);
                        },
                        label: 'Really want to clear all Transacts?',
                        content: 'This action cannot be undone !',
                      );
                    },
                  );
                },
                labelSize: 12,
                label: 'Clear all',
                iconSize: 12,
                icon: Icons.restore,
                btnColor:
                    isDark ? Colors.blue.shade700 : Colors.blueGrey.shade600,
                textColor: Colors.white,
              ),
              BookMenuBtn(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => _addUserDialog(
                      isDark,
                      uid: uid,
                      bookId: bookData.bookId,
                      bookName: bookData.bookName,
                    ),
                  );
                },
                labelSize: 12,
                label: 'Add User(s)',
                iconSize: 15,
                icon: Icons.person_add_alt_1,
                btnColor: isDark ? Dark.profitText : const Color(0xFF27576D),
                textColor: isDark ? Colors.black : Colors.white,
              ),
              BookMenuBtn(
                onPressed: () {
                  distribute(isDark);
                },
                labelSize: 12,
                label: 'Distribute',
                iconSize: 15,
                icon: Icons.alt_route_rounded,
                btnColor: isDark ? Dark.profitText : const Color(0xFF27576D),
                textColor: isDark ? Colors.black : Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> selectedUsers = [];
  // bool isSelecting = false;
  Widget _addUserDialog(
    bool isDark, {
    required String uid,
    required String bookId,
    required String bookName,
  }) {
    final searchUser = TextEditingController();
    selectedUsers = [];
    bool isSelecting = false;

    void onSelect(setState, String uid) {
      setState(() {
        if (!selectedUsers.contains(uid)) {
          selectedUsers.add(uid);
        } else {
          selectedUsers.remove(uid);
        }
      });

      if (selectedUsers.isEmpty) {
        setState(() {
          isSelecting = false;
        });
      } else {
        setState(() {
          isSelecting = true;
        });
      }
    }

    return StatefulBuilder(
      builder: (context, setState) => Dialog(
        elevation: 0,
        insetPadding: const EdgeInsets.all(15),
        backgroundColor: isDark ? Dark.scaffold : Light.scaffold,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              KSearchBar(
                context,
                isDark: isDark,
                controller: searchUser,
                onChanged: (_) {
                  setState(() {});
                },
              ),
              Visibility(
                visible: isSelecting,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text('Selected ${selectedUsers.length} user(s)'),
                ),
              ),
              height20,
              FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future:
                    FirebaseRefs.userRef.where('uid', isNotEqualTo: uid).get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.isEmpty) {
                      return const Text('No Users');
                    }
                    return Flexible(
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          UserModel userData = UserModel.fromMap(
                              snapshot.data!.docs[index].data());
                          if (Constants.getSearchString(userData.name)
                                  .contains(searchUser.text) ||
                              Constants.getSearchString(userData.username)
                                  .contains(searchUser.text)) {
                            return kUserTile(
                              isDark,
                              userData: userData,
                              isSelecting: isSelecting,
                              selectedUsers: selectedUsers,
                              onTap: () {
                                onSelect(setState, userData.uid);
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    );
                  }
                  return const LinearProgressIndicator();
                },
              ),
              selectedUsers.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          int currentTime =
                              DateTime.now().millisecondsSinceEpoch;

                          Map<String, dynamic> requestMap = {
                            'id': "$currentTime",
                            'date': Constants.getDisplayDate(currentTime),
                            'time': Constants.getDisplayTime(currentTime),
                            'senderId': uid,
                            'users': selectedUsers,
                            'bookName': bookName,
                            'bookId': bookId,
                          };

                          await FirebaseRefs.requestRef
                              .doc("$currentTime")
                              .set(requestMap)
                              .then(
                                (value) => KSnackbar(
                                  context,
                                  content:
                                      "Request to join book has been sent to ${selectedUsers.length} user(s)",
                                ),
                              );
                          Navigator.pop(context);
                        },
                        child: const Text('Send Request'),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget FilterBottomSheet(bool isDark, StateSetter setState) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: kRadius(20),
                    color: isDark ? Dark.card : Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                              borderRadius: kRadius(50),
                            ),
                            child: Text(
                              'Filter',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? Colors.blue.shade100
                                  : Colors.blue.shade700,
                            ),
                            icon: Icon(
                              Icons.done,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                            label: Text(
                              'Apply',
                              style: TextStyle(
                                color: isDark ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          FilterBtns(
                            isDark,
                            setState: setState,
                            icon: Icon(
                              Icons.all_inbox,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                            label: 'All',
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          FilterBtns(
                            isDark,
                            setState: setState,
                            icon: Icon(
                              Icons.file_download_outlined,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                            label: 'Income',
                            color: isDark ? Dark.profitCard : Light.profitCard,
                          ),
                          FilterBtns(
                            isDark,
                            setState: setState,
                            icon: Icon(
                              Icons.file_upload_outlined,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                            label: 'Expense',
                            color: isDark ? Colors.red.shade300 : Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _clearAllTransacts() async {
    setState(() => _isLoading = true);
    await DatabaseMethods().deleteAllTransacts(bookData.bookId);
    await DatabaseMethods()
        .updateBookTransactions(bookData.bookId, {"income": 0, "expense": 0});
    setState(() => _isLoading = false);
  }

  GestureDetector FilterBtns(
    bool isDark, {
    required String label,
    required Widget icon,
    required Color color,
    required StateSetter setState,
  }) {
    bool isSelected = _selectedSortType == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSortType = label;
        });
        // Navigator.pop(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color : Colors.grey,
              boxShadow: [
                BoxShadow(
                  color: isSelected ? color : Colors.transparent,
                  blurRadius: 100,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: icon,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? isDark
                      ? color
                      : Colors.black
                  : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
