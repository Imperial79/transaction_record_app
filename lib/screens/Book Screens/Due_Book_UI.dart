import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Components/WIdgets.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/KButton.dart';
import 'package:transaction_record_app/Utility/KTextfield.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import '../../Functions/navigatorFns.dart';
import '../../Utility/commons.dart';
import '../../Utility/constants.dart';
import '../../Utility/newColors.dart';
import '../../models/transactModel.dart';
import '../../models/userModel.dart';
import '../../services/database.dart';
import '../Transact Screens/edit_transactUI.dart';
import '../Transact Screens/New_Transact_UI.dart';

class Due_Book_UI extends ConsumerStatefulWidget {
  final BookModel bookData;
  const Due_Book_UI({super.key, required this.bookData});

  @override
  ConsumerState<Due_Book_UI> createState() => _Due_Book_UIState(bookData);
}

class _Due_Book_UIState extends ConsumerState<Due_Book_UI> {
  final BookModel bookData;
  _Due_Book_UIState(this.bookData);

  String dateTitle = '';
  bool showDateWidget = false;
  final ValueNotifier<int> bookListCounter = ValueNotifier<int>(20);

  final oCcy = NumberFormat("#,##0.00", "en_US");

  final _searchController = TextEditingController();
  final String _selectedSortType = 'All';
  var items = ['All', 'Income', 'Expense'];
  final _newTargetAmount = TextEditingController();

  int searchingBookListCounter = 50;
  bool isLoading = false;
  bool isSearching = false;

