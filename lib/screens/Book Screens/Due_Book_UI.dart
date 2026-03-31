import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Components/User_Selector_Card.dart';
import 'package:transaction_record_app/Components/WIdgets.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/KButton.dart';
import 'package:transaction_record_app/Utility/KTextfield.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import '../../Helper/navigatorFns.dart';
import '../../Utility/commons.dart';
import '../../Utility/constants.dart';
import '../../Utility/newColors.dart';
import '../../models/transactModel.dart';
import '../../services/database.dart';
import 'package:transaction_record_app/Repository/book_repository.dart';
import 'package:transaction_record_app/screens/Transact%20Screens/edit_transactUI.dart';
import 'package:transaction_record_app/screens/Transact%20Screens/New_Transact_UI.dart';

class Due_Book_UI extends ConsumerStatefulWidget {
  final BookModel bookData;
  const Due_Book_UI({super.key, required this.bookData});

  @override
  ConsumerState<Due_Book_UI> createState() => _Due_Book_UIState(bookData);
}

class _Due_Book_UIState extends ConsumerState<Due_Book_UI> {
  final BookModel bookData;
  _Due_Book_UIState(this.bookData);

  String dateTitle = '';
  bool showDateWidget = false;
  final ValueNotifier<int> bookListCounter = ValueNotifier<int>(20);

  final oCcy = NumberFormat("#,##0.00", "en_US");

  final _searchController = TextEditingController();
  final String _selectedSortType = 'All';
  var items = ['All', 'Income', 'Expense'];
  final _newTargetAmount = TextEditingController();

  int searchingBookListCounter = 50;
  final isLoading = ValueNotifier(false);
  final isFetching = ValueNotifier(false);
  bool isSearching = false;
  final ScrollController _scrollController = ScrollController();
  bool _hasMore = true;

  // Future<void> _addUsers({
  //   required String uid,
  //   required String bookName,
  //   required String bookId,
  // }) async {
  //   try {
  //     Navigator.pop(context);
  //     setState(() {
  //       isLoading = true;
  //     });
  //     int currentTime = DateTime.now().millisecondsSinceEpoch;

  //     Map<String, dynamic> requestMap = {
  //       'id': "$currentTime",
  //       'date': Constants.getDisplayDate(currentTime),
  //       'time': Constants.getDisplayTime(currentTime),
  //       'senderId': uid,
  //       'users': selectedUsers,
  //       'bookName': bookName,
  //       'bookId': bookId,
  //     };

