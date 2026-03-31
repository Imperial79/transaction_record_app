// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Components/User_Selector_Card.dart';
import 'package:transaction_record_app/Components/WIdgets.dart';
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

final transactCountProvider = StateProvider.autoDispose<int>((ref) => 10);
final hasMoreTransactsProvider = StateProvider.autoDispose<bool>((ref) => true);
final showElementsProvider = StateProvider.autoDispose<bool>((ref) => true);
final showMenuProvider = StateProvider.autoDispose<bool>((ref) => false);
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

class Regular_Book_UI extends ConsumerStatefulWidget {
  final String bookId;
  final String bookType;

  final BookModel bookData;
  const Regular_Book_UI({
    super.key,
    required this.bookId,
    required this.bookType,
    required this.bookData,
  });

  @override
  ConsumerState<Regular_Book_UI> createState() => _BookUIState();
}

class _BookUIState extends ConsumerState<Regular_Book_UI> {
  String dateTitle = '';
  String monthTitle = '';
  bool showDateWidget = false;
  final ScrollController _scrollController = ScrollController();

  final searchKey = TextEditingController();
  String _selectedSortType = 'All';
  var items = ['All', 'Income', 'Expense'];

  int searchingBookListCounter = 50;
  bool isSearching = false;
  Timer? _debounce;

