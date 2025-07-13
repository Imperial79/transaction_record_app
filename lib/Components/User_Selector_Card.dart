import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/models/bookModel.dart';

import '../Utility/commons.dart';
import '../Utility/components.dart';
import '../Utility/newColors.dart';
import '../models/userModel.dart';

class UserSelectorDialog extends ConsumerStatefulWidget {
  final BookModel bookData;
  const UserSelectorDialog({super.key, required this.bookData});

  @override
  ConsumerState<UserSelectorDialog> createState() => _UserSelectorDialogState();
}

class _UserSelectorDialogState extends ConsumerState<UserSelectorDialog> {
  final searchKey = TextEditingController();
  List selectedUsers = [];
  bool isSelecting = false;

  void onSelect(StateSetter setState, String uid) {
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

  @override
  void dispose() {
    searchKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);
    return Dialog(
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
              controller: searchKey,
              onChanged: (_) {
                setState(() {});
              },
            ),
            Visibility(
              visible: isSelecting,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text('Selected ${selectedUsers.length} user(s)'),
              ),
            ),
            FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future:
                  FirebaseRefs.userRef
                      .where('uid', isNotEqualTo: user!.uid)
                      .get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isEmpty) {
                    return const Text('No Users');
                  }
                  return Flexible(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      itemCount: snapshot.data!.docs.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        UserModel userData = UserModel.fromMap(
                          snapshot.data!.docs[index].data(),
                        );
                        if (Constants.getSearchString(
                              userData.name,
                            ).contains(searchKey.text) ||
                            Constants.getSearchString(
                              userData.username,
                            ).contains(searchKey.text)) {
                          return _userTile(
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
                      int currentTime = DateTime.now().millisecondsSinceEpoch;

                      Map<String, dynamic> requestMap = {
                        'id': "$currentTime",
                        'date': Constants.getDisplayDate(currentTime),
                        'time': Constants.getDisplayTime(currentTime),
                        'senderId': user.uid,
                        'users': selectedUsers,
                        'bookName': widget.bookData.bookName,
                        'bookId': widget.bookData.bookId,
                      };

                      await FirebaseRefs.requestRef
                          .doc("$currentTime")
                          .set(requestMap)
                          .then(
                            (value) => KSnackbar(
                              context,
                              content:
                                  "Request to join book has been sent to ${selectedUsers.length} user(s)",
                            ),
                          );
                      Navigator.pop(context);
                    },
                    child: Text('Send Request [${selectedUsers.length}]'),
                  ),
                )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Padding _userTile(
    bool isDark, {
    required List selectedUsers,
    required UserModel userData,
    required bool isSelecting,
    void Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: kRadius(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: kRadius(15),
            color:
                selectedUsers.contains(userData.uid)
                    ? isDark
                        ? Dark.primary.lighten(.2)
                        : Light.profitCard
                    : Colors.transparent,
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              selectedUsers.contains(userData.uid)
                  ? const CircleAvatar(child: Icon(Icons.done))
                  : CircleAvatar(
                    backgroundImage: NetworkImage(userData.imgUrl),
                  ),
              width20,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData.name,
                      style: TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "@${userData.username}",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Dark.fadeText : Light.fadeText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
