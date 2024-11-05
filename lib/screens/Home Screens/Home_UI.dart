// ignore_for_file: unused_result

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Repository/book_repository.dart';
import 'package:transaction_record_app/Utility/CustomLoading.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/screens/Account%20Screen/accountUI.dart';
import 'package:transaction_record_app/screens/Book%20Screens/components/Book_Tile.dart';
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
  bool isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(scrollListener);
  }

  scrollListener() {
    if (_scrollController.position.atEdge) {
      bool isBottom = _scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent;
      if (isBottom) {
        ref.read(bookCountProvider.notifier).state += 5;
        ref.refresh(bookListStream.future);
      }
    }
  }

  _deleteBook({
    required String bookName,
    required String bookId,
  }) async {
    try {
      setState(() {
        isLoading = true;
      });

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
      setState(() {
        isLoading = false;
      });
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
    bool isDark = Theme.of(context).brightness == Brightness.dark;
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
                    child: showHomeMenu ? const HomeMenuUI() : Container(),
                  ),
                ),
                // AnimatedSize(
                //   reverseDuration: const Duration(milliseconds: 300),
                //   duration: const Duration(milliseconds: 300),
                //   alignment: Alignment.topCenter,
                //   curve: Curves.ease,
                //   child: ValueListenableBuilder<bool>(
                //     valueListenable: _showAdd,
                //     builder: (BuildContext context, bool showFullAppBar,
                //         Widget? child) {
                //       return Container(
                //         padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                //         child: showFullAppBar
                //             ? Row(
                //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                 children: [
                //                   GestureDetector(
                //                     onTap: () {
                //                       navPush(context, const AccountUI());
                //                     },
                //                     child: Hero(
                //                       tag: 'profImg',
                //                       child: CircleAvatar(
                //                         radius: 12,
                //                         child: ClipRRect(
                //                           borderRadius: kRadius(50),
                //                           child: user.imgUrl == ''
                //                               ? const Center(
                //                                   child:
                //                                       CircularProgressIndicator(
                //                                     color: Dark.profitCard,
                //                                     strokeWidth: 1.5,
                //                                   ),
                //                                 )
                //                               : CachedNetworkImage(
                //                                   imageUrl: user.imgUrl,
                //                                   fit: BoxFit.cover,
                //                                 ),
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                   width10,
                //                   Expanded(
                //                     child: Row(
                //                       children: [
                //                         Text(
                //                           'Hi,',
                //                           style: TextStyle(
                //                             fontSize: 20,
                //                             fontWeight: FontWeight.w400,
                //                             color: isDark
                //                                 ? Colors.white
                //                                 : Colors.black,
                //                           ),
                //                         ),
                //                         width5,
                //                         Text(
                //                           user.name.split(" ").first,
                //                           style: TextStyle(
                //                             fontSize: 20,
                //                             fontWeight: FontWeight.w600,
                //                             color: isDark
                //                                 ? Colors.white
                //                                 : Colors.black,
                //                           ),
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //                   InkWell(
                //                     onTap: () {
                //                       ref.read(showMenuProvider.notifier).state =
                //                           !showHomeMenu;
                //                     },
                //                     borderRadius: kRadius(100),
                //                     child: CircleAvatar(
                //                       radius: 20,
                //                       backgroundColor: isDark
                //                           ? Dark.card
                //                           : Colors.grey.shade200,
                //                       child: Icon(
                //                         showHomeMenu
                //                             ? Icons.keyboard_arrow_up_rounded
                //                             : Icons.keyboard_arrow_down_rounded,
                //                         size: 20,
                //                         color:
                //                             isDark ? Colors.white : Colors.black,
                //                       ),
                //                     ),
                //                   ),
                //                 ],
                //               )
                //             : Container(),
                //       );
                //     },
                //   ),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        navPush(context, const AccountUI());
                      },
                      child: Hero(
                        tag: 'profImg',
                        child: CircleAvatar(
                          radius: 12,
                          child: ClipRRect(
                            borderRadius: kRadius(50),
                            child: CachedNetworkImage(
                              imageUrl: user.imgUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    width10,
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'Hi,',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          width5,
                          Text(
                            user.name.split(" ").first,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ref.read(showMenuProvider.notifier).state =
                            !showHomeMenu;
                      },
                      borderRadius: kRadius(100),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            isDark ? Dark.card : Colors.grey.shade200,
                        child: Icon(
                          showHomeMenu
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                height15,
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.only(bottom: 50),
                    child: Column(
                      children: [
                        KSearchBar(
                          context,
                          isDark: isDark,
                          controller: searchKey,
                          onChanged: (val) {
                            setState(() {});
                          },
                        ),
                        height10,
                        _booksList(isDark, uid: user.uid),
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

  Widget _booksList(bool isDark, {required String uid}) {
    return Consumer(
      builder: (context, ref, child) {
        final asyncData = ref.watch(bookListStream);
        final bookList = ref.watch(bookListProvider);

        return Column(
          children: [
            ListView.builder(
              itemCount: bookList.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                BookModel book = bookList[index];
                if (dateTitle == book.date) {
                  showDateWidget = false;
                } else {
                  dateTitle = book.date;
                  showDateWidget = true;
                }
                if (kCompare(searchKey.text, book.bookName) ||
                    kCompare(searchKey.text, book.bookDescription)) {
                  return BookTile(
                    book: book,
                    title: dateTitle,
                    showDate: showDateWidget,
                    onDelete: (id, name) {
                      _deleteBook(bookName: name, bookId: id);
                    },
                  );
                }
                return const SizedBox();
              },
            ),
            kHeight(30),
            if (asyncData.isLoading)
              Center(
                child: const CustomLoading(),
              ),
          ],
        );
      },
    );
  }
}
