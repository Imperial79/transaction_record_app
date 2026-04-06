import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Utility/KLoading.dart';
import 'package:transaction_record_app/Utility/commons.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/components/transaction/transact_list_header.dart';
import 'package:transaction_record_app/components/transaction/transact_tile.dart';
import 'package:transaction_record_app/helpers/navigation_helper.dart';
import 'package:transaction_record_app/models/transactModel.dart';
import 'package:transaction_record_app/repositories/auth_repository.dart';
import 'package:transaction_record_app/screens/transaction/edit_transaction_screen.dart';

class BookTransactionList extends ConsumerWidget {
  final String bookId;
  final StateProvider<int> countProvider;
  final String? searchQuery;
  final ScrollController? scrollController;
  final bool isFetching;

  const BookTransactionList({
    super.key,
    required this.bookId,
    required this.countProvider,
    this.searchQuery,
    this.scrollController,
    this.isFetching = false,
  });

  String _getMonthStr(String date, String ts) {
    try {
      // Try parsing the timestamp first for more accurate month grouping
      return DateFormat.yMMMM().format(DateTime.parse(ts));
    } catch (e) {
      try {
        // Fallback to date string parsing
        return DateFormat.yMMMM().format(DateFormat.yMMMMd().parse(date));
      } catch (e) {
        return "";
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(countProvider);
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
        if (!snapshot.hasData) return const SizedBox.shrink();

        var docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: kNoData(context, title: "No Transactions Found"),
          );
        }

        final items = docs.map((doc) => Transact.fromMap(doc.data())).where((
          item,
        ) {
          if (searchQuery == null || searchQuery!.isEmpty) return true;
          return kCompare(searchQuery!, item.description) ||
              kCompare(searchQuery!, item.amount.toString());
        }).toList();

        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: kNoData(context, title: "No Matching Transactions"),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: scrollController == null
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          controller: scrollController,
          itemCount: items.length + (scrollController != null ? 1 : 0),
          itemBuilder: (context, index) {
            if (scrollController != null && index == items.length) {
              return isFetching
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: KLoading()),
                    )
                  : const SizedBox(height: 80);
            }

            final data = items[index];
            final prevData = index > 0 ? items[index - 1] : null;

            final String currentMonth = _getMonthStr(data.date, data.ts);
            final String prevMonth = prevData != null
                ? _getMonthStr(prevData.date, prevData.ts)
                : "";

            final bool isFirstInMonth = index == 0 || currentMonth != prevMonth;
            final bool isFirstInDate =
                index == 0 || data.date != prevData?.date;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFirstInMonth)
                  KTransactMonthHeader(month: currentMonth, date: data.date),
                if (!isFirstInMonth && isFirstInDate)
                  KTransactDateHeader(date: data.date),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: APP_PADDING),
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
