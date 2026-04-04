import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/components/book/book_header.dart';
import 'package:transaction_record_app/components/common/action_button.dart';
import 'package:transaction_record_app/components/common/stat_box.dart';
import 'package:transaction_record_app/components/common/widgets.dart';
import 'package:transaction_record_app/components/common/k_scaffold.dart';
import 'package:transaction_record_app/components/transaction/transact_list_header.dart';
import 'package:transaction_record_app/components/transaction/transact_tile.dart';
import 'package:transaction_record_app/components/book/user_selector_card.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import 'package:transaction_record_app/models/transactModel.dart';
import 'package:transaction_record_app/repositories/book_repository.dart';
import 'package:transaction_record_app/screens/book/users_screen.dart';
import 'package:transaction_record_app/screens/transaction/edit_transaction_screen.dart';
import 'package:transaction_record_app/screens/transaction/new_transaction_screen.dart';
import 'package:transaction_record_app/utility/constants.dart';
import 'package:transaction_record_app/utility/newColors.dart';
import 'package:transaction_record_app/utility/commons.dart';
import 'package:transaction_record_app/utility/components.dart';
import '../../helpers/navigation_helper.dart';

final transactCountProvider = StateProvider.autoDispose<int>((ref) => 10);
final hasMoreTransactsProvider = StateProvider.autoDispose<bool>((ref) => true);
final showElementsProvider = StateProvider.autoDispose<bool>((ref) => true);
final showMenuProvider = StateProvider.autoDispose<bool>((ref) => false);
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

class RegularBookScreen extends ConsumerStatefulWidget {
  final String bookId;
  final String bookType;
  final BookModel bookData;

  const RegularBookScreen({
    super.key,
    required this.bookId,
    required this.bookType,
    required this.bookData,
  });

  @override
  ConsumerState<RegularBookScreen> createState() => _BookUIState();
}

