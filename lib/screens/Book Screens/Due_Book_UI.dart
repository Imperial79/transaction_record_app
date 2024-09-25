import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Components/WIdgets.dart';
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
import '../../services/user.dart';
import '../Transact Screens/edit_transactUI.dart';
import '../Transact Screens/new_transactUi.dart';

class Due_Book_UI extends StatefulWidget {
  final BookModel bookData;
  Due_Book_UI({super.key, required this.bookData});

  @override
  State<Due_Book_UI> createState() => _Due_Book_UIState(bookData);
}

class _Due_Book_UIState extends State<Due_Book_UI> {
  final BookModel bookData;
  _Due_Book_UIState(this.bookData);

  String dateTitle = '';
  bool showDateWidget = false;
  final ValueNotifier<int> bookListCounter = ValueNotifier<int>(20);

  final oCcy = new NumberFormat("#,##0.00", "en_US");

  final _searchController = TextEditingController();
  String _selectedSortType = 'All';
  var items = ['All', 'Income', 'Expense'];
  final _newTargetAmount = new TextEditingController();

  int searchingBookListCounter = 50;
  bool isLoading = false;
  bool isSearching = false;

  Future<void> _addUsers({
    required String bookName,
    required String bookId,
  }) async {
    try {
      Navigator.pop(context);
      setState(() {
        isLoading = true;
      });
      int currentTime = DateTime.now().millisecondsSinceEpoch;

      Map<String, dynamic> _requestMap = {
        'id': "$currentTime",
        'date': Constants.getDisplayDate(currentTime),
        'time': Constants.getDisplayTime(currentTime),
        'senderId': globalUser.uid,
        'users': selectedUsers,
        'bookName': bookName,
        'bookId': bookId,
      };

      await FirebaseRefs.requestRef.doc("$currentTime").set(_requestMap).then(
            (value) => kSnackbar(
              context,
              content:
                  "Request to join book has been sent to ${selectedUsers.length} user(s)",
            ),
          );
    } catch (e) {
      kSnackbar(context, content: "Something went wrong!", isDanger: true);
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

      kSnackbar(context,
          content: "New target set successfully!", isDanger: false);
    } catch (e) {
      kSnackbar(context, content: "Something went wrong!", isDanger: true);
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
    isDark = Theme.of(context).brightness == Brightness.dark;
    bool isCompleted = bookData.targetAmount != 0 &&
        (bookData.income == bookData.targetAmount);
    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: isDark ? Dark.card : Light.card,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    kBackButton(context),
                    Spacer(),
                    IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => _addUserDialog(
                              isDark,
                              bookId: bookData.bookId,
                              bookName: bookData.bookName,
                            ),
                          );
                        },
                        icon: Icon(Icons.person_add)),
                    IconButton(
                        onPressed: () {}, icon: Icon(Icons.delete_outline)),
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
                                          ? Dark.profitText
                                          : Light.profitText,
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
                                      prefix: Text(
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
                          style: TextStyle(
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
                            padding: EdgeInsets.only(top: 20.0),
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 600),
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
                                            Text(
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
                                  : Text("Add a target value!"),
                            ),
                          ),
                      ],
                    );
                  } else {
                    return LinearProgressIndicator();
                  }
                },
              ),
              height20,
              TransactList(bookData.bookId),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navPush(
            context,
            New_Transact_UI(
              bookId: bookData.bookId,
            ),
          );
        },
        elevation: 0,
        highlightElevation: 0,
        child: Icon(Icons.add),
      ),
    );
  }

  List<String> selectedUsers = [];
  // bool isSelecting = false;
  Widget _addUserDialog(
    bool isDark, {
    required String bookId,
    required String bookName,
  }) {
    final _searchUser = TextEditingController();
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

      if (selectedUsers.length == 0) {
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
        insetPadding: EdgeInsets.all(15),
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
                controller: _searchUser,
                onChanged: (_) {
                  setState(() {});
                },
              ),
              Visibility(
                visible: isSelecting,
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text('Selected ${selectedUsers.length} user(s)'),
                ),
              ),
              height20,
              FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: FirebaseRefs.userRef
                    .where('uid', isNotEqualTo: globalUser.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.length == 0) {
                      return Text('No Users');
                    }
                    return Flexible(
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          KUser userData =
                              KUser.fromMap(snapshot.data!.docs[index].data());

                          if (kCompare(_searchUser.text, userData.name) ||
                              kCompare(_searchUser.text, userData.username)) {
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
                          return SizedBox.shrink();
                        },
                      ),
                    );
                  }
                  return LinearProgressIndicator();
                },
              ),
              selectedUsers.length > 0
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          await _addUsers(
                            bookId: bookData.bookId,
                            bookName: bookData.bookName,
                          );
                        },
                        child: Text('Send Request'),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget TransactList(String bookId) {
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
              duration: Duration(milliseconds: 600),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: snapshot.hasData
                  ? snapshot.data!.docs.length > 0
                      ? ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            Transact transact = Transact.fromMap(
                                snapshot.data!.docs[index].data());
                            final searchKey = Constants.getSearchString(
                                _searchController.text);

                            if (_selectedSortType == 'All') {
                              if (_searchController.text.isEmpty) {
                                return _transactTile(transact);
                              } else if (transact.amount.contains(searchKey) ||
                                  transact.description
                                      .toLowerCase()
                                      .contains(searchKey) ||
                                  transact.source
                                      .toLowerCase()
                                      .contains(searchKey)) {
                                return _transactTile(transact);
                              }
                            } else if (transact.type.toLowerCase() ==
                                _selectedSortType.toLowerCase()) {
                              if (searchKey.isEmpty) {
                                return _transactTile(transact);
                              } else if (transact.amount.contains(searchKey) ||
                                  transact.description
                                      .toLowerCase()
                                      .contains(searchKey) ||
                                  transact.source
                                      .toLowerCase()
                                      .contains(searchKey)) {
                                return _transactTile(transact);
                              }
                            }
                            return SizedBox.shrink();
                          },
                        )
                      : Text(
                          'No Transacts',
                          style: TextStyle(
                            fontSize: 30,
                            color: isDark ? Dark.fadeText : Light.fadeText,
                          ),
                        )
                  : DummyTransactList(),
            );
          },
        );
      },
    );
  }

  Widget _transactTile(Transact transactData) {
    bool isIncome = transactData.type == 'Income';
    String dateLabel = '';
    var todayDate = DateFormat.yMMMMd().format(DateTime.now());
    if (dateTitle == transactData.date) {
      showDateWidget = false;
    } else {
      dateTitle = transactData.date;
      showDateWidget = true;
    }
    String ts = DateFormat("yMMMMd").parse(transactData.date).toString();

    if (dateTitle == todayDate) {
      dateLabel = 'Today';
    } else if (DateTime.now().difference(DateTime.parse(ts)).inDays == 1) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = dateTitle;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: showDateWidget,
          child: Padding(
            padding: EdgeInsets.only(bottom: 10, top: 5),
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
            transactData.uid != globalUser.uid &&
                    bookData.users != null &&
                    bookData.users!.length > 0
                ? Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child:
                        FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(transactData.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return CircleAvatar(
                            radius: 12,
                            backgroundImage:
                                NetworkImage(snapshot.data!.data()!['imgUrl']),
                          );
                        }

                        return CircleAvatar(
                          radius: 12,
                        );
                      },
                    ),
                  )
                : SizedBox.shrink(),
            Flexible(
              child: GestureDetector(
                onTap: () {
                  if (transactData.uid == globalUser.uid)
                    navPush(context, EditTransactUI(trData: transactData));
                  else
                    kSnackbar(
                      context,
                      content: "You cannot edit other's transactions",
                      isDanger: true,
                    );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Container(
                    padding: EdgeInsets.all(10),
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
                                        padding: EdgeInsets.all(6),
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
                                                                .withOpacity(.5)
                                                            : Light.profitCard
                                                                .withOpacity(.5)
                                                        : isDark
                                                            ? Dark.lossCard
                                                            : Light.lossCard,
                                                    blurRadius: 30,
                                                    spreadRadius: 1,
                                                  )
                                                : BoxShadow(),
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
                                                text: oCcy.format(double.parse(
                                                    transactData.amount)),
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
                                                children: [
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
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: transactData
                                                            .transactMode ==
                                                        'CASH'
                                                    ? isDark
                                                        ? Dark.profitText
                                                        : Colors.black
                                                    : isDark
                                                        ? Color(0xFF9DC4FF)
                                                        : Colors.blue.shade900,
                                                borderRadius: kRadius(100),
                                              ),
                                              child: Text(
                                                transactData.transactMode,
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
                                    content: transactData.source,
                                    icon: Icons.person,
                                  ),
                                  Visibility(
                                    visible: transactData.description
                                        .trim()
                                        .isNotEmpty,
                                    child: Container(
                                      margin: EdgeInsets.only(top: 10),
                                      padding: EdgeInsets.all(8),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Dark.scaffold
                                            : Light.scaffold,
                                        borderRadius: kRadius(10),
                                      ),
                                      child: Text(transactData.description),
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
                            Icon(
                              Icons.schedule_rounded,
                              size: 15,
                            ),
                            width5,
                            Text(
                              transactData.time.toString(),
                              style: TextStyle(
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
              visible: transactData.uid == globalUser.uid &&
                  bookData.users != null &&
                  bookData.users!.length > 0,
              child: Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(globalUser.imgUrl),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 10,
              child: FittedBox(
                child: Padding(
                  padding: EdgeInsets.all(5),
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
