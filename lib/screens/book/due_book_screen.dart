import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/components/book/book_header.dart';
import 'package:transaction_record_app/components/common/stat_box.dart';
import 'package:transaction_record_app/components/common/widgets.dart';
import 'package:transaction_record_app/components/common/k_scaffold.dart';
import 'package:transaction_record_app/components/transaction/transact_list_header.dart';
import 'package:transaction_record_app/components/transaction/transact_tile.dart';
import 'package:transaction_record_app/components/book/user_selector_card.dart';
import 'package:transaction_record_app/components/common/action_button.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import 'package:transaction_record_app/models/transactModel.dart';
import 'package:transaction_record_app/repositories/auth_repository.dart';
import 'package:transaction_record_app/screens/transaction/edit_transaction_screen.dart';
import 'package:transaction_record_app/screens/transaction/new_transaction_screen.dart';
import 'package:transaction_record_app/utility/constants.dart';
import 'package:transaction_record_app/utility/newColors.dart';
import 'package:transaction_record_app/utility/commons.dart';
import 'package:transaction_record_app/utility/components.dart';
import '../../helpers/navigation_helper.dart';

final dueBookCountProvider = StateProvider.autoDispose<int>((ref) => 20);
final showDueStatsProvider = StateProvider.autoDispose<bool>((ref) => true);

class DueBookScreen extends ConsumerStatefulWidget {
  final BookModel bookData;
  const DueBookScreen({super.key, required this.bookData});

  @override
  ConsumerState<DueBookScreen> createState() => _DueBookScreenState();
}

class _DueBookScreenState extends ConsumerState<DueBookScreen> {
  final ScrollController _scrollController = ScrollController();
  final _newTargetAmount = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (ref.read(showDueStatsProvider)) {
        ref.read(showDueStatsProvider.notifier).state = false;
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!ref.read(showDueStatsProvider)) {
        ref.read(showDueStatsProvider.notifier).state = true;
      }
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(dueBookCountProvider.notifier).state += 10;
    }
  }

  void _setNewTarget(double currentTarget) async {
    _newTargetAmount.text = currentTarget.toString();
    showDialog(
      context: context,
      builder: (context) => kAlertDialog(
        context,
        title: "SET TARGET",
        subTitle: "Goal for this book",
        content: TextField(
          controller: _newTargetAmount,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: "₹ ",
            border: OutlineInputBorder(borderRadius: BorderRadius.zero),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection("transactBooks")
                    .doc(widget.bookData.bookId)
                    .update({
                      "targetAmount": double.parse(_newTargetAmount.text),
                    });
                KSnackbar(context, content: "Target updated!");
              } catch (e) {
                KSnackbar(context, content: "Update failed", isDanger: true);
              }
            },
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _newTargetAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showStats = ref.watch(showDueStatsProvider);
    return KScaffold(
      body: SafeArea(
        child: Column(
          children: [
            KBookHeader(
              title: widget.bookData.bookName,
              subtitle:
                  "DUE BOOK • ${DateFormat("dd MMM, yyyy").format(DateTime.parse(widget.bookData.bookId))}",
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
                          ? StreamBuilder<
                              DocumentSnapshot<Map<String, dynamic>>
                            >(
                              stream: FirebaseRefs.transactBookRef(
                                widget.bookData.bookId,
                              ).snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data!.data() == null) {
                                  return const SizedBox();
                                }
                                final data = BookModel.fromMap(
                                  snapshot.data!.data()!,
                                );
                                final amountPaid = data.income - data.expense;
                                final amountDue =
                                    data.targetAmount - data.income;
                                double percent = data.targetAmount != 0
                                    ? (amountPaid / data.targetAmount).clamp(
                                        0.0,
                                        1.0,
                                      )
                                    : 0.0;

                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: KStatBox(
                                              label: "TOTAL TARGET",
                                              value: data.targetAmount,
                                              isCurrency: true,
                                            ),
                                          ),
                                          width10,
                                          KActionButton(
                                            icon: Icons.adjust,
                                            onTap: () => _setNewTarget(
                                              data.targetAmount,
                                            ),
                                          ),
                                        ],
                                      ),
                                      height10,
                                      Row(
                                        children: [
                                          Expanded(
                                            child: KStatBox(
                                              label: "PAID",
                                              value: amountPaid,
                                              isCurrency: true,
                                              isPrimary: true,
                                            ),
                                          ),
                                          width10,
                                          Expanded(
                                            child: KStatBox(
                                              label: "DUE",
                                              value: amountDue,
                                              isCurrency: true,
                                              isLoss: amountDue > 0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (data.targetAmount > 0) ...[
                                        height20,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "PROGRESS: ${(percent * 100).toStringAsFixed(1)}%",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        height5,
                                        Container(
                                          height: 8,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: context.textColor.lighten(
                                                0.1,
                                              ),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              FractionallySizedBox(
                                                widthFactor: percent,
                                                child: Container(
                                                  color: context.primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            )
                          : Container(width: double.infinity),
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
    final count = ref.watch(dueBookCountProvider);
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
