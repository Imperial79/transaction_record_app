import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Utility/KButton.dart';
import 'package:transaction_record_app/Utility/commons.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/components/book/book_header.dart';
import 'package:transaction_record_app/components/common/action_button.dart';
import 'package:transaction_record_app/components/common/k_scaffold.dart';
import 'package:transaction_record_app/components/common/stat_box.dart';
import 'package:transaction_record_app/components/common/widgets.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import 'package:transaction_record_app/repositories/book_repository.dart';
import 'package:transaction_record_app/screens/book/book_widgets/book_fab.dart';
import 'package:transaction_record_app/screens/book/book_widgets/book_transaction_list.dart';
import 'package:transaction_record_app/screens/book/book_widgets/book_utilities.dart';
import 'package:transaction_record_app/screens/book/users_screen.dart';
import 'package:transaction_record_app/helpers/navigation_helper.dart';

final transactCountProvider = StateProvider.autoDispose<int>((ref) => 15);
final hasMoreTransactsProvider = StateProvider.autoDispose<bool>((ref) => true);
final showStatsProvider = StateProvider.autoDispose<bool>((ref) => true);
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

class RegularBookScreen extends ConsumerStatefulWidget {
  final BookModel bookData;
  const RegularBookScreen({super.key, required this.bookData});

  @override
  ConsumerState<RegularBookScreen> createState() => _RegularBookScreenState();
}

class _RegularBookScreenState extends ConsumerState<RegularBookScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchKey = TextEditingController();
  late BookScrollHelper _scrollHelper;

  @override
  void initState() {
    super.initState();
    _scrollHelper = BookScrollHelper(
      controller: _scrollController,
      showStatsProvider: showStatsProvider,
      countProvider: transactCountProvider,
      ref: ref,
    );
    _scrollHelper.addListener();
  }

  @override
  void dispose() {
    _scrollHelper.removeListener();
    _scrollController.dispose();
    _searchKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showStats = ref.watch(showStatsProvider);
    final searchVal = ref.watch(searchQueryProvider);

    return KScaffold(
      body: SafeArea(
        child: Column(
          children: [
            KBookHeader(
              title: widget.bookData.bookName,
              subtitle:
                  "REGULAR BOOK • ${DateFormat("dd MMM, yyyy").format(DateTime.parse(widget.bookData.bookId))}",
              actions: [
                KActionButton(
                  icon: LucideIcons.userPlus,
                  onTap: () => navPush(
                    context,
                    UsersScreen(
                      bookId: widget.bookData.bookId,
                      bookName: widget.bookData.bookName,
                      users: widget.bookData.users ?? [],
                      ownerUid: widget.bookData.uid,
                    ),
                  ),
                ),
                KActionButton(
                  icon: LucideIcons.pencil,
                  onTap: () => showRenameBookModal(
                    context,
                    ref,
                    bookId: widget.bookData.bookId,
                    initialName: widget.bookData.bookName,
                  ),
                ),
                KActionButton(
                  icon: LucideIcons.trash2,
                  color: context.lossColor,
                  onTap: () => _confirmDelete(context),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: showStats
                  ? _statsWidget()
                  : const SizedBox(width: double.infinity),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        APP_PADDING,
                        8,
                        APP_PADDING,
                        24,
                      ),
                      child: KSearchBar(
                        context,
                        controller: _searchKey,
                        onChanged: (val) =>
                            ref.read(searchQueryProvider.notifier).state = val,
                      ),
                    ),
                    _sectionHeader("TRANSACTIONS"),
                    BookTransactionList(
                      bookId: widget.bookData.bookId,
                      countProvider: transactCountProvider,
                      searchQuery: searchVal,
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
          double expense = 0;
          if (snapshot.hasData && snapshot.data!.data() != null) {
            income = (snapshot.data!.data()!['income'] ?? 0).toDouble();
            expense = (snapshot.data!.data()!['expense'] ?? 0).toDouble();
          }
          final balance = income - expense;
          return Column(
            children: [
              KStatBox(
                width: double.infinity,
                label: "BALANCE",
                value: balance,
                isCurrency: true,
                isPrimary: balance >= 0,
                isLoss: balance < 0,
              ),
              height10,
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: KStatBox(
                      label: "INCOME",
                      value: income,
                      isCurrency: true,
                      small: true,
                    ),
                  ),

                  Expanded(
                    child: KStatBox(
                      label: "EXPENSE",
                      value: expense,
                      isCurrency: true,
                      isLoss: true,
                      small: true,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    kAlertDialog(
      context,
      title: "DELETE BOOK",
      subTitle:
          "ARE YOU SURE YOU WANT TO DELETE THIS BOOK? THIS ACTION CANNOT BE UNDONE.",
      actions: [
        KButton.text(
          context,
          onTap: () => Navigator.pop(context),
          label: "CANCEL",
        ),
        KButton.themed(
          context,
          onPressed: () async {
            await ref
                .read(bookrepositories)
                .deleteBook(bookId: widget.bookData.bookId);
            if (context.mounted) {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back from screen
            }
          },
          label: "DELETE",
          color: context.lossColor,
        ),
      ],
    );
  }
}
