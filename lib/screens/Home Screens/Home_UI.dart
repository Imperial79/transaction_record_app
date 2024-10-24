import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/KButton.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import 'package:transaction_record_app/screens/Account%20Screen/accountUI.dart';
import 'package:transaction_record_app/screens/Book%20Screens/Due_Book_UI.dart';
import 'package:transaction_record_app/screens/Book%20Screens/Savings_Book_UI.dart';
import 'package:transaction_record_app/screens/Home%20Screens/HomeMenu.dart';
import 'package:transaction_record_app/services/database.dart';
import '../../Functions/bookFunctions.dart';
import '../../Utility/commons.dart';
import '../../Utility/components.dart';
import '../Book Screens/bookUI.dart';

final ValueNotifier<bool> showAdd = ValueNotifier<bool>(true);

class Home_UI extends ConsumerStatefulWidget {
  @override
  ConsumerState<Home_UI> createState() => _Home_UIState();
}

class _Home_UIState extends ConsumerState<Home_UI>
    with AutomaticKeepAliveClientMixin<Home_UI> {
  DatabaseMethods databaseMethods = DatabaseMethods();
  List? data;
  String dateTitle = '';
  bool showDateWidget = false;

  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final showMenuProvider = StateProvider<bool>((ref) => false);
  final ValueNotifier<bool> _showAdd = ValueNotifier<bool>(true);

  bool isKeyboardOpen = false;
  bool isLoading = false;

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

  Widget BookList(bool isDark, {required String uid}) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('transactBooks')
          .where(
            Filter.or(
              Filter(
                'users',
                arrayContains: uid,
              ),
              Filter('uid', isEqualTo: uid),
            ),
          )
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        dateTitle = '';
        return (snapshot.hasData)
            ? (snapshot.data!.docs.isEmpty)
                ? NewBookCard(context)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            BookModel newBook = BookModel.fromMap(
                                snapshot.data!.docs[index].data());

                            if (_searchController.text.isEmpty) {
                              return _bookTile(isDark, book: newBook);
                            } else {
                              if (kCompare(_searchController.text,
                                      newBook.bookName) ||
                                  kCompare(_searchController.text,
                                      newBook.bookDescription)) {
                                return _bookTile(isDark, book: newBook);
                              }
                              return const SizedBox();
                            }
                          },
                        ),
                      ],
                    ),
                  )
            : const Center(
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

  _deleteBook({
    required String bookName,
    required String bookId,
  }) async {
    Navigator.pop(context);
    try {
      setState(() {
        isLoading = true;
      });

      await BookMethods.deleteBook(
        context,
        bookName: bookName,
        bookId: bookId,
      );

      KSnackbar(context, content: "\"$bookName\" Book Deleted!");
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _showAdd.value = _searchController.text.isEmpty;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);
    final showHomeMenu = ref.watch(showMenuProvider);
    if (user != null) {
      return KScaffold(
        isLoading: isLoading,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AnimatedSize(
                reverseDuration: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.topCenter,
                curve: Curves.ease,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  reverseDuration: const Duration(milliseconds: 100),
                  child: showHomeMenu ? const HomeMenuUI() : Container(),
                ),
              ),
              AnimatedSize(
                reverseDuration: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 300),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          navPush(context, const AccountUI());
                                        },
                                        child: Hero(
                                          tag: 'profImg',
                                          child: CircleAvatar(
                                            radius: 12,
                                            child: ClipRRect(
                                              borderRadius: kRadius(50),
                                              child: user.imgUrl == ''
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Dark.profitCard,
                                                        strokeWidth: 1.5,
                                                      ),
                                                    )
                                                  : CachedNetworkImage(
                                                      imageUrl: user.imgUrl,
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
                                              'Hi,',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w400,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                            width5,
                                            Text(
                                              user.name.split(" ").first,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          ref
                                              .read(showMenuProvider.notifier)
                                              .state = !showHomeMenu;
                                        },
                                        borderRadius: kRadius(100),
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: isDark
                                              ? Dark.card
                                              : Colors.grey.shade200,
                                          child: Icon(
                                            showHomeMenu
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
                  physics: const BouncingScrollPhysics(),
                  controller: _scrollController,
                  children: [
                    height10,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                    BookList(isDark, uid: user.uid),
                    const SizedBox(
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
    return SizedBox();
  }

  Widget _bookTile(bool isDark, {required BookModel book}) {
    var todayDate = DateFormat.yMMMMd().format(DateTime.now());

    if (dateTitle == book.date) {
      showDateWidget = false;
    } else {
      dateTitle = book.date;
      showDateWidget = true;
    }

    // Change Card color -------------------->
    Color kCardColor = Dark.card;
    Color textColor = Colors.black;
    bool isCompleted = false;

    if (book.type == "regular") {
      isCompleted = book.expense != 0 && (book.income == book.expense);
    } else {
      isCompleted =
          book.targetAmount != 0 && (book.income == book.targetAmount);
    }

    if (isCompleted) {
      kCardColor = isDark ? Dark.completeCard : Light.completeCard;
      textColor = isDark ? Colors.white : Colors.black;
    } else {
      kCardColor = isDark ? Dark.card : Light.card;
      textColor = isDark ? Colors.white : Colors.black;
    }

    bool isSavings = book.type == "savings";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: showDateWidget,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              dateTitle == todayDate ? 'Today' : dateTitle,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (book.type == "due") {
              navPush(context, Due_Book_UI(bookData: book));
            } else if (book.type == "regular") {
              navPush(context, BookUI(bookData: book));
            } else {
              navPush(context, Savings_Book_UI(bookData: book));
            }
          },
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              elevation: 0,
              builder: (context) {
                return _deleteModal(
                  isDark,
                  bookId: book.bookId,
                  bookName: book.bookName,
                );
              },
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: kRadius(10),
            ),
            color: kCardColor,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCompleted)
                    Text(
                      "Completed",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            isDark ? Dark.onCompleteCard : Light.onCompleteCard,
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    book.bookName,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                width10,
                                book.users != null && book.users!.isNotEmpty
                                    ? const CircleAvatar(
                                        radius: 12,
                                        child: Icon(
                                          Icons.groups_2,
                                          size: 12,
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                            Visibility(
                              visible: book.bookDescription.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.note,
                                      color: textColor,
                                      size: 12,
                                    ),
                                    width5,
                                    Text(
                                      book.bookDescription,
                                      style: TextStyle(
                                        color: textColor,
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
                                  color: textColor,
                                  size: 12,
                                ),
                                width5,
                                Text(
                                  '${book.date} | ${book.time}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isSavings)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              borderRadius: kRadius(7),
                              color: isDark ? Dark.scaffold : Light.scaffold),
                          child: Text(
                            "₹ ${kMoneyFormat(book.income)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (!isCompleted && !isSavings)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: book.type == "due"
                          ? Row(
                              children: [
                                _bookStats(
                                  index: 0,
                                  crossAlign: CrossAxisAlignment.start,
                                  textColor:
                                      isDark ? Colors.white : Colors.black,
                                  amount:
                                      "₹ ${kMoneyFormat(book.targetAmount - book.income)}",
                                  label: 'Due',
                                  cardColor: isDark
                                      ? Dark.completeCard
                                      : Light.completeCard,
                                  amountColor: isDark
                                      ? Dark.onCompleteCard
                                      : Light.onCompleteCard,
                                ),
                                _bookStats(
                                  index: 2,
                                  crossAlign: CrossAxisAlignment.end,
                                  label: "Target",
                                  amount:
                                      "₹ ${kMoneyFormat(book.targetAmount)}",
                                  cardColor: isDark
                                      ? const Color(0xFF0B2A43)
                                      : const Color.fromARGB(
                                          255, 197, 226, 250),
                                  textColor: isDark
                                      ? Colors.white
                                      : Colors.blue.shade900,
                                  amountColor: isDark
                                      ? Colors.blue.shade100
                                      : Colors.blue.shade900,
                                ),
                              ],
                            )
                          : book.type == "regular"
                              ? Row(
                                  children: [
                                    _bookStats(
                                      index: 0,
                                      crossAlign: CrossAxisAlignment.start,
                                      textColor:
                                          isDark ? Colors.white : Colors.black,
                                      amount: "₹ ${kMoneyFormat(book.income)}",
                                      label: 'Income',
                                      cardColor: isDark
                                          ? const Color(0xFF223B05)
                                          : const Color(0xFFB5FFB7),
                                      amountColor: isDark
                                          ? Colors.lightGreenAccent
                                          : Colors.lightGreen.shade900,
                                    ),
                                    width5,
                                    _bookStats(
                                      index: 1,
                                      crossAlign: CrossAxisAlignment.center,
                                      amount: "₹ ${kMoneyFormat(book.expense)}",
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
                                      amount:
                                          "₹ ${kMoneyFormat(book.income - book.expense)}",
                                      cardColor: isDark
                                          ? const Color(0xFF0B2A43)
                                          : const Color.fromARGB(
                                              255, 197, 226, 250),
                                      textColor: isDark
                                          ? Colors.white
                                          : Colors.blue.shade900,
                                      amountColor: isDark
                                          ? Colors.blue.shade100
                                          : Colors.blue.shade900,
                                    ),
                                  ],
                                )
                              // : data.type == "savings"
                              //     ? Row(
                              //         children: [
                              //           _bookStats(
                              //             index: 0,
                              //             crossAlign: CrossAxisAlignment.start,
                              //             textColor: isDark
                              //                 ? Colors.white
                              //                 : Colors.black,
                              //             amount:
                              //                 "₹ ${kMoneyFormat(data.income)}",
                              //             label: 'Accumulated',
                              //             cardColor: isDark
                              //                 ? const Color(0xFF223B05)
                              //                 : const Color(0xFFB5FFB7),
                              //             amountColor: isDark
                              //                 ? Colors.lightGreenAccent
                              //                 : Colors.lightGreen.shade900,
                              //           ),
                              //         ],
                              //       )
                              : SizedBox(),
                    ),
                  if (isCompleted && !isSavings)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        height10,
                        const Text(
                          "Final Sum",
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          "INR ${kMoneyFormat(book.income)}",
                          style: TextStyle(
                            fontSize: 20,
                            color: isDark
                                ? Dark.onCompleteCard
                                : Light.onCompleteCard,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _deleteModal(
    bool isDark, {
    required String bookName,
    required String bookId,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: isDark ? Dark.modal : Light.modal,
              borderRadius: kRadius(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor:
                        isDark ? Colors.grey.shade300 : Colors.black,
                    child: Icon(
                      Icons.menu_open_sharp,
                      color: isDark ? Light.text : Dark.text,
                    ),
                  ),
                  height10,
                  Text(
                    "Book Options",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  height20,
                  KButton.icon(
                    isDark,
                    onPressed: () {
                      _deleteBook(bookId: bookId, bookName: bookName);
                    },
                    icon: Icon(Icons.delete),
                    label: "Delete \"$bookName\" Book!",
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    return Flexible(
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: kRadius(7),
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
