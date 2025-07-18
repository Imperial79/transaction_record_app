// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transaction_record_app/Components/User_Selector_Card.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Repository/book_repository.dart';
import 'package:transaction_record_app/Utility/CustomLoading.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import 'package:transaction_record_app/models/transactModel.dart';
import 'package:transaction_record_app/screens/Book%20Screens/Users_UI.dart';
import 'package:transaction_record_app/screens/Transact%20Screens/edit_transactUI.dart';
import 'package:transaction_record_app/screens/Transact%20Screens/New_Transact_UI.dart';
import '../../Helper/navigatorFns.dart';
import '../../Utility/commons.dart';
import '../../services/database.dart';
import '../../Utility/components.dart';

class Regular_Book_UI extends ConsumerStatefulWidget {
  final String bookId;
  final String bookType;
  const Regular_Book_UI({
    super.key,
    required this.bookId,
    required this.bookType,
  });

  @override
  ConsumerState<Regular_Book_UI> createState() => _BookUIState();
}

class _BookUIState extends ConsumerState<Regular_Book_UI> {
  String dateTitle = '';
  String monthTitle = '';
  bool showDateWidget = false;
  final ScrollController _scrollController = ScrollController();

  final transactCountProvider = StateProvider.autoDispose<int>((ref) => 10);
  final showElementsProvider = StateProvider.autoDispose<bool>((ref) => true);
  final showMenuProvider = StateProvider.autoDispose<bool>((ref) => false);

  final searchKey = TextEditingController();
  String _selectedSortType = 'All';
  var items = ['All', 'Income', 'Expense'];
  final newBookName = TextEditingController();

  int searchingBookListCounter = 50;
  bool isSearching = false;

