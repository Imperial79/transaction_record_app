import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/components/book/book_header.dart';
import 'package:transaction_record_app/components/common/action_button.dart';
import 'package:transaction_record_app/components/common/k_scaffold.dart';
import 'package:transaction_record_app/components/common/stat_box.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import 'package:transaction_record_app/screens/book/book_widgets/book_fab.dart';
import 'package:transaction_record_app/screens/book/book_widgets/book_transaction_list.dart';
import 'package:transaction_record_app/screens/book/book_widgets/book_utilities.dart';

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
  late BookScrollHelper _scrollHelper;

  @override
  void initState() {
    super.initState();
    _scrollHelper = BookScrollHelper(
      controller: _scrollController,
      showStatsProvider: showSavingsStatsProvider,
      countProvider: savingsBookCountProvider,
      ref: ref,
    );
    _scrollHelper.addListener();
  }

  @override
  void dispose() {
    _scrollHelper.removeListener();
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
                  icon: LucideIcons.pencil,
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
                          ? _statsWidget()
                          : const SizedBox(width: double.infinity),
                    ),
                    _sectionHeader("TRANSACTION HISTORY"),
                    BookTransactionList(
                      bookId: widget.bookData.bookId,
                      countProvider: savingsBookCountProvider,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: BookFAB(
        bookType: widget.bookData.type,
        bookId: widget.bookData.bookId,
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: APP_PADDING, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: context.fadeTextColor,
        ),
      ),
    );
  }

  Widget _statsWidget() {
    return Padding(
      padding: const EdgeInsets.all(APP_PADDING),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseRefs.transactBookRef(
          widget.bookData.bookId,
        ).snapshots(),
        builder: (context, snapshot) {
          double income = 0;
          if (snapshot.hasData && snapshot.data!.data() != null) {
            income = (snapshot.data!.data()!['income'] ?? 0).toDouble();
          }
          return KStatBox(
            label: "TOTAL ACCUMULATED",
            value: income,
            isCurrency: true,
            isPrimary: true,
          );
        },
      ),
    );
  }
}
