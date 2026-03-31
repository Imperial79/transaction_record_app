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
import 'package:transaction_record_app/screens/Home%20Screens/Home_Menu_Widget.dart';
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
                        ? Home_Menu_Widget(isLoading: isLoading)
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
                        // _buildSummarySection(ref.watch(bookListProvider)),
                        // height20,
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
        final selectedFilter = ref.watch(bookFilterProvider);

        // Filter the list locally for search and category
        final filteredList = bookList.where((book) {
          bool matchesSearch =
              kCompare(searchKey.text, book.bookName) ||
              kCompare(searchKey.text, book.bookDescription);

          bool matchesFilter =
              selectedFilter == "All" ||
              book.type.toLowerCase() == selectedFilter.toLowerCase();

          return matchesSearch && matchesFilter;
        }).toList();

        // Check if we have an error (e.g., missing Firestore index or no internet)
        if (asyncData.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    color: context.lossColor.withAlpha(150),
                    size: 60,
                  ),
                  height15,
                  Text(
                    "Connection Error",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                  height10,
                  Text(
                    "Unable to reach the server. Please check your internet connection.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.fadeTextColor),
                  ),
                  height20,
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.invalidate(bookListStream);
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text("Retry Now"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Reset dateTitle for each build to ensure headers are correct in the filtered list
        String lastDate = '';

        return Column(
          children: [
            if (filteredList.isEmpty && !asyncData.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      size: 64,
                      color: context.fadeTextColor.withAlpha(50),
                    ),
                    height15,
                    Text(
                      "No books found",
                      style: TextStyle(
                        color: context.fadeTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
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
            if (asyncData.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CustomLoading()),
              ),
          ],
        );
      },
    );
  }
}
