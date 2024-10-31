import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import 'package:transaction_record_app/screens/Account%20Screen/accountUI.dart';
import 'package:transaction_record_app/screens/Book%20Screens/Book%20Tiles/Regular_Book_Tile.dart';
import 'package:transaction_record_app/screens/Home%20Screens/HomeMenu.dart';
import 'package:transaction_record_app/services/database.dart';
import '../../Functions/bookFunctions.dart';
import '../../Utility/commons.dart';
import '../../Utility/components.dart';

final ValueNotifier<bool> showAdd = ValueNotifier<bool>(true);

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
  final ValueNotifier<bool> _showAdd = ValueNotifier<bool>(true);

  bool isKeyboardOpen = false;
  bool isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    dateTitle = '';

    _scrollFunction();
  }

  _scrollFunction() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        _showAdd.value = false;
        showAdd.value = false;
      } else {
        _showAdd.value = true;
        showAdd.value = true;
      }
    });
  }

  _deleteBook({
    required String bookName,
    required String bookId,
  }) async {
    Navigator.pop(context);
    try {
      setState(() {
        isLoading = true;
      });

      await BookMethods.deleteBook(
        context,
        bookName: bookName,
        bookId: bookId,
      );

      KSnackbar(context, content: "\"$bookName\" Book Deleted!");
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
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _showAdd.value = searchKey.text.isEmpty;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);
    final showHomeMenu = ref.watch(showMenuProvider);
    if (user != null) {
      return KScaffold(
        isLoading: isLoading,
        body: SafeArea(
          bottom: false,
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
              AnimatedSize(
                reverseDuration: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.topCenter,
                curve: Curves.ease,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _showAdd,
                  builder: (BuildContext context, bool showFullAppBar,
                      Widget? child) {
                    return Container(
                      child: showFullAppBar
                          ? Column(
                              children: [
                                height10,
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                              child: user.imgUrl == ''
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Dark.profitCard,
                                                        strokeWidth: 1.5,
                                                      ),
                                                    )
                                                  : CachedNetworkImage(
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
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                            width5,
                                            Text(
                                              user.name.split(" ").first,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          ref
                                              .read(showMenuProvider.notifier)
                                              .state = !showHomeMenu;
                                        },
                                        borderRadius: kRadius(100),
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: isDark
                                              ? Dark.card
                                              : Colors.grey.shade200,
                                          child: Icon(
                                            showHomeMenu
                                                ? Icons
                                                    .keyboard_arrow_up_rounded
                                                : Icons
                                                    .keyboard_arrow_down_rounded,
                                            size: 20,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                height10,
                              ],
                            )
                          : Container(),
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  controller: _scrollController,
                  children: [
                    height10,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: KSearchBar(
                        context,
                        isDark: isDark,
                        controller: searchKey,
                        onChanged: (val) {
                          setState(() {
                            _showAdd.value = false;
                          });
                        },
                      ),
                    ),
                    height15,
                    _booksList(isDark, uid: user.uid),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox();
  }

  Widget _booksList(bool isDark, {required String uid}) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('transactBooks')
          .where(
            Filter.or(
              Filter(
                'users',
                arrayContains: uid,
              ),
              Filter('uid', isEqualTo: uid),
            ),
          )
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        dateTitle = '';
        return (snapshot.hasData)
            ? (snapshot.data!.docs.isEmpty)
                ? NewBookCard(context)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        searchKey.text.isEmpty
                            ? Center(
                                child: Text(
                                  'RECENT BOOKS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    letterSpacing: 7,
                                    color:
                                        isDark ? Dark.fadeText : Light.fadeText,
                                  ),
                                ),
                              )
                            : Text(
                                'Searching for "${searchKey.text}"',
                                style: TextStyle(
                                  color:
                                      isDark ? Dark.fadeText : Light.fadeText,
                                ),
                              ),
                        height10,
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            BookModel book = BookModel.fromMap(
                                snapshot.data!.docs[index].data());
                            if (dateTitle == book.date) {
                              showDateWidget = false;
                            } else {
                              dateTitle = book.date;
                              showDateWidget = true;
                            }
                            if (kCompare(searchKey.text, book.bookName)) {
                              return BookTile(
                                book: book,
                                title: dateTitle,
                                showDate: showDateWidget,
                                onDelete: (bookId, bookName) {
                                  _deleteBook(
                                    bookName: bookName,
                                    bookId: bookId,
                                  );
                                },
                              );
                            }

                            return SizedBox();
                          },
                        ),
                      ],
                    ),
                  )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                  ),
                ),
              );
      },
    );
  }
}