class _BookUIState extends ConsumerState<RegularBookScreen> {
  final ScrollController _scrollController = ScrollController();
  final searchKey = TextEditingController();
  String _selectedSortType = 'All';
  Timer? _debounce;
  final isLoading = ValueNotifier(false);
  final isFetching = ValueNotifier(false);

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
    try {
      final value = await FirebaseRefs.transactBookRef(widget.bookId).get();
      List<dynamic> groupMembers = [];
      groupMembers.addAll(value.data()!['users']);
      if (!groupMembers.contains(value.data()!['uid'])) {
        groupMembers.add(value.data()!['uid']);
      }

      Map<String, double> expenseMap = {
        for (var item in groupMembers) item: 0.0,
      };
      double totalExpense = (value.data()!['expense'] ?? 0).toDouble();

      final snapshot = await FirebaseRefs.transactsRef(widget.bookId).get();
      for (var element in snapshot.docs) {
        final transact = element.data();
        if (expenseMap.containsKey(transact['uid'])) {
          double amt = double.tryParse(transact['amount'].toString()) ?? 0;
          if (transact['type'] == "income") {
            expenseMap[transact['uid']] = expenseMap[transact['uid']]! + amt;
          } else {
            expenseMap[transact['uid']] = expenseMap[transact['uid']]! - amt;
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

      if (payGetUsers.isNotEmpty) {
        final usersSnapshot = await FirebaseRefs.userRef
            .where('uid', whereIn: payGetUsers)
            .get();
        for (var element in usersSnapshot.docs) {
          balanceSheetUsers[element.data()['uid']] = {
            'name': element.data()['name'],
            'imgUrl': element.data()['imgUrl'],
          };
        }
      }

      List<Map<String, dynamic>> balanceSheet = [];
      for (var i = 0; i < reciever.length; i++) {
        String recieverUid = reciever[i]['uid'];
        double recieverSpent = reciever[i]['amount'];

        for (var j = 0; j < payer.length; j++) {
          String payerUid = payer[j]['uid'];
          double payerPay = payer[j]['amount'];
          if (payerPay <= 0) continue;

          if (recieverSpent <= 0) break;

          double amountToPay = recieverSpent < payerPay
              ? recieverSpent
              : payerPay;
          balanceSheet.add({
            'payerUid': payerUid,
            'amount': amountToPay,
            'recieverUid': recieverUid,
          });
          recieverSpent -= amountToPay;
          payer[j]['amount'] -= amountToPay;
        }
      }

      if (context.mounted && balanceSheet.isNotEmpty) {
        showModalBottomSheet(
          context: context,
          elevation: 0,
          backgroundColor: Colors.transparent,
          builder: (context) => DistributeModal(
            balanceSheet: balanceSheet,
            balanceSheetUsers: balanceSheetUsers,
          ),
        );
      } else if (context.mounted) {
        KSnackbar(context, content: "No settlements needed");
      }
    } catch (e) {
      if (context.mounted) {
        KSnackbar(context, content: "Settlement failed: $e", isDanger: true);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchKey.removeListener(_onSearchChanged);
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    searchKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KBookHeader(
              title: widget.bookData.bookName,
              subtitle: DateFormat(
                "dd MMM, yyyy",
              ).format(DateTime.parse(widget.bookData.bookId)),
              actions: [
                KActionButton(
                  icon: Icons.edit_outlined,
                  onTap: () => showRenameBookModal(
                    context,
                    ref,
                    bookId: widget.bookData.bookId,
                    initialName: widget.bookData.bookName,
                  ),
                ),
                KActionButton(
                  icon: Icons.person_add_outlined,
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) =>
                        UserSelectorDialog(bookData: widget.bookData),
                  ),
                ),
                KActionButton(
                  icon: Icons.delete_outline,
                  color: context.lossColor,
                  onTap: () => _confirmDeleteBook(),
                ),
              ],
            ),
            _incomeExpenseTracker(),
            const SizedBox(height: 12),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navPush(
            context,
            NewTransactionScreen(
              bookId: widget.bookId,
              bookType: widget.bookType,
            ),
          );
        },
        backgroundColor: context.textColor,
        foregroundColor: context.scaffoldColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _confirmDeleteBook() {
    showDialog(
      context: context,
      builder: (context) => kAlertDialog(
        context,
        title: 'DELETE BOOK',
        subTitle:
            'Are you sure you want to delete "${widget.bookData.bookName}"?',
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                isLoading.value = true;
                await ref
                    .read(bookrepositories)
                    .deleteBook(bookId: widget.bookData.bookId);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  KSnackbar(context, content: "Delete failed", isDanger: true);
                }
              } finally {
                isLoading.value = false;
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.lossColor,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: const Text(
              'DELETE',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _incomeExpenseTracker() {
    return Consumer(
      builder: (context, ref, _) {
        final bookData = ref.watch(bookdataStream(widget.bookId));
        return bookData.when(
          data: (book) {
            final isVisible = ref.watch(showElementsProvider);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isVisible ? 1 : 0,
                      child: isVisible
                          ? Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: context.textColor,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "TOTAL BALANCE",
                                            style: TextStyle(
                                              color: context.scaffoldColor
                                                  .lighten(0.7),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                          height5,
                                          Builder(
                                            builder: (context) {
                                              final balance =
                                                  book.income - book.expense;
                                              final isNegative = balance < 0;
                                              return Text(
                                                "₹${kMoneyFormat(balance.abs())}",
                                                style: TextStyle(
                                                  color: isNegative
                                                      ? context.lossColor
                                                      : context.scaffoldColor,
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: -1,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          _iconAction(
                                            icon: Icons.groups_outlined,
                                            onTap: () => navPush(
                                              context,
                                              UsersScreen(
                                                users: book.users!,
                                                ownerUid: book.uid,
                                                bookId: book.bookId,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          _iconAction(
                                            icon: Icons.tune_outlined,
                                            onTap: () => _showFilterSheet(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: KStatBox(
                                        label: "INCOME",
                                        value: book.income,
                                        isPrimary: true,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: KStatBox(
                                        label: "EXPENSE",
                                        value: book.expense,
                                        isLoss: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Container(width: double.infinity),
                    ),
                  ),
                ],
              ),
            );
          },
          error: (error, stackTrace) => const SizedBox(),
          loading: () => const SizedBox(),
        );
      },
    );
  }

  Widget _iconAction({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: context.scaffoldColor.lighten(0.2)),
        ),
        child: Icon(icon, size: 20, color: context.scaffoldColor),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => FilterBottomSheet(setState),
    );
  }

  Widget DistributeModal({
    required List<dynamic> balanceSheet,
    required Map<String, dynamic> balanceSheetUsers,
  }) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.scaffoldColor,
          border: Border.all(color: context.textColor.lighten(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SETTLEMENT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 25),
            Flexible(
              child: ListView.separated(
                itemCount: balanceSheet.length,
                shrinkWrap: true,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final payer =
                      balanceSheetUsers[balanceSheet[index]['payerUid']];
                  final reciever =
                      balanceSheetUsers[balanceSheet[index]['recieverUid']];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.textColor.lighten(0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        _userItem(payer['name'], payer['imgUrl']),
                        const Spacer(),
                        Column(
                          children: [
                            Text(
                              "₹${balanceSheet[index]['amount'].toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(Icons.arrow_forward, size: 12),
                          ],
                        ),
                        const Spacer(),
                        _userItem(
                          reciever['name'],
                          reciever['imgUrl'],
                          isRight: true,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userItem(String name, String img, {bool isRight = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isRight) _squareAvatar(img),
        if (!isRight) width10,
        Text(
          name.split(" ").first.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        if (isRight) width10,
        if (isRight) _squareAvatar(img),
      ],
    );
  }

  Widget _squareAvatar(String img) {
    return Container(
      height: 24,
      width: 24,
      decoration: BoxDecoration(
        border: Border.all(color: context.textColor.lighten(0.1)),
      ),
      child: Image.network(img, fit: BoxFit.cover),
    );
  }

  Widget FilterBottomSheet(StateSetter setState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.scaffoldColor,
        border: Border.all(color: context.textColor.lighten(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FILTER TRANSACTIONS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: context.fadeTextColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _filterOption("All", setState),
              const SizedBox(width: 12),
              _filterOption("Income", setState),
              const SizedBox(width: 12),
              _filterOption("Expense", setState),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterOption(String label, StateSetter setState) {
    final isSelected = _selectedSortType == label;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSortType = label;
          });
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? context.textColor : Colors.transparent,
            border: Border.all(color: context.textColor.lighten(0.1)),
          ),
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isSelected ? context.scaffoldColor : context.textColor,
              letterSpacing: 1,
            ),
          ),
        ),
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

        return ListView.builder(
          controller: scrollController,
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index == items.length) {
              return isFetching
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : const SizedBox(height: 80);
            }

            final data = items[index];
            final bool isFirstInMonth =
                index == 0 ||
                getMonthStr(items[index - 1].date) != getMonthStr(data.date);
            final bool isFirstInDate =
                index == 0 || items[index - 1].date != data.date;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFirstInMonth)
                  KTransactMonthHeader(
                    month: getMonthStr(data.date),
                    date: data.date,
                  ),
                if (!isFirstInMonth && isFirstInDate)
                  KTransactDateHeader(date: data.date),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: KTransactTile(
                    data: data,
                    onTap: () =>
                        navPush(context, EditTransactionScreen(trData: data)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
