import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:transaction_record_app/Utility/KButton.dart';
import 'package:transaction_record_app/helpers/navigation_helper.dart';
import 'package:transaction_record_app/repositories/auth_repository.dart';
import 'package:transaction_record_app/repositories/book_repository.dart';
import 'package:transaction_record_app/screens/book/book_widgets/book_tile.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/components/common/k_scaffold.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/Utility/KLoading.dart';
import 'package:transaction_record_app/screens/account/account_screen.dart';
import 'package:transaction_record_app/screens/home/home_menu_widget.dart';
import '../../Utility/commons.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  final TextEditingController searchKey = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final isLoading = ValueNotifier(false);
  final showMenuProvider = StateProvider<bool>((ref) => false);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (ref.read(hasMoreBooksProvider) && !isLoading.value) {
        ref.read(bookCountProvider.notifier).state += 5;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchKey.dispose();
    super.dispose();
  }

  Future<void> _deleteBook({
    required String bookName,
    required String bookId,
  }) async {
    try {
      isLoading.value = true;
      final res = await ref.read(bookrepositories).deleteBook(bookId: bookId);
      if (res && context.mounted) {
        KSnackbar(context, content: "\"$bookName\" Book Deleted!");
      }
    } catch (e) {
      if (context.mounted) {
        KSnackbar(context, content: "Unable to delete book!", isDanger: true);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = ref.watch(userProvider);
    final showHomeMenu = ref.watch(showMenuProvider);

    if (user == null) return const SizedBox();

    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(APP_PADDING),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => navPush(context, const AccountScreen()),
                        child: Hero(
                          tag: 'profImg',
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: context.textColor,
                                width: 1.5,
                              ),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: user.imgUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  const Icon(LucideIcons.user),
                            ),
                          ),
                        ),
                      ),
                      width15,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'TRANSACT RECORD',
                              style: TextStyle(
                                fontSize: 10,
                                color: context.fadeTextColor,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            ref.read(showMenuProvider.notifier).state =
                                !showHomeMenu,
                        icon: Icon(
                          showHomeMenu ? LucideIcons.x : LucideIcons.menu,
                          color: context.textColor,
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: showHomeMenu
                        ? Home_Menu_Widget(isLoading: isLoading)
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: APP_PADDING),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KSearchBar(
                      context,
                      controller: searchKey,
                      onChanged: (val) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'FILTER BY TYPE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: context.fadeTextColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _filterRow(),
                    const SizedBox(height: 24),
                    _booksList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterRow() {
    final filters = ["All", "Regular", "Due", "Savings"];
    final selectedFilter = ref.watch(bookFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                ref.read(bookFilterProvider.notifier).state = filter;
                ref.read(bookCountProvider.notifier).state = 5;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? context.textColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? context.textColor
                        : context.textColor.lighten(0.1),
                  ),
                ),
                child: Text(
                  filter.toUpperCase(),
                  style: TextStyle(
                    color: isSelected
                        ? context.scaffoldColor
                        : context.textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _booksList() {
    final asyncData = ref.watch(bookListStream);
    final bookList = ref.watch(bookListProvider);
    final selectedFilter = ref.watch(bookFilterProvider);

    final filteredList = bookList.where((book) {
      bool matchesSearch =
          kCompare(searchKey.text, book.bookName) ||
          kCompare(searchKey.text, book.bookDescription);
      bool matchesFilter =
          selectedFilter == "All" ||
          book.type.toLowerCase() == selectedFilter.toLowerCase();
      return matchesSearch && matchesFilter;
    }).toList();

    if (asyncData.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                LucideIcons.cloudOff,
                size: 48,
                color: context.lossColor.lighten(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                "CONNECTION ERROR",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
              const SizedBox(height: 24),
              KButton.outline(
                context,
                onPressed: () => ref.invalidate(bookListStream),
                label: "RETRY",
              ),
            ],
          ),
        ),
      );
    }

    String lastDate = '';
    return Column(
      children: [
        if (filteredList.isEmpty && !asyncData.isLoading)
          kNoData(context, title: "No Books Found")
        else
          ListView.builder(
            itemCount: filteredList.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final book = filteredList[index];
              bool showDate = lastDate != book.date;
              if (showDate) lastDate = book.date;
              return BookTile(
                book: book,
                title: book.date,
                showDate: showDate,
                onDelete: (id, name) => _deleteBook(bookName: name, bookId: id),
              );
            },
          ),
        if (asyncData.isLoading)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: KLoading()),
          ),
      ],
    );
  }
}
