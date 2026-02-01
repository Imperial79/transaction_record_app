import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Components/WIdgets.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/components.dart';
import '../../Helper/navigatorFns.dart';
import '../../Utility/commons.dart';
import '../../Utility/constants.dart';
import '../../Utility/newColors.dart';
import '../../models/bookModel.dart';
import '../../models/transactModel.dart';
import '../../services/database.dart';
import '../Transact Screens/edit_transactUI.dart';
import '../Transact Screens/New_Transact_UI.dart';

class Savings_Book_UI extends ConsumerStatefulWidget {
  final BookModel bookData;
  const Savings_Book_UI({super.key, required this.bookData});

  @override
  ConsumerState<Savings_Book_UI> createState() => _Due_Book_UIState(bookData);
}

class _Due_Book_UIState extends ConsumerState<Savings_Book_UI> {
  final BookModel bookData;
  _Due_Book_UIState(this.bookData);

  String dateTitle = '';
  bool showDateWidget = false;
  final ValueNotifier<int> bookListCounter = ValueNotifier<int>(20);

  final oCcy = NumberFormat("#,##0.00", "en_US");

  var items = ['All', 'Income', 'Expense'];
  final _newTargetAmount = TextEditingController();

  int searchingBookListCounter = 50;
  final isLoading = ValueNotifier(false);
  final isFetching = ValueNotifier(false);
  bool isSearching = false;
  final ScrollController _scrollController = ScrollController();
  bool _hasMore = true;

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
                decoration: BoxDecoration(
                  borderRadius: kRadius(10),
                  color: context.cardColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    kBackButton(context),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.delete_outline,
                        color: context.lossCardColor,
                      ),
                    ),
                  ],
                ),
              ),
              height10,
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "SAVINGS BOOK",
                      style: TextStyle(
                        letterSpacing: 5,
                        fontSize: 12,
                        color: context.fadeTextColor,
                      ),
                    ),
                    width10,
                    Text(
                      DateFormat(
                        "dd MMM, yyyy [hh:mm a]",
                      ).format(DateTime.parse(bookData.bookId)),
                      style: TextStyle(
                        letterSpacing: 1.2,
                        fontSize: 12,
                        color: context.fadeTextColor,
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
                  if (snapshot.hasData) {
                    final data = BookModel.fromMap(snapshot.data!.data()!);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        height10,
                        Text(
                          data.bookName,
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text("Accumulated"),
                        Text(
                          "INR ${kMoneyFormat(data.income)}",
                          style: TextStyle(
                            fontSize: 25,
                            color: context.profitColor,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
              height20,
              _transactList(context.isDarkMode, bookId: bookData.bookId),
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

  Widget _transactList(bool isDark, {required String bookId}) {
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
                        ? ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              Transact transact = Transact.fromMap(
                                snapshot.data!.docs[index].data(),
                              );

                              final bool showDate =
                                  index == 0 ||
                                  Transact.fromMap(
                                        snapshot.data!.docs[index - 1].data(),
                                      ).date !=
                                      transact.date;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (showDate) _buildDateHeader(transact.date),
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final user = ref.watch(userProvider);
                                      return TransactTile(
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
                                      );
                                    },
                                  ),
                                ],
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
}
