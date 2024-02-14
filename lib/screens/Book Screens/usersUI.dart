import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/colors.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/customScaffold.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/Utility/sdp.dart';
import 'package:transaction_record_app/models/userModel.dart';
import 'package:transaction_record_app/services/user.dart';

import '../../Utility/components.dart';

class UsersUI extends StatefulWidget {
  final List<dynamic> users;
  final String ownerUid;
  final String bookId;
  const UsersUI(
      {Key? key,
      required this.users,
      required this.ownerUid,
      required this.bookId})
      : super(key: key);

  @override
  State<UsersUI> createState() => _UsersUIState();
}

class _UsersUIState extends State<UsersUI> {
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    widget.users.add(widget.ownerUid);
  }

  void _removeUserFromBook(String userUid) async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseRefs.transactBookRef(widget.bookId).update({
        'uid': FieldValue.arrayRemove([userUid]),
      });
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;
    return KScaffold(
      appBar: AppBar(
        title: Text('Joined Users'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
            future:
                FirebaseRefs.userRef.where('uid', whereIn: widget.users).get(),
            builder: (context, snapshot) {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 600),
                child: snapshot.hasData
                    ? snapshot.data!.docs.length == 0
                        ? NoData(context, customText: 'No Users')
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              KUser user = KUser.fromMap(
                                  snapshot.data!.docs[index].data());
                              return _usersTile(user);
                            },
                            separatorBuilder: (context, index) => height20,
                          )
                    : snapshot.hasError
                        ? Text('Has Error')
                        : _dummyUserTile(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _usersTile(KUser user) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(user.imgUrl),
          radius: sdp(context, 12),
        ),
        width10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.uid == globalUser.uid ? "You" : user.name,
                style: TextStyle(
                  fontSize: sdp(context, 12),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(user.username),
            ],
          ),
        ),
        width10,
        Visibility(
          visible:
              widget.ownerUid == globalUser.uid && widget.ownerUid != user.uid,
          child: ElevatedButton(
            onPressed: () {
              _removeUserFromBook(user.uid);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.black : Colors.white,
              foregroundColor:
                  isDark ? DarkColors.lossText : LightColors.lossText,
            ),
            child: Text('Remove'),
          ),
        ),
        Visibility(
          visible: widget.ownerUid == user.uid,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: kRadius(6),
              color:
                  isDark ? DarkColors.primaryButton : LightColors.primaryButton,
              // border: Border.all(
              //   color: isDark ? DarkColors.profitCard : LightColors.profitCard,
              // ),
            ),
            child: Text(
              'Admin',
              style: TextStyle(
                  color: isDark ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dummyUserTile() {
    return Card(
      child: SizedBox(
        height: 100,
        width: double.infinity,
      ),
    );
  }
}