  Future<void> _addUsers({
    required String uid,
    required String bookName,
    required String bookId,
  }) async {
    try {
      Navigator.pop(context);
      setState(() {
        isLoading = true;
      });
      int currentTime = DateTime.now().millisecondsSinceEpoch;

      Map<String, dynamic> requestMap = {
        'id': "$currentTime",
        'date': Constants.getDisplayDate(currentTime),
        'time': Constants.getDisplayTime(currentTime),
        'senderId': uid,
        'users': selectedUsers,
        'bookName': bookName,
        'bookId': bookId,
      };

      await FirebaseRefs.requestRef.doc("$currentTime").set(requestMap).then(
            (value) => KSnackbar(
              context,
              content:
                  "Request to join book has been sent to ${selectedUsers.length} user(s)",
            ),
          );
    } catch (e) {
      KSnackbar(context, content: "Something went wrong!", isDanger: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  _setNewTarget() async {
    Navigator.pop(context);
    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection("transactBooks")
          .doc(bookData.bookId)
          .update({
        "targetAmount": double.parse(_newTargetAmount.text),
      });

      KSnackbar(context,
          content: "New target set successfully!", isDanger: false);
    } catch (e) {
      KSnackbar(context, content: "Something went wrong!", isDanger: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _newTargetAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isCompleted = bookData.targetAmount != 0 &&
        (bookData.income == bookData.targetAmount);

    final user = ref.watch(userProvider);
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
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => _addUserDialog(
                            isDark,
                            uid: user!.uid,
                            bookId: bookData.bookId,
                            bookName: bookData.bookName,
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.person_add,
                        color:
                            isDark ? Colors.blueAccent : Colors.blue.shade700,
                      ),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.delete_outline)),
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
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(!isCompleted
                                      ? "Due Amount"
                                      : "Final Sum"),
                                  Text(
                                    !isCompleted
                                        ? "INR ${kMoneyFormat(data.targetAmount - data.income)}"
                                        : "INR ${kMoneyFormat(data.income)}",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: isCompleted
                                          ? isDark
                                              ? Dark.profitText
                                              : Light.profitText
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            KButton.text(
                              isDark,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => kAlertDialog(
                                    isDark,
                                    title: "Target Amount",
                                    subTitle: "Set target value",
                                    content: KTextfield.regular(
                                      isDark,
                                      controller: _newTargetAmount,
                                      hintText: "0.00",
                                      fontSize: 30,
                                      maxLines: 1,
                                      minLines: 1,
                                      keyboardType: TextInputType.number,
                                      fieldColor:
                                          isDark ? Colors.black : Colors.white,
                                      prefix: const Text(
                                        "INR",
                                        style: TextStyle(
                                          fontSize: 30,
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      KButton.regular(
                                        isDark,
                                        onPressed: _setNewTarget,
                                        label: "Set Target",
                                      )
                                    ],
                                  ),
                                );
                              },
                              label: "Edit",
                            )
                          ],
                        ),
                        height20,
                        Text(
                          data.bookName,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          DateFormat("dd MMM, yyyy").format(
                            DateTime.parse(data.bookId),
                          ),
                        ),
                        if (!isCompleted)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 600),
                              switchInCurve: Curves.easeIn,
                              switchOutCurve: Curves.easeOut,
                              child: data.targetAmount != 0
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              "Completed",
                                            ),
                                            Text(
                                                "${(double.parse("${(data.income - data.expense) / data.targetAmount}") * 100).toStringAsFixed(1)}%")
                                          ],
                                        ),
                                        height5,
                                        ClipRRect(
                                          borderRadius: kRadius(5),
                                          child: LinearProgressIndicator(
                                            minHeight: 30,
                                            value:
                                                (((data.income - data.expense) /
                                                    data.targetAmount)),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text("Add a target value!"),
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
              TransactList(isDark, bookId: bookData.bookId),
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

  List<String> selectedUsers = [];
  // bool isSelecting = false;
  Widget _addUserDialog(
    bool isDark, {
    required String uid,
    required String bookId,
    required String bookName,
  }) {
    final searchUser = TextEditingController();
    selectedUsers = [];
    bool isSelecting = false;

    void onSelect(setState, String uid) {
      setState(() {
        if (!selectedUsers.contains(uid)) {
          selectedUsers.add(uid);
        } else {
          selectedUsers.remove(uid);
        }
      });

      if (selectedUsers.isEmpty) {
        setState(() {
          isSelecting = false;
        });
      } else {
        setState(() {
          isSelecting = true;
        });
      }
    }

    return StatefulBuilder(
      builder: (context, setState) => Dialog(
        elevation: 0,
        insetPadding: const EdgeInsets.all(15),
        backgroundColor: isDark ? Dark.scaffold : Light.scaffold,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              KSearchBar(
                context,
                isDark: isDark,
                controller: searchUser,
                onChanged: (_) {
                  setState(() {});
                },
              ),
              Visibility(
                visible: isSelecting,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text('Selected ${selectedUsers.length} user(s)'),
                ),
              ),
              height20,
              FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future:
                    FirebaseRefs.userRef.where('uid', isNotEqualTo: uid).get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.isEmpty) {
                      return const Text('No Users');
                    }
                    return Flexible(
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          UserModel userData = UserModel.fromMap(
                              snapshot.data!.docs[index].data());

                          if (kCompare(searchUser.text, userData.name) ||
                              kCompare(searchUser.text, userData.username)) {
                            return kUserTile(
                              isDark,
                              userData: userData,
                              isSelecting: isSelecting,
                              selectedUsers: selectedUsers,
                              onTap: () {
                                onSelect(setState, userData.uid);
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    );
                  }
                  return const LinearProgressIndicator();
                },
              ),
              selectedUsers.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          await _addUsers(
                            uid: uid,
                            bookId: bookData.bookId,
                            bookName: bookData.bookName,
                          );
                        },
                        child: const Text('Send Request'),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget TransactList(bool isDark, {required String bookId}) {
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
                            final searchKey = Constants.getSearchString(
                                _searchController.text);

                            if (_selectedSortType == 'All') {
                              if (_searchController.text.isEmpty) {
                                return _transactTile(isDark, data: transact);
                              } else if (transact.amount.contains(searchKey) ||
                                  transact.description
                                      .toLowerCase()
                                      .contains(searchKey) ||
                                  transact.source
                                      .toLowerCase()
                                      .contains(searchKey)) {
                                return _transactTile(isDark, data: transact);
                              }
                            } else if (transact.type.toLowerCase() ==
                                _selectedSortType.toLowerCase()) {
                              if (searchKey.isEmpty) {
                                return _transactTile(isDark, data: transact);
                              } else if (transact.amount.contains(searchKey) ||
                                  transact.description
                                      .toLowerCase()
                                      .contains(searchKey) ||
                                  transact.source
                                      .toLowerCase()
                                      .contains(searchKey)) {
                                return _transactTile(isDark, data: transact);
                              }
                            }
                            return const SizedBox.shrink();
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              data.uid != user.uid &&
                      bookData.users != null &&
                      bookData.users!.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child:
                          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(data.uid)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return CircleAvatar(
                              radius: 12,
                              backgroundImage: NetworkImage(
                                  snapshot.data!.data()!['imgUrl']),
                            );
                          }

                          return const CircleAvatar(
                            radius: 12,
                          );
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
              Flexible(
                child: GestureDetector(
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
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? Dark.card : Light.card,
                        borderRadius: kRadius(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                            color: isIncome
                                                ? isDark
                                                    ? Dark.profitText
                                                    : Light.profitText
                                                : isDark
                                                    ? Dark.lossText
                                                    : Light.lossText,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              isDark
                                                  ? BoxShadow(
                                                      color: isIncome
                                                          ? isDark
                                                              ? Dark.profitCard
                                                                  .withOpacity(
                                                                      .5)
                                                              : Light.profitCard
                                                                  .withOpacity(
                                                                      .5)
                                                          : isDark
                                                              ? Dark.lossCard
                                                              : Light.lossCard,
                                                      blurRadius: 30,
                                                      spreadRadius: 1,
                                                    )
                                                  : const BoxShadow(),
                                            ],
                                          ),
                                          child: FittedBox(
                                            child: Icon(
                                              isIncome
                                                  ? Icons.file_download_outlined
                                                  : Icons.file_upload_outlined,
                                              color: isIncome
                                                  ? isDark
                                                      ? Colors.black
                                                      : Colors.white
                                                  : isDark
                                                      ? Colors.red.shade900
                                                      : Colors.white,
                                            ),
                                          ),
                                        ),
                                        width10,
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  text: oCcy.format(
                                                      double.parse(
                                                          data.amount)),
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
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: data.transactMode ==
                                                          'CASH'
                                                      ? isDark
                                                          ? Dark.profitText
                                                          : Colors.black
                                                      : isDark
                                                          ? const Color(
                                                              0xFF9DC4FF)
                                                          : Colors
                                                              .blue.shade900,
                                                  borderRadius: kRadius(100),
                                                ),
                                                child: Text(
                                                  data.transactMode,
                                                  style: TextStyle(
                                                    letterSpacing: 1,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w900,
                                                    color: isDark
                                                        ? Colors.black
                                                        : Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
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
                                      visible:
                                          data.description.trim().isNotEmpty,
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        padding: const EdgeInsets.all(8),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Dark.scaffold
                                              : Light.scaffold,
                                          borderRadius: kRadius(10),
                                        ),
                                        child: Text(data.description),
                                      ),
                                    )
                                  ],
                                ),
                              ),
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
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
