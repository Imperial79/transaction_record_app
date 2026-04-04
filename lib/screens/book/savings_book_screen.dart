import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/components/book/book_header.dart';
import 'package:transaction_record_app/components/common/action_button.dart';
import 'package:transaction_record_app/components/common/stat_box.dart';
import 'package:transaction_record_app/components/common/k_scaffold.dart';
import 'package:transaction_record_app/components/transaction/transact_list_header.dart';
import 'package:transaction_record_app/components/transaction/transact_tile.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import 'package:transaction_record_app/models/transactModel.dart';
import 'package:transaction_record_app/repositories/auth_repository.dart';
import 'package:transaction_record_app/screens/transaction/edit_transaction_screen.dart';
import 'package:transaction_record_app/screens/transaction/new_transaction_screen.dart';
import 'package:transaction_record_app/utility/commons.dart';
import 'package:transaction_record_app/utility/components.dart';
import 'package:transaction_record_app/utility/constants.dart';
import 'package:transaction_record_app/utility/newColors.dart';
import '../../helpers/navigation_helper.dart';

final savingsBookCountProvider = StateProvider.autoDispose<int>((ref) => 20);
final showSavingsStatsProvider = StateProvider.autoDispose<bool>((ref) => true);

class SavingsBookScreen extends ConsumerStatefulWidget {
  final BookModel bookData;
  const SavingsBookScreen({super.key, required this.bookData});

  @override
  ConsumerState<SavingsBookScreen> createState() => _SavingsBookScreenState();
}

class _SavingsBookScreenState extends ConsumerState<SavingsBookScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (ref.read(showSavingsStatsProvider)) {
        ref.read(showSavingsStatsProvider.notifier).state = false;
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!ref.read(showSavingsStatsProvider)) {
        ref.read(showSavingsStatsProvider.notifier).state = true;
      }
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(savingsBookCountProvider.notifier).state += 10;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showStats = ref.watch(showSavingsStatsProvider);

    return KScaffold(
      body: SafeArea(
        child: Column(
          children: [
            KBookHeader(
              title: widget.bookData.bookName,
              subtitle:
                  "SAVINGS BOOK • ${DateFormat("dd MMM, yyyy").format(DateTime.parse(widget.bookData.bookId))}",
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
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: showStats
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child:
                                  StreamBuilder<
                                    DocumentSnapshot<Map<String, dynamic>>
                                  >(
                                    stream: FirebaseRefs.transactBookRef(
                                      widget.bookData.bookId,
                                    ).snapshots(),
                                    builder: (context, snapshot) {
                                      double income = 0;
                                      if (snapshot.hasData &&
                                          snapshot.data!.data() != null) {
                                        income =
                                            (snapshot.data!.data()!['income'] ??
                                                    0)
                                                .toDouble();
                                      }
                                      return KStatBox(
                                        label: "TOTAL ACCUMULATED",
                                        value: income,
                                        isCurrency: true,
                                        isPrimary: true,
                                      );
                                    },
                                  ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        "TRANSACTION HISTORY",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: context.fadeTextColor,
                        ),
                      ),
                    ),
                    _TransactList(bookId: widget.bookData.bookId),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navPush(
          context,
          NewTransactionScreen(
            bookType: widget.bookData.type,
            bookId: widget.bookData.bookId,
          ),
        ),
        backgroundColor: context.textColor,
        foregroundColor: context.scaffoldColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TransactList extends ConsumerWidget {
  final String bookId;
  const _TransactList({required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(savingsBookCountProvider);
    final user = ref.watch(userProvider);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('transactBooks')
          .doc(bookId)
          .collection('transacts')
          .orderBy('ts', descending: true)
          .limit(count)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        if (snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: kNoData(context, title: "No Transactions"),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = Transact.fromMap(snapshot.data!.docs[index].data());

            final prevData = index > 0
                ? Transact.fromMap(snapshot.data!.docs[index - 1].data())
                : null;

            final bool isFirstInMonth =
                index == 0 ||
                DateFormat.yMMMM().format(DateTime.parse(data.ts)) !=
                    DateFormat.yMMMM().format(DateTime.parse(prevData!.ts));

            final bool isFirstInDate =
                index == 0 || data.date != prevData!.date;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFirstInMonth)
                  KTransactMonthHeader(
                    month: DateFormat.yMMMM().format(DateTime.parse(data.ts)),
                    date: data.date,
                  ),
                if (!isFirstInMonth && isFirstInDate)
                  KTransactDateHeader(date: data.date),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: KTransactTile(
                    data: data,
                    onTap: () {
                      if (data.uid == user?.uid) {
                        navPush(context, EditTransactionScreen(trData: data));
                      } else {
                        KSnackbar(
                          context,
                          content: "You cannot edit other's transactions",
                          isDanger: true,
                        );
                      }
                    },
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