  //------------------------------------>

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      ref.read(showElementsProvider.notifier).state = false;
    } else {
      ref.read(showElementsProvider.notifier).state = true;
    }
    if (_scrollController.position.atEdge) {
      bool isBottom =
          _scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent;
      if (isBottom) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() {
      isFetching = true;
    });
    await Future.delayed(Duration(seconds: 2));
    ref.read(transactCountProvider.notifier).state += 5;
    setState(() {
      isFetching = false;
    });
  }

  Future<void> distribute(bool isDark) async {
    setState(() {
      isLoading = true;
    });
    await FirebaseRefs.transactBookRef(widget.bookId).get().then((value) async {
      List<dynamic> groupMembers = [];

      groupMembers.addAll(value.data()!['users']);
      groupMembers.add(value.data()!['uid']);

      Map<String, double> expenseMap = {
        for (var item in groupMembers) item: 0.0,
      };
      double totalExpense = value.data()!['expense'];

      await FirebaseRefs.transactsRef(widget.bookId).get().then((
        snapshot,
      ) async {
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
                'recieverUid': recieverUid,
              });
              recieverSpent = 0;
            } else if (recieverSpent - payerPay > 0) {
              recieverSpent -= payerPay;
              balanceSheet.add({
                'payerUid': payerUid,
                'amount': payerPay,
                'recieverUid': recieverUid,
              });
              payerPay = 0;
              // payer gave all money reciever is yet to get money
            } else {
              balanceSheet.add({
                'payerUid': payerUid,
                'amount': payerPay,
                'recieverUid': recieverUid,
              });
              recieverSpent = 0;
              payerPay = 0;
              // no due
            }
          }
        }

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

  Future<void> _deleteBook({
    required String bookName,
    required String bookId,
  }) async {
    try {
      setState(() {
        isLoading = true;
      });

      final res = await ref.read(bookRepository).deleteBook(bookId: bookId);
      if (res) {
        KSnackbar(context, content: "\"$bookName\" Book Deleted!");
      }
    } catch (e) {
      KSnackbar(
        context,
        content:
            "Unable to delete book! Check your connection or try again later.",
        isDanger: true,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  ///------------------------------->

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    searchKey.dispose();
  }

  //------------------------------------>

  bool isLoading = false;
  bool isFetching = false;

  @override
  Widget build(BuildContext context) {
    isSearching = searchKey.text.isNotEmpty;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  reverseDuration: const Duration(milliseconds: 300),
                  alignment: Alignment.centerLeft,
                  curve: Curves.ease,
                  child: IconButton(
                    color: isDark ? Dark.profitText : Light.profitText,
                    onPressed: () {
                      // Navigator.pop(context);
                      context.go("/root");
                    },
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: isDark ? Dark.profitCard : Colors.black,
                        ),
                        searchKey.text.isEmpty
                            ? const SizedBox(width: 10)
                            : const SizedBox(),
                        searchKey.text.isEmpty
                            ? Text(
                              'Return',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
                Flexible(child: _SearchBar(isDark)),
              ],
            ),
            _incomeExpenseTracker(isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 100),
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: TransactList(isDark, bookId: widget.bookId),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navPush(
            context,
            New_Transact_UI(bookId: widget.bookId, bookType: widget.bookType),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget TransactList(bool isDark, {required String bookId}) {
    dateTitle = '';
    monthTitle = '';
    return Consumer(
      builder: (context, ref, _) {
        final count = ref.watch(transactCountProvider);
        final bookData = ref.watch(bookdataStream(widget.bookId));
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream:
              firestore
                  .collection('transactBooks')
                  .doc(bookId)
                  .collection('transacts')
                  .orderBy('ts', descending: true)
                  .limit(count)
                  .snapshots(),
          builder: (context, snapshot) {
            dateTitle = '';
            monthTitle = '';
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child:
                  snapshot.hasData
                      ? snapshot.data!.docs.isNotEmpty
                          ? Column(
                            children: [
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data!.docs.length,
                                shrinkWrap: true,
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  0,
                                  10,
                                  20,
                                ),
                                itemBuilder: (context, index) {
                                  Transact transact = Transact.fromMap(
                                    snapshot.data!.docs[index].data(),
                                  );

                                  if (kCompare(
                                        searchKey.text,
                                        transact.amount,
                                      ) ||
                                      kCompare(
                                        searchKey.text,
                                        transact.description,
                                      )) {
                                    return TransactTile(
                                      isDark,
                                      data: transact,
                                      users: bookData.value?.users,
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                              if (isFetching) const CustomLoading(),
                            ],
                          )
                          : kNoData(isDark, title: 'No Transacts')
                      : const SizedBox(),
            );
          },
        );
      },
    );
  }

  Widget _incomeExpenseTracker(bool isDark) {
    return Consumer(
      builder: (context, ref, _) {
        final bookData = ref.watch(bookdataStream(widget.bookId));
        final user = ref.watch(userProvider);
        final showElements = ref.watch(showElementsProvider);
        final showMenu = ref.watch(showMenuProvider);
        return bookData.when(
          data:
              (book) => Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  children: [
                    AnimatedSize(
                      reverseDuration: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 300),
                      alignment: Alignment.topCenter,
                      curve: Curves.ease,
                      child: Container(
                        child:
                            showElements
                                ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              book.bookName,
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          width10,
                                          InkWell(
                                            onTap: () {
                                              ref
                                                  .read(
                                                    showMenuProvider.notifier,
                                                  )
                                                  .state = !showMenu;
                                            },
                                            borderRadius: kRadius(100),
                                            child: CircleAvatar(
                                              radius: 12,
                                              backgroundColor:
                                                  isDark
                                                      ? Dark.card
                                                      : Colors.grey.shade200,
                                              child: FittedBox(
                                                child: Icon(
                                                  showMenu
                                                      ? Icons
                                                          .keyboard_arrow_up_rounded
                                                      : Icons
                                                          .keyboard_arrow_down_rounded,
                                                  size: 20,
                                                  color:
                                                      isDark
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
                                                  users: book.users!,
                                                  ownerUid: book.uid,
                                                  bookId: book.bookId,
                                                ),
                                              );
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
                                    height10,
                                    AnimatedSize(
                                      reverseDuration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      alignment: Alignment.topCenter,
                                      curve: Curves.ease,
                                      child:
                                          showMenu
                                              ? BookMenu(
                                                isDark,
                                                bookData: book,
                                                uid: user!.uid,
                                              )
                                              : Container(),
                                    ),
                                  ],
                                )
                                : Container(),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text.rich(
                            style: TextStyle(
                              fontFamily: "Product",
                              fontSize: 25,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'INR ',
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                ),
                                TextSpan(
                                  text: kMoneyFormat(
                                    book.income - book.expense,
                                  ),
                                  style: TextStyle(fontWeight: FontWeight.w600),
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
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: kRadius(10),
                              color: (isDark
                                      ? Dark.profitCard
                                      : Light.profitText)
                                  .lighten(.2),
                              border: Border.all(
                                color:
                                    isDark ? Dark.profitCard : Light.profitText,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.trending_up, size: 15),
                                width10,
                                Expanded(
                                  child: Text(
                                    "INR ${kMoneyFormat(book.income)}",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        width10,
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: kRadius(10),
                              color: (isDark ? Dark.lossCard : Light.lossCard)
                                  .lighten(.2),
                              border: Border.all(
                                color: isDark ? Dark.lossCard : Light.lossCard,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.trending_down_rounded, size: 15),
                                width10,
                                Expanded(
                                  child: Text(
                                    "INR ${kMoneyFormat(book.expense)}",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          error: (error, stackTrace) => SizedBox(),
          loading: () => SizedBox(),
        );
      },
    );
  }

  Widget DistributeModal(
    bool isDark, {
    required List<dynamic> balanceSheet,
    required Map<String, dynamic> balanceSheetUsers,
  }) {
    return StatefulBuilder(
      builder:
          (context, setState) => SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              width: double.infinity,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Settlement', style: TextStyle(fontSize: 30)),
                    height20,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(child: Text('Will Pay')),
                        Expanded(
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor:
                                isDark ? Dark.primary : Light.primary,
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
                          ),
                        ),
                        const Expanded(
                          child: Text('To', textAlign: TextAlign.end),
                        ),
                      ],
                    ),
                    height20,
                    ListView.separated(
                      itemCount: balanceSheet.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        String payerName =
                            balanceSheetUsers[balanceSheet[index]['payerUid']]['name']
                                .split(" ")
                                .first;
                        String payerImg =
                            balanceSheetUsers[balanceSheet[index]['payerUid']]['imgUrl'];
                        String recieverName =
                            balanceSheetUsers[balanceSheet[index]['recieverUid']]['name']
                                .split(" ")
                                .first;
                        String recieverImg =
                            balanceSheetUsers[balanceSheet[index]['recieverUid']]['imgUrl'];
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
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              width10,
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: kRadius(100),
                                  color: isDark ? Light.card : Dark.card,
                                ),
                                child: Text(
                                  "₹ ${balanceSheet[index]['amount'].toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: isDark ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
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
                                      backgroundImage: NetworkImage(
                                        recieverImg,
                                      ),
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

  Container _filterButton(bool isDark) {
    final isAll = _selectedSortType == 'All';
    final isIncome = _selectedSortType == 'Income';

    // Define colors based on selected sort type
    final backgroundColor =
        isDark
            ? isAll
                ? Dark.text
                : isIncome
                ? Dark.profitCard
                : Dark.lossCard
            : isAll
            ? Colors.black
            : isIncome
            ? Dark.profitCard
            : Dark.lossCard;

    final iconColor =
        isDark
            ? (isIncome || isAll ? Colors.black : Colors.white)
            : (isAll || !isIncome ? Colors.white : Colors.black);

    final iconType =
        isAll
            ? Icons.filter_list
            : isIncome
            ? Icons.file_download_outlined
            : Icons.file_upload_outlined;

    final boxShadowColor =
        isAll
            ? Colors.grey.shade500
            : isIncome
            ? Dark.profitCard
            : Colors.red;

    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        boxShadow: [
          BoxShadow(color: boxShadowColor, blurRadius: 100, spreadRadius: 10),
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
            ).then((_) => setState(() {}));
          },
          icon: Icon(iconType, color: iconColor),
        ),
      ),
    );
  }

  Container _SearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
      margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Dark.card : Light.card,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(100)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'lib/assets/icons/search.svg',
            height: 20,
            colorFilter: svgColor(isDark ? Dark.text : Light.text),
          ),
          width10,
          Flexible(
            child: TextField(
              controller: searchKey,
              cursorColor: isDark ? Dark.primary : Light.primary,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
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

  Widget TransactTile(
    bool isDark, {
    required Transact data,
    required List? users,
  }) {
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

    return Consumer(
      builder: (context, ref, _) {
        final user = ref.watch(userProvider)!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateWidget)
              Padding(
                padding: const EdgeInsets.only(top: 15.0, left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dateLabel.split(" ").first.trim(),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Dark.fadeText : Light.fadeText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.uid != user.uid && users != null && users.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child:
                        FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          future:
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(data.uid)
                                  .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return CircleAvatar(
                                radius: 12,
                                backgroundImage: NetworkImage(
                                  snapshot.data!.data()!['imgUrl'],
                                ),
                              );
                            }

                            return const CircleAvatar(radius: 12);
                          },
                        ),
                  ),
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
                      margin: const EdgeInsets.only(top: 10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: (isIncome
                                    ? isDark
                                        ? Dark.profitText
                                        : Light.profitText
                                    : isDark
                                    ? Dark.lossText
                                    : Light.lossText)
                                .lighten(.3),
                          ),
                          borderRadius: kRadius(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              color:
                                                  isIncome
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
                                                      color:
                                                          isIncome
                                                              ? isDark
                                                                  ? Dark
                                                                      .profitCard
                                                                      .lighten(
                                                                        .5,
                                                                      )
                                                                  : Light
                                                                      .profitCard
                                                                      .lighten(
                                                                        .5,
                                                                      )
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
                                                    ? Icons
                                                        .file_download_outlined
                                                    : Icons
                                                        .file_upload_outlined,
                                                color:
                                                    isIncome
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
                                            child: Text.rich(
                                              textAlign: TextAlign.start,
                                              TextSpan(
                                                text: kMoneyFormat(data.amount),
                                                style: TextStyle(
                                                  fontFamily: "Product",
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      isIncome
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
                                          margin: const EdgeInsets.only(
                                            top: 10,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          width: double.maxFinite,
                                          decoration: BoxDecoration(
                                            color:
                                                isDark ? Dark.card : Light.card,
                                            borderRadius: kRadius(10),
                                          ),
                                          child: Text(data.description),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  data.transactMode,
                                  style: TextStyle(
                                    letterSpacing: 1,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        data.transactMode == 'CASH'
                                            ? isDark
                                                ? Dark.profitText
                                                : Colors.black
                                            : isDark
                                            ? const Color(0xFF9DC4FF)
                                            : Colors.blue.shade900,
                                  ),
                                ),
                              ],
                            ),
                            height10,
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.schedule_rounded, size: 15),
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
                  visible:
                      data.uid == user.uid && users != null && users.isNotEmpty,
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
      },
    );
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
                  child: Icon(icon, color: Colors.white),
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
    required BookModel bookData,
    required String uid,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
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
                        onUpdate: () {
                          Navigator.pop(context);
                          ref
                              .read(bookRepository)
                              .updateBook(
                                bookId: bookData.bookId,
                                data: {'bookName': newBookName.text.trim()},
                              );
                        },
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
                          Navigator.pop(context);
                          _deleteBook(
                            bookId: bookData.bookId,
                            bookName: bookData.bookName,
                          );
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
                          _clearAllTransacts(bookData.bookId);
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
                    builder:
                        (context) => _addUserDialog(
                          isDark,
                          uid: uid,
                          bookData: bookData,
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
              BookMenuBtn(
                onPressed: () {
                  Share.share(
                    'check out my transact book "${bookData.bookName}" ${Uri.parse("$kAppLink/book/${bookData.type}/${bookData.bookId}")}',
                  );
                },
                labelSize: 12,
                label: 'Share',
                iconSize: 15,
                icon: Icons.share,
                btnColor: kColor(context).primary,
                textColor: !isDark ? Dark.text : Light.text,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget kRenameModal(
    BuildContext context, {
    required String bookId,
    required String oldBookName,
    required void Function()? onUpdate,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return StatefulBuilder(
      builder: (context, setState) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            margin: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: isDark ? Dark.card : Light.card,
              borderRadius: kRadius(20),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor:
                        isDark ? Colors.blue.shade100 : Colors.blueAccent,
                    child: Text(
                      'Aa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.blue.shade800 : Colors.white,
                      ),
                    ),
                  ),
                  height10,
                  Text(
                    'Rename Book',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Change the book name',
                    style: TextStyle(
                      color: isDark ? Colors.blue.shade300 : Colors.blueAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  height20,
                  TextField(
                    controller: newBookName,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    cursorWidth: 1,
                    cursorColor: isDark ? Colors.white : Colors.black,
                    decoration: InputDecoration(
                      focusColor: isDark ? Colors.white : Colors.black,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: isDark ? Dark.scaffold : Colors.black,
                          width: 2,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: isDark ? Dark.scaffold : Colors.grey.shade300,
                        ),
                      ),
                      hintText: 'Book title',
                      hintStyle: TextStyle(
                        fontSize: 30,
                        color: isDark ? Dark.scaffold : Colors.grey.shade400,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        newBookName.text = value;
                      });
                    },
                  ),
                  height20,
                  ElevatedButton.icon(
                    onPressed: onUpdate,
                    icon: const Icon(Icons.file_upload_outlined),
                    label: const Text('Update'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<String> selectedUsers = [];
  // bool isSelecting = false;
  Widget _addUserDialog(
    bool isDark, {
    required String uid,
    required BookModel bookData,
  }) {
    return StatefulBuilder(
      builder: (context, setState) => UserSelectorDialog(bookData: bookData),
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
                              horizontal: 15,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isDark
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
                              backgroundColor:
                                  isDark
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 10),
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

  Future<void> _clearAllTransacts(String bookId) async {
    setState(() => isLoading = true);
    await DatabaseMethods().deleteAllTransacts(bookId);
    await DatabaseMethods().updateBookTransactions(bookId, {
      "income": 0,
      "expense": 0,
    });
    setState(() => isLoading = false);
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
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color:
                  isSelected
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
