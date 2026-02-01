// ignore_for_file: unused_result

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:transaction_record_app/Helper/navigatorFns.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Repository/book_repository.dart';
import 'package:transaction_record_app/Utility/CustomLoading.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/screens/Account%20Screen/accountUI.dart';
import 'package:transaction_record_app/screens/Book%20Screens/Book%20Widgets/Book_Tile.dart';
import 'package:transaction_record_app/screens/Home%20Screens/HomeMenu.dart';
import 'package:transaction_record_app/services/database.dart';
import '../../Utility/commons.dart';
import '../../Utility/components.dart';
import '../../models/bookModel.dart';

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

  final searchKey = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final showMenuProvider = StateProvider<bool>((ref) => false);

  bool isKeyboardOpen = false;
  final isLoading = ValueNotifier(false);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final hasMore = ref.read(hasMoreBooksProvider);
      if (hasMore && !isLoading.value) {
        // Simple debounce: only increment if we aren't already loading something elsewhere
        // (In a more complex app, we'd use a dedicated 'isPaginationLoading' state)
        ref.read(bookCountProvider.notifier).state += 5;
      }
    }
  }

  Future<void> _deleteBook({
    required String bookName,
    required String bookId,
  }) async {
    try {
      isLoading.value = true;

      final res = await ref.read(bookRepository).deleteBook(bookId: bookId);
      if (res) {
        KSnackbar(context, content: "\"$bookName\" Book Deleted!");
      }
    } catch (e) {
      KSnackbar(
        context,
        content:
            "Unable to delete book! Check your connection or try again later.",
        isDanger: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = ref.watch(userProvider);
    final showHomeMenu = ref.watch(showMenuProvider);
    if (user != null) {
      return KScaffold(
        isLoading: isLoading,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
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
                    child: showHomeMenu
                        ? HomeMenuUI(isLoading: isLoading)
                        : Container(),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => navPush(context, const AccountUI()),
                      child: Hero(
                        tag: 'profImg',
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.profitColor,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: CachedNetworkImageProvider(
                              user.imgUrl,
                            ),
                          ),
                        ),
                      ),
                    ),
                    width12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Day,',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.fadeTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            user.name.split(" ").first,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => ref.read(showMenuProvider.notifier).state =
                          !showHomeMenu,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.fadeTextColor.withAlpha(20),
                          ),
                        ),
                        child: Icon(
                          showHomeMenu
                              ? Icons.close_rounded
                              : Icons.grid_view_rounded,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                height20,
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.only(bottom: 50),
                    child: Column(
                      children: [
                        // Summary Card
                        _buildSummarySection(ref.watch(bookListProvider)),
                        height20,
                        KSearchBar(
                          context,
                          controller: searchKey,
                          onChanged: (val) {
                            setState(() {});
                          },
                        ),
                        height15,
                        _filterRow(),
                        height10,
                        _booksList(context.isDarkMode, uid: user.uid),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SizedBox();
  }

  Widget _buildSummarySection(List<BookModel> books) {
    double totalNet = books.fold(
      0.0,
      (sum, book) => sum + (book.income - book.expense),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kColor(context).secondaryContainer,
            kColor(context).secondaryContainer.withAlpha(300),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Overall Balance",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "₹ ${kMoneyFormat(totalNet)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _summaryMiniItem(
                label: "Books",
                value: "${books.length}",
                icon: Icons.auto_stories_rounded,
              ),
              const Spacer(),
              _summaryMiniItem(
                label: "Regular",
                value: "${books.where((b) => b.type == 'regular').length}",
                icon: Icons.receipt_long_rounded,
              ),
              const Spacer(),
              _summaryMiniItem(
                label: "Due",
                value: "${books.where((b) => b.type == 'due').length}",
                icon: Icons.assignment_late_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryMiniItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white60),
        width5,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _filterRow() {
    final filters = ["All", "Regular", "Due", "Savings"];
    final selectedFilter = ref.watch(bookFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: filters.map((filter) {
          bool isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                ref.read(bookFilterProvider.notifier).state = filter;
                ref.read(bookCountProvider.notifier).state = 5;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? kColor(context).primary
                      : context.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? context.primaryColor
                        : context.fadeTextColor.withAlpha(30),
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected
                        ? kColor(context).onPrimary
                        : context.fadeTextColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _booksList(bool isDark, {required String uid}) {
    return Consumer(
      builder: (context, ref, child) {
        final asyncData = ref.watch(bookListStream);
        final bookList = ref.watch(bookListProvider);

        // Filter the list locally for search only
        final filteredList = bookList.where((book) {
          bool matchesSearch =
              kCompare(searchKey.text, book.bookName) ||
              kCompare(searchKey.text, book.bookDescription);
          return matchesSearch;
        }).toList();

        // Reset dateTitle for each build to ensure headers are correct in the filtered list
        String lastDate = '';

        return Column(
          children: [
            ListView.builder(
              itemCount: filteredList.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                BookModel book = filteredList[index];
                bool showDate = false;
                if (lastDate != book.date) {
                  showDate = true;
                  lastDate = book.date;
                }

                return BookTile(
                  book: book,
                  title: book.date,
                  showDate: showDate,
                  onDelete: (id, name) {
                    _deleteBook(bookName: name, bookId: id);
                  },
                );
              },
            ),
            kHeight(30),
            if (asyncData.isLoading) Center(child: const CustomLoading()),
          ],
        );
      },
    );
  }
}
