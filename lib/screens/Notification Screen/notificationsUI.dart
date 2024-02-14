import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Utility/colors.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/customScaffold.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/Utility/sdp.dart';

import '../../services/user.dart';

class NotificationsUI extends StatefulWidget {
  const NotificationsUI({Key? key}) : super(key: key);

  @override
  State<NotificationsUI> createState() => _NotificationsUIState();
}

class _NotificationsUIState extends State<NotificationsUI> {
  Future<void> _addToBook({
    required String bookId,
    required String bookName,
    required String requestId,
  }) async {
    try {
      await FirebaseRefs.transactBookRef(bookId).get().then((book) async {
        if (book.exists) {
          await FirebaseRefs.transactBookRef(bookId).update({
            'users': FieldValue.arrayUnion([globalUser.uid])
          }).then((value) async {
            await _removeFromRequest(requestId: requestId).then(
              (value) => ShowSnackBar(
                context,
                content: "\"$bookName\" Book joined successfully!",
              ),
            );
          });
        } else {
          ShowSnackBar(
            context,
            content: "Book does not exists!",
            isDanger: true,
          );
        }
      });
    } catch (e) {
      ShowSnackBar(context, content: "Something went wrong!", isDanger: true);
    }
  }

  Future<void> _removeFromRequest({required requestId}) async {
    try {
      await FirebaseRefs.requestRef.doc(requestId).update({
        'users': FieldValue.arrayRemove([globalUser.uid]),
      }).then((value) => ShowSnackBar(
            context,
            content: 'Request Rejected!',
          ));
    } catch (e) {
      ShowSnackBar(context, content: "Something went wrong!", isDanger: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;
    return KScaffold(
      appBar: AppBar(
        backgroundColor: isDark ? DarkColors.scaffold : LightColors.scaffold,
        title: Text('Notifications'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: StreamBuilder<dynamic>(
            stream: FirebaseRefs.requestRef
                .where('users', arrayContains: globalUser.uid)
                .snapshots(),
            builder: (context, snapshot) {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 600),
                child: snapshot.hasData
                    ? snapshot.data.docs.length == 0
                        ? NoData(context, customText: 'No Notifications Yet')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Recent Notifications'),
                              height10,
                              ListView.separated(
                                shrinkWrap: true,
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot ds =
                                      snapshot.data.docs[index];
                                  return _notificationCard(ds);
                                },
                                separatorBuilder: (context, index) => height10,
                              ),
                            ],
                          )
                    : snapshot.hasError
                        ? Text('Has Error')
                        : _dummyNotificationsCard(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _dummyNotificationsCard() {
    return Card(
      child: SizedBox(
        height: sdp(context, 100),
        width: double.infinity,
      ),
    );
  }

  Widget _notificationCard(requestData) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: kRadius(15),
        color: isDark ? DarkColors.card : LightColors.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<dynamic>(
            future: FirebaseRefs.userRef.doc(requestData['senderId']).get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.data() != null) {
                  return _notificationCardHeader(data: snapshot.data.data());
                }
              }
              return Transform.scale(
                scale: .5,
                child: CircularProgressIndicator(),
              );
            },
          ),
          height10,
          Text(
            'Join my book "${requestData['bookName']}" so that we can share the expense details!',
            style: TextStyle(
              fontSize: sdp(context, 12),
            ),
          ),
          height10,
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _addToBook(
                    bookId: requestData['bookId'],
                    bookName: requestData['bookName'],
                    requestId: requestData['id'],
                  );
                },
                child: Text('Accept'),
              ),
              width10,
              ElevatedButton(
                onPressed: () async {
                  await _removeFromRequest(
                    requestId: requestData['id'],
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? DarkColors.lossCard : LightColors.lossCard,
                  foregroundColor: Colors.white,
                ),
                child: Text('Reject'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _notificationCardHeader({dynamic data}) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(data['imgUrl']),
        ),
        width10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data["name"] ?? "User",
                style: TextStyle(
                  fontSize: sdp(context, 12),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(data["username"] ?? 'username'),
            ],
          ),
        ),
      ],
    );
  }
}
