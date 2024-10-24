import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Components/WIdgets.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import '../../Functions/navigatorFns.dart';
import '../../Utility/commons.dart';
import '../../Utility/constants.dart';
import '../../Utility/newColors.dart';
import '../../models/transactModel.dart';
import '../../services/database.dart';
import '../Transact Screens/edit_transactUI.dart';
import '../Transact Screens/New_Transact_UI.dart';

class Savings_Book_UI extends ConsumerStatefulWidget {
  final BookModel bookData;
  const Savings_Book_UI({super.key, required this.bookData});

  @override
  ConsumerState<Savings_Book_UI> createState() => _Due_Book_UIState(bookData);
}

class _Due_Book_UIState extends ConsumerState<Savings_Book_UI> {
  final BookModel bookData;
  _Due_Book_UIState(this.bookData);

  String dateTitle = '';
  bool showDateWidget = false;
  final ValueNotifier<int> bookListCounter = ValueNotifier<int>(20);

  final oCcy = NumberFormat("#,##0.00", "en_US");

  var items = ['All', 'Income', 'Expense'];
  final _newTargetAmount = TextEditingController();

  int searchingBookListCounter = 50;
  bool isLoading = false;
  bool isSearching = false;

  @override
  void dispose() {
    _newTargetAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: kRadius(10),
                  color: isDark ? Dark.card : Light.card,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    kBackButton(context),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.delete_outline,
                        color: isDark ? Dark.lossCard : Light.lossCard,
                      ),
                    ),
                  ],
                ),
              ),
              height10,
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "SAVINGS BOOK",
                      style: TextStyle(
                        letterSpacing: 5,
                        fontSize: 12,
                        color: isDark ? Dark.fadeText : Light.fadeText,
                      ),
                    ),
                    width10,
                    Text(
                      DateFormat("dd MMM, yyyy [hh:mm a]").format(
                        DateTime.parse(bookData.bookId),
                      ),
                      style: TextStyle(
                        letterSpacing: 1.2,
                        fontSize: 12,
                        color: isDark ? Dark.fadeText : Light.fadeText,
                      ),
                    ),
                  ],
                ),
              ),
              height20,
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream:
                    FirebaseRefs.transactBookRef(bookData.bookId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = BookModel.fromMap(snapshot.data!.data()!);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        height10,
                        Text(
                          data.bookName,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text("Accumulated"),
                        Text(
                          "INR ${kMoneyFormat(data.income)}",
                          style: TextStyle(
                            fontSize: 25,
                            color: isDark ? Dark.profitText : Light.profitText,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
              height20,
              _transactList(isDark, bookId: bookData.bookId),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navPush(
            context,
            New_Transact_UI(
              bookType: bookData.type,
              bookId: bookData.bookId,
            ),
          );
        },
        elevation: 0,
        highlightElevation: 0,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _transactList(bool isDark, {required String bookId}) {
    dateTitle = '';
    return ValueListenableBuilder(
      valueListenable: bookListCounter,
      builder: (context, int bookCount, child) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: firestore
              .collection('transactBooks')
              .doc(bookId)
              .collection('transacts')
              .orderBy('ts', descending: true)
              .limit(bookCount)
              .snapshots(),
          builder: (context, snapshot) {
            dateTitle = '';

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: snapshot.hasData
                  ? snapshot.data!.docs.isNotEmpty
                      ? ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            Transact transact = Transact.fromMap(
                                snapshot.data!.docs[index].data());

                            return _transactTile(isDark, data: transact);
                          },
                        )
                      : Text(
                          'No Transacts',
                          style: TextStyle(
                            fontSize: 30,
                            color: isDark ? Dark.fadeText : Light.fadeText,
                          ),
                        )
                  : DummyTransactList(isDark),
            );
          },
        );
      },
    );
  }

  Widget _transactTile(bool isDark, {required Transact data}) {
    bool isIncome = data.type == 'Income';
    String dateLabel = '';
    var todayDate = DateFormat.yMMMMd().format(DateTime.now());
    if (dateTitle == data.date) {
      showDateWidget = false;
    } else {
      dateTitle = data.date;
      showDateWidget = true;
    }
    String ts = DateFormat("yMMMMd").parse(data.date).toString();

    if (dateTitle == todayDate) {
      dateLabel = 'Today';
    } else if (DateTime.now().difference(DateTime.parse(ts)).inDays == 1) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = dateTitle;
    }

    return Consumer(builder: (context, ref, _) {
      final user = ref.watch(userProvider)!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: showDateWidget,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 5),
              child: Text(
                dateLabel,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (data.uid == user.uid) {
                navPush(context, EditTransactUI(trData: data));
              } else {
                KSnackbar(
                  context,
                  content: "You cannot edit other's transactions",
                  isDanger: true,
                );
              }
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Dark.card : Light.card,
                borderRadius: kRadius(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: oCcy.format(double.parse(data.amount)),
                                style: TextStyle(
                                  fontFamily: "Product",
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: isIncome
                                      ? isDark
                                          ? Dark.profitText
                                          : Light.profitText
                                      : isDark
                                          ? Dark.lossText
                                          : Light.lossText,
                                ),
                                children: const [
                                  TextSpan(
                                    text: " INR",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            data.transactMode,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: data.transactMode == 'CASH'
                                  ? isDark
                                      ? Dark.profitText
                                      : Colors.black
                                  : isDark
                                      ? const Color(0xFF9DC4FF)
                                      : Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                      StatsRow(
                        color: Colors.amber.shade900,
                        content: data.source,
                        icon: Icons.person,
                      ),
                      Visibility(
                        visible: data.description.trim().isNotEmpty,
                        child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(8),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? Dark.scaffold : Light.scaffold,
                            borderRadius: kRadius(10),
                          ),
                          child: Text(data.description),
                        ),
                      )
                    ],
                  ),
                  height10,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 15,
                      ),
                      width5,
                      Text(
                        data.time.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: data.uid == user.uid &&
                bookData.users != null &&
                bookData.users!.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(user.imgUrl),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget StatsRow({
    required String content,
    required IconData icon,
    required Color color,
  }) {
    bool isEmpty = content.trim() == '';
    return Visibility(
      visible: !isEmpty,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 10,
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Icon(
                    icon,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            width5,
            Flexible(
              child: Text(
                isEmpty ? 'No Information Provided' : content,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w500,
                  fontStyle: isEmpty ? FontStyle.italic : null,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