  //     await FirebaseRefs.requestRef.doc("$currentTime").set(requestMap).then(
  //           (value) => KSnackbar(
  //             context,
  //             content:
  //                 "Request to join book has been sent to ${selectedUsers.length} user(s)",
  //           ),
  //         );
  //   } catch (e) {
  //     KSnackbar(context, content: "Something went wrong!", isDanger: true);
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  void _setNewTarget() async {
    Navigator.pop(context);
    try {
      isLoading.value = true;

      await FirebaseFirestore.instance
          .collection("transactBooks")
          .doc(bookData.bookId)
          .update({"targetAmount": double.parse(_newTargetAmount.text)});

      if (context.mounted) {
        KSnackbar(
          context,
          content: "New target set successfully!",
          isDanger: false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        KSnackbar(context, content: "Something went wrong!", isDanger: true);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore && !isFetching.value) {
        bookListCounter.value += 10;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _newTargetAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isCompleted =
        bookData.targetAmount != 0 &&
        (bookData.income == bookData.targetAmount);

    final user = ref.watch(userProvider);
    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            bookData.bookName,
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
                            ).format(DateTime.parse(bookData.bookId)),
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
                          bookId: bookData.bookId,
                          initialName: bookData.bookName,
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
                            context.isDarkMode,
                            uid: user!.uid,
                            bookId: bookData.bookId,
                            bookName: bookData.bookName,
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
                                'Are you sure you want to delete "${bookData.bookName}" book?',
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
                                        .deleteBook(bookId: bookData.bookId);
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
              height20,
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseRefs.transactBookRef(
                  bookData.bookId,
                ).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.data() != null) {
                    final data = BookModel.fromMap(snapshot.data!.data()!);
                    double statsPaid = data.income - data.expense;
                    double statsDue = data.targetAmount - data.income;
                    double percent = data.targetAmount != 0
                        ? (statsPaid / data.targetAmount).clamp(0.0, 1.0)
                        : 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: context.isDarkMode
                                  ? [
                                      context.cardColor,
                                      context.cardColor.withAlpha(180),
                                    ]
                                  : [Colors.white, Colors.white.withAlpha(200)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: kRadius(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(
                                  context.isDarkMode ? 40 : 10,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _buildStatItem(
                                    context,
                                    label: isCompleted
                                        ? "Total Collected"
                                        : "Remaining Due",
                                    value: isCompleted ? data.income : statsDue,
                                    color: isCompleted
                                        ? context.profitColor
                                        : context.lossColor,
                                    isMain: true,
                                  ),
                                  const Spacer(),
                                  KButton.text(
                                    context,
                                    onTap: () {
                                      _newTargetAmount.text = data.targetAmount
                                          .toString();
                                      showDialog(
                                        context: context,
                                        builder: (context) => kAlertDialog(
                                          context,
                                          title: "Set Target",
                                          subTitle: "Goal for this book",
                                          content: KTextfield.regular(
                                            context,
                                            controller: _newTargetAmount,
                                            hintText: "0.00",
                                            fontSize: 24,
                                            keyboardType: TextInputType.number,
                                            prefix: const Padding(
                                              padding: EdgeInsets.only(
                                                right: 8,
                                              ),
                                              child: Text(
                                                "₹",
                                                style: TextStyle(fontSize: 24),
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            KButton.regular(
                                              context,
                                              onPressed: _setNewTarget,
                                              label: "Update Goal",
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    label: "Adjust Goal",
                                  ),
                                ],
                              ),
                              height20,
                              Row(
                                children: [
                                  _buildMiniStat(
                                    context,
                                    label: "Target",
                                    value: data.targetAmount,
                                    icon: Icons.flag_rounded,
                                  ),
                                  const Spacer(),
                                  _buildMiniStat(
                                    context,
                                    label: "Current",
                                    value: statsPaid,
                                    icon: Icons.account_balance_wallet_rounded,
                                    iconColor: context.profitColor,
                                  ),
                                ],
                              ),
                              if (data.targetAmount > 0 && !isCompleted) ...[
                                height20,
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Progress",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: context.fadeTextColor,
                                          ),
                                        ),
                                        Text(
                                          "${(percent * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: context.profitColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    height10,
                                    Stack(
                                      children: [
                                        Container(
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: context.isDarkMode
                                                ? Colors.white10
                                                : Colors.black.withAlpha(10),
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 1000,
                                          ),
                                          curve: Curves.easeOutCubic,
                                          height: 10,
                                          width:
                                              (MediaQuery.of(
                                                    context,
                                                  ).size.width -
                                                  64) *
                                              percent,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                context.profitColor.withAlpha(
                                                  180,
                                                ),
                                                context.profitColor,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: context.profitColor
                                                    .withAlpha(80),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ] else if (data.targetAmount == 0) ...[
                                height20,
                                const Center(
                                  child: Text(
                                    "✨ Set a goal to track progress",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
              height20,
              TransactList(context.isDarkMode, bookId: bookData.bookId),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navPush(
            context,
            New_Transact_UI(bookType: bookData.type, bookId: bookData.bookId),
          );
        },
        elevation: 0,
        highlightElevation: 0,
        child: const Icon(Icons.add),
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
    return StatefulBuilder(
      builder: (context, setState) => UserSelectorDialog(bookData: bookData),
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
            if (snapshot.hasData) {
              _hasMore = snapshot.data!.docs.length == bookCount;
            }
            dateTitle = '';

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: snapshot.hasData
                  ? snapshot.data!.docs.isNotEmpty
                        ? Consumer(
                            builder: (context, ref, _) {
                              final user = ref.watch(userProvider);
                              return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  final transact = Transact.fromMap(
                                    snapshot.data!.docs[index].data(),
                                  );

                                  // Filtering logic
                                  final searchKey = Constants.getSearchString(
                                    _searchController.text,
                                  );
                                  bool matchesSearch =
                                      searchKey.isEmpty ||
                                      transact.amount.contains(searchKey) ||
                                      transact.description
                                          .toLowerCase()
                                          .contains(searchKey.toLowerCase()) ||
                                      transact.source.toLowerCase().contains(
                                        searchKey.toLowerCase(),
                                      );

                                  bool matchesSort =
                                      _selectedSortType == 'All' ||
                                      transact.type.toLowerCase() ==
                                          _selectedSortType.toLowerCase();

                                  if (!matchesSearch || !matchesSort) {
                                    return const SizedBox.shrink();
                                  }

                                  // Date Grouping logic
                                  final bool showDate =
                                      index == 0 ||
                                      Transact.fromMap(
                                            snapshot.data!.docs[index - 1]
                                                .data(),
                                          ).date !=
                                          transact.date;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (showDate)
                                        _buildDateHeader(transact.date),
                                      TransactTile(
                                        data: transact,
                                        isDark: isDark,
                                        showUser:
                                            bookData.users != null &&
                                            bookData.users!.isNotEmpty,
                                        onTap: () {
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
                                  );
                                },
                              );
                            },
                          )
                        : NoData(context, customText: 'No Transacts')
                  : const SizedBox(),
            );
          },
        );
      },
    );
  }

  Widget _buildDateHeader(String date) {
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
      padding: const EdgeInsets.only(bottom: 12, top: 8),
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

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required double value,
    Color? color,
    bool isMain = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMain ? 14 : 12,
            fontWeight: isMain ? FontWeight.w600 : FontWeight.w500,
            color: context.fadeTextColor,
          ),
        ),
        Text(
          "₹ ${kMoneyFormat(value)}",
          style: TextStyle(
            fontSize: isMain ? 24 : 18,
            fontWeight: FontWeight.w800,
            color: color ?? context.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(
    BuildContext context, {
    required String label,
    required double value,
    required IconData icon,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor ?? context.fadeTextColor),
        width5,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "₹ ${kMoneyFormat(value)}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: context.fadeTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
