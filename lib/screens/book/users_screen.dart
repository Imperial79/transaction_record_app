import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaction_record_app/components/common/k_scaffold.dart';
import 'package:transaction_record_app/utility/constants.dart';
import 'package:transaction_record_app/utility/newColors.dart';
import 'package:transaction_record_app/models/userModel.dart';
import '../../repositories/auth_repository.dart';
import '../../utility/commons.dart';

class UsersScreen extends ConsumerStatefulWidget {
  final List<dynamic> users;
  final String ownerUid;
  final String bookId;
  const UsersScreen({
    super.key,
    required this.users,
    required this.ownerUid,
    required this.bookId,
  });

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
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
    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Architectural Header
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: context.textColor.lighten(0.1)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "BOOK COLLABORATORS",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: context.fadeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _usersList.length,
                itemBuilder: (context, index) {
                  UserModel userData = UserModel.fromMap(_usersList[index]);
                  return _usersTile(user: userData);
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _usersTile({required UserModel user}) {
    final currentUser = ref.watch(userProvider);
    bool isMe = user.uid == currentUser?.uid;
    bool isOwner = widget.ownerUid == user.uid;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border.all(color: context.textColor.lighten(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: context.textColor.lighten(0.1)),
            ),
            child: Image.network(user.imgUrl, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe ? "YOU" : user.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isMe ? context.primaryColor : context.textColor,
                  ),
                ),
                Text(
                  "@${user.username}",
                  style: TextStyle(
                    fontSize: 10,
                    color: context.fadeTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (isOwner)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: context.textColor,
                border: Border.all(color: context.textColor),
              ),
              child: Text(
                'ADMIN',
                style: TextStyle(
                  fontSize: 9,
                  color: context.scaffoldColor,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          if (widget.ownerUid == currentUser?.uid && !isOwner)
            IconButton(
              onPressed: () => _removeUserFromBook(user.uid),
              icon: Icon(
                Icons.person_remove_outlined,
                size: 18,
                color: context.lossColor,
              ),
            ),
        ],
      ),
    );
  }
}
