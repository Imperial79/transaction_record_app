import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/models/userModel.dart';
import '../../Repository/auth_repository.dart';
import '../../Utility/commons.dart';

class UsersUI extends ConsumerStatefulWidget {
  final List<dynamic> users;
  final String ownerUid;
  final String bookId;
  const UsersUI({
    super.key,
    required this.users,
    required this.ownerUid,
    required this.bookId,
  });

  @override
  ConsumerState<UsersUI> createState() => _UsersUIState();
}

class _UsersUIState extends ConsumerState<UsersUI> {
  final isLoading = ValueNotifier(false);
  final List<dynamic> _allUsers = [];
  List<dynamic> _usersList = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    _allUsers.addAll(widget.users);
    _allUsers.add(widget.ownerUid);
    await _fetchBookUsers();
  }

  Future<void> _fetchBookUsers() async {
    isLoading.value = true;
    _usersList = [];
    await FirebaseRefs.userRef.where('uid', whereIn: _allUsers).get().then((
      value,
    ) {
      setState(() {
        for (var element in value.docs) {
          _usersList.add(element.data());
        }
      });
    });
    isLoading.value = false;
  }

  void _removeUserFromBook(String userUid) async {
    try {
      isLoading.value = true;
      await FirebaseRefs.transactBookRef(widget.bookId)
          .update({
            'uid': FieldValue.arrayRemove([userUid]),
          })
          .whenComplete(() async {
            _allUsers.remove(userUid);
            widget.users.remove(userUid);
            KSnackbar(context, content: "User Removed!");
            await _fetchBookUsers();
          });
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      KSnackbar(context, content: "Unable to remove user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return KScaffold(
      isLoading: isLoading,
      appBar: AppBar(title: const Text('Joined Users')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _usersList.length,
            itemBuilder: (context, index) {
              UserModel userData = UserModel.fromMap(_usersList[index]);
              return _usersTile(uid: user!.uid, user: userData);
            },
            separatorBuilder: (context, index) => height20,
          ),
        ),
      ),
    );
  }

  Widget _usersTile({required String uid, required UserModel user}) {
    return Row(
      children: [
        CircleAvatar(backgroundImage: NetworkImage(user.imgUrl), radius: 15),
        width10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.uid == uid ? "You" : user.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(user.username),
            ],
          ),
        ),
        width10,
        Visibility(
          visible: widget.ownerUid == uid && widget.ownerUid != user.uid,
          child: ElevatedButton(
            onPressed: () {
              _removeUserFromBook(user.uid);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.scaffoldColor,
              foregroundColor: context.lossColor,
            ),
            child: const Text('Remove'),
          ),
        ),
        Visibility(
          visible: widget.ownerUid == user.uid,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: kRadius(6),
              color: context.primaryColor,
            ),
            child: Text(
              'Admin',
              style: TextStyle(
                color: context.isDarkMode ? Colors.black : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