  //------------------------------------>

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(scrollListener);
    searchKey.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(searchQueryProvider.notifier).state = searchKey.text;
      }
    });
  }

  void scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      ref.read(showElementsProvider.notifier).state = false;
    } else {
      ref.read(showElementsProvider.notifier).state = true;
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    final hasMore = ref.read(hasMoreTransactsProvider);
    if (hasMore && !isFetching.value) {
      ref.read(transactCountProvider.notifier).state += 10;
    }
  }

  Future<void> distribute() async {
    isLoading.value = true;
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

        if (context.mounted) {
          showModalBottomSheet(
            context: context,
            elevation: 0,
            backgroundColor: context.isDarkMode ? Dark.card : Light.card,
            builder: (context) {
              return DistributeModal(
                balanceSheet: balanceSheet,
                balanceSheetUsers: balanceSheetUsers,
              );
            },
          );
        }
      });
    });
    isLoading.value = false;
  }

  Future<void> _deleteBook({
    required String bookName,
    required String bookId,
  }) async {
    try {
      isLoading.value = true;

      final res = await ref.read(bookRepository).deleteBook(bookId: bookId);
      if (res && context.mounted) {
        KSnackbar(context, content: "\"$bookName\" Book Deleted!");
      }
    } catch (e) {
      if (context.mounted) {
        KSnackbar(
          context,
          content:
              "Unable to delete book! Check your connection or try again later.",
          isDanger: true,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  ///------------------------------->

  @override
  void dispose() {
    _debounce?.cancel();
    searchKey.removeListener(_onSearchChanged);
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    searchKey.dispose();
    super.dispose();
  }

  //------------------------------------>

  final isLoading = ValueNotifier(false);
  final isFetching = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(
            //   children: [
            //     IconButton.filledTonal(
            //       onPressed: () {
            //         context.go("/root");
            //       },
            //       icon: Icon(
            //         Icons.arrow_back,
            //         color: context.colorScheme.onSurface,
            //       ),
            //     ),
            //     Flexible(child: _SearchBar()),
            //   ],
            // ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  kBackButton(context),
                  width10,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.bookData.bookName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          DateFormat(
                            "dd MMM, yyyy",
                          ).format(DateTime.parse(widget.bookData.bookId)),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.fadeTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showRenameBookModal(
                        context,
                        ref,
                        bookId: widget.bookData.bookId,
                        initialName: widget.bookData.bookName,
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withAlpha(
                          context.isDarkMode ? 40 : 20,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 20,
                        color: context.primaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => _addUserDialog(
                          // context.isDarkMode,
                          uid: user!.uid,
                          bookData: widget.bookData,
                        ),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(
                          context.isDarkMode ? 40 : 20,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_add_rounded,
                        size: 20,
                        color: context.isDarkMode
                            ? Colors.blueAccent
                            : Colors.blue.shade700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => kAlertDialog(
                          context,
                          title: 'Delete Book?',
                          subTitle:
                              'Are you sure you want to delete "${widget.bookData.bookName}" book?',
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                try {
                                  isLoading.value = true;
                                  await ref
                                      .read(bookRepository)
                                      .deleteBook(
                                        bookId: widget.bookData.bookId,
                                      );
                                  if (context.mounted) Navigator.pop(context);
                                } catch (e) {
                                  if (context.mounted) {
                                    KSnackbar(
                                      context,
                                      content: "Delete failed",
                                      isDanger: true,
                                    );
                                  }
                                } finally {
                                  isLoading.value = false;
                                }
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(
                          context.isDarkMode ? 40 : 20,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _incomeExpenseTracker(),
            Expanded(
              child: _TransactList(
                bookId: widget.bookId,
                isFetching: isFetching.value,
                scrollController: _scrollController,
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

  Widget _incomeExpenseTracker() {
    return Consumer(
      builder: (context, ref, _) {
        final bookData = ref.watch(bookdataStream(widget.bookId));
        // final user = ref.watch(userProvider);
        // final showElements = ref.watch(showElementsProvider);
        // final showMenu = ref.watch(showMenuProvider);
        return bookData.when(
          data: (book) => Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Column(
              children: [
                // AnimatedSize(
                //   reverseDuration: const Duration(milliseconds: 300),
                //   duration: const Duration(milliseconds: 300),
                //   alignment: Alignment.topCenter,
                //   curve: Curves.ease,
                //   child: Container(
                //     child: showElements
                //         ? Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Padding(
                //                 padding: const EdgeInsets.symmetric(
                //                   horizontal: 10,
                //                 ),
                //                 child: Row(
                //                   crossAxisAlignment: CrossAxisAlignment.start,
                //                   mainAxisAlignment:
                //                       MainAxisAlignment.spaceBetween,
                //                   mainAxisSize: MainAxisSize.min,
                //                   children: [
                //                     Flexible(
                //                       child: Text(
                //                         book.bookName,
                //                         style: const TextStyle(fontSize: 15),
                //                       ),
                //                     ),
                //                     width10,
                //                     InkWell(
                //                       onTap: () {
                //                         ref
                //                                 .read(showMenuProvider.notifier)
                //                                 .state =
                //                             !showMenu;
                //                       },
                //                       borderRadius: kRadius(100),
                //                       child: CircleAvatar(
                //                         radius: 12,
                //                         backgroundColor: context.isDarkMode
                //                             ? Dark.card
                //                             : Colors.grey.shade200,
                //                         child: FittedBox(
                //                           child: Icon(
                //                             showMenu
                //                                 ? Icons
                //                                       .keyboard_arrow_up_rounded
                //                                 : Icons
                //                                       .keyboard_arrow_down_rounded,
                //                             size: 20,
                //                             color:
                //                                 context.colorScheme.onSurface,
                //                           ),
                //                         ),
                //                       ),
                //                     ),
                //                     width10,
                //                     InkWell(
                //                       borderRadius: kRadius(100),
                //                       onTap: () {
                // navPush(
                //   context,
                //   UsersUI(
                //     users: book.users!,
                //     ownerUid: book.uid,
                //     bookId: book.bookId,
                //   ),
                // );
                //                       },
                //                       child: const FittedBox(
                //                         child: CircleAvatar(
                //                           radius: 12,
                //                           child: Icon(Icons.groups_2, size: 12),
                //                         ),
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //               height10,
                //               AnimatedSize(
                //                 reverseDuration: const Duration(
                //                   milliseconds: 300,
                //                 ),
                //                 duration: const Duration(milliseconds: 300),
                //                 alignment: Alignment.topCenter,
                //                 curve: Curves.ease,
                //                 child: showMenu
                //                     ? BookMenu(bookData: book, uid: user!.uid)
                //                     : Container(),
                //               ),
                //             ],
                //           )
                //         : Container(),
                //   ),
                // ),
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        style: TextStyle(
                          fontFamily: "Product",
                          fontSize: 25,
                          color: context.colorScheme.onSurface,
                        ),
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'INR ',
                              style: TextStyle(fontWeight: FontWeight.w300),
                            ),
                            TextSpan(
                              text: kMoneyFormat(book.income - book.expense),
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        navPush(
                          context,
                          UsersUI(
                            users: book.users!,
                            ownerUid: book.uid,
                            bookId: book.bookId,
                          ),
                        );
                      },
                      icon: Icon(Icons.groups_2, color: context.primaryColor),
                    ),
                    _filterButton(),
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
                          borderRadius: kRadius(12),
                          color: context.profitCardColor.withAlpha(50),
                          border: Border.all(
                            color: context.profitColor.withAlpha(50),
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
                          borderRadius: kRadius(12),
                          color: context.lossCardColor.withAlpha(50),
                          border: Border.all(
                            color: context.lossColor.withAlpha(50),
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

  Widget DistributeModal({
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
                const Text('Settlement', style: TextStyle(fontSize: 30)),
                height20,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(child: Text('Will Pay')),
                    Expanded(
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: context.primaryColor,
                        child: FittedBox(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              '₹',
                              style: TextStyle(
                                color: context.isDarkMode
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Expanded(child: Text('To', textAlign: TextAlign.end)),
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
                        color: context.scaffoldColor,
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
                              color: context.cardColor,
                            ),
                            child: Text(
                              "₹ ${balanceSheet[index]['amount'].toStringAsFixed(2)}",
                              style: TextStyle(
                                color: context.colorScheme.onSurface,
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

  Container _filterButton() {
    final isAll = _selectedSortType == 'All';
    final isIncome = _selectedSortType == 'Income';

    // Define colors based on selected sort type
    final backgroundColor = context.isDarkMode
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

    final iconColor = context.isDarkMode
        ? (isIncome || isAll ? Colors.black : Colors.white)
        : (isAll || !isIncome ? Colors.white : Colors.black);

    final iconType = isAll
        ? Icons.filter_list
        : isIncome
        ? Icons.file_download_outlined
        : Icons.file_upload_outlined;

    final boxShadowColor = isAll
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
                return FilterBottomSheet(setState);
              },
            ).then((_) => setState(() {}));
          },
          icon: Icon(iconType, color: iconColor),
        ),
      ),
    );
  }

  // Container _SearchBar() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
  //     margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
  //     decoration: BoxDecoration(
  //       color: context.isDarkMode ? Dark.card : Light.card,
  //       borderRadius: const BorderRadius.horizontal(left: Radius.circular(100)),
  //     ),
  //     child: Row(
  //       crossAxisAlignment: .center,
  //       children: [
  //         SvgPicture.asset(
  //           'lib/assets/icons/search.svg',
  //           height: 20,
  //           colorFilter: svgColor(context.isDarkMode ? Dark.text : Light.text),
  //         ),
  //         width10,
  //         Flexible(
  //           child: TextField(
  //             controller: searchKey,
  //             cursorColor: context.isDarkMode ? Dark.primary : Light.primary,
  //             style: TextStyle(
  //               color: context.isDarkMode ? Colors.white : Colors.black,
  //             ),
  //             decoration: InputDecoration(
  //               border: InputBorder.none,
  //               isDense: true,
  //               contentPadding: EdgeInsets.symmetric(vertical: 10),
  //               // contentPadding: EdgeInsets.all(0),
  //               hintStyle: TextStyle(
  //                 fontWeight: FontWeight.w400,
  //                 color: context.isDarkMode ? Dark.fadeText : Light.fadeText,
  //               ),
  //               hintText: 'Search amount, description, etc',
  //               suffixIcon: ValueListenableBuilder(
  //                 valueListenable: searchKey,
  //                 builder: (context, value, child) {
  //                   return searchKey.text.isNotEmpty
  //                       ? IconButton(
  //                           padding: EdgeInsets.zero,
  //                           onPressed: () {
  //                             searchKey.clear();
  //                             ref.read(searchQueryProvider.notifier).state = '';
  //                           },
  //                           icon: Icon(
  //                             Icons.cancel_rounded,
  //                             size: 18,
  //                             color: context.isDarkMode
  //                                 ? Dark.fadeText
  //                                 : Light.fadeText,
  //                           ),
  //                         )
  //                       : const SizedBox.shrink();
  //                 },
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget BookMenu({required BookModel bookData, required String uid}) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.isDarkMode ? Dark.card : Light.card,
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
                  color: context.isDarkMode
                      ? Colors.grey.shade900
                      : Colors.grey.shade300,
                  borderRadius: kRadius(50),
                ),
                child: Text(
                  bookData.date,
                  style: TextStyle(
                    color: context.isDarkMode ? Dark.fadeText : Light.fadeText,
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
                  showRenameBookModal(
                    context,
                    ref,
                    bookId: bookData.bookId,
                    initialName: bookData.bookName,
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
                btnColor: context.isDarkMode
                    ? Colors.blue.shade700
                    : Colors.blueGrey.shade600,
                textColor: Colors.white,
              ),
              BookMenuBtn(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        _addUserDialog(uid: uid, bookData: bookData),
                  );
                },
                labelSize: 12,
                label: 'Add User(s)',
                iconSize: 15,
                icon: Icons.person_add_alt_1,
                btnColor: context.isDarkMode
                    ? Dark.profitText
                    : const Color(0xFF27576D),
                textColor: context.isDarkMode ? Colors.black : Colors.white,
              ),
              BookMenuBtn(
                onPressed: () {
                  distribute();
                },
                labelSize: 12,
                label: 'Distribute',
                iconSize: 15,
                icon: Icons.alt_route_rounded,
                btnColor: context.isDarkMode
                    ? Dark.profitText
                    : const Color(0xFF27576D),
                textColor: context.isDarkMode ? Colors.black : Colors.white,
              ),
              // BookMenuBtn(
              //   onPressed: () {
              //     Share.share(
              //       'check out my transact book "${bookData.bookName}" ${Uri.parse("$kAppLink/book/${bookData.type}/${bookData.bookId}")}',
              //     );
              //   },
              //   labelSize: 12,
              //   label: 'Share',
              //   iconSize: 15,
              //   icon: Icons.share,
              //   btnColor: kColor(context).primary,
              //   textColor: !context.isDarkMode ? Dark.text : Light.text,
              // ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> selectedUsers = [];
  Widget _addUserDialog({required String uid, required BookModel bookData}) {
    return StatefulBuilder(
      builder: (context, setState) => UserSelectorDialog(bookData: bookData),
    );
  }

  Widget FilterBottomSheet(StateSetter setState) {
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
                    color: context.isDarkMode ? Dark.card : Colors.white,
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
                              color: context.isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                              borderRadius: kRadius(50),
                            ),
                            child: Text(
                              'Filter',
                              style: TextStyle(
                                color: context.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
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
                              backgroundColor: context.isDarkMode
                                  ? Colors.blue.shade100
                                  : Colors.blue.shade700,
                            ),
                            icon: Icon(
                              Icons.done,
                              color: context.isDarkMode
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            label: Text(
                              'Apply',
                              style: TextStyle(
                                color: context.isDarkMode
                                    ? Colors.black
                                    : Colors.white,
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
                            setState: setState,
                            icon: Icon(
                              Icons.all_inbox,
                              color: context.isDarkMode
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            label: 'All',
                            color: context.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                          FilterBtns(
                            setState: setState,
                            icon: Icon(
                              Icons.file_download_outlined,
                              color: context.isDarkMode
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            label: 'Income',
                            color: context.isDarkMode
                                ? Dark.profitCard
                                : Light.profitCard,
                          ),
                          FilterBtns(
                            setState: setState,
                            icon: Icon(
                              Icons.file_upload_outlined,
                              color: context.isDarkMode
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            label: 'Expense',
                            color: context.isDarkMode
                                ? Colors.red.shade300
                                : Colors.red,
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
    isLoading.value = true;
    await DatabaseMethods().deleteAllTransacts(bookId);
    await DatabaseMethods().updateBookTransactions(bookId, {
      "income": 0,
      "expense": 0,
    });
    isLoading.value = false;
  }

  GestureDetector FilterBtns({
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
              color: isSelected
                  ? context.isDarkMode
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

class _TransactList extends ConsumerWidget {
  final String bookId;
  final bool isFetching;
  final ScrollController scrollController;

  const _TransactList({
    required this.bookId,
    required this.isFetching,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(transactCountProvider);
    final bookData = ref.watch(bookdataStream(bookId));
    final searchQuery = ref.watch(searchQueryProvider);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('transactBooks')
          .doc(bookId)
          .collection('transacts')
          .orderBy('ts', descending: true)
          .limit(count)
          .snapshots(),
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: () {
            if (!snapshot.hasData) return const SizedBox.shrink();
            if (snapshot.data!.docs.isEmpty) {
              return kNoData(context, title: 'No Transacts');
            }

            final items = snapshot.data!.docs
                .map((doc) => Transact.fromMap(doc.data()))
                .where(
                  (transact) =>
                      kCompare(searchQuery, transact.amount) ||
                      kCompare(searchQuery, transact.description),
                )
                .toList();

            // Efficiently handle hasMore state updates
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                ref.read(hasMoreTransactsProvider.notifier).state =
                    snapshot.data!.docs.length == count;
              }
            });

            if (items.isEmpty) {
              return kNoData(context, title: 'No Transacts Found');
            }

            String getMonthStr(String d) {
              try {
                return DateFormat.yMMMM().format(DateFormat.yMMMMd().parse(d));
              } catch (e) {
                return "";
              }
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemCount: items.length,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 100),
                    itemBuilder: (context, index) {
                      final transact = items[index];
                      final prevTransact = index > 0 ? items[index - 1] : null;

                      final currentMonth = getMonthStr(transact.date);
                      final bool showMonth =
                          index == 0 ||
                          getMonthStr(prevTransact!.date) != currentMonth;
                      final bool showDate =
                          index == 0 || prevTransact!.date != transact.date;

                      return TweenAnimationBuilder<double>(
                        duration: Duration(
                          milliseconds: 400 + (index.clamp(0, 10) * 40),
                        ),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showMonth)
                              _buildMonthHeader(context, currentMonth),
                            if (showDate && !showMonth)
                              _buildDateHeader(context, transact.date),
                            TransactTile(
                              key: ValueKey(transact.transactId),
                              data: transact,
                              showUser:
                                  bookData.value?.users != null &&
                                  bookData.value!.users!.isNotEmpty,
                              isDark: context.isDarkMode,
                              onTap: () {
                                final user = ref.read(userProvider);
                                if (transact.uid == user?.uid) {
                                  navPush(
                                    context,
                                    EditTransactUI(trData: transact),
                                  );
                                } else {
                                  KSnackbar(
                                    context,
                                    content:
                                        "You cannot edit other's transactions",
                                    isDanger: true,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (isFetching) const CustomLoading(),
              ],
            );
          }(),
        );
      },
    );
  }

  Widget _buildMonthHeader(BuildContext context, String monthLabel) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, left: 12, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "${monthLabel.split(' ').first}, ",
            style: TextStyle(
              fontSize: 22,
              height: 1,
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            monthLabel.split(' ').last,
            style: TextStyle(
              fontSize: 12,
              height: 1,
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, String date) {
    String label = date;
    final today = DateFormat.yMMMMd().format(DateTime.now());
    final yesterday = DateFormat.yMMMMd().format(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    if (date == today) {
      label = 'Today';
    } else if (date == yesterday) {
      label = 'Yesterday';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 12, left: 12),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: context.fadeTextColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
