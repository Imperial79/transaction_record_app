import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Utility/colors.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/Utility/sdp.dart';

class NotificationsUI extends StatefulWidget {
  const NotificationsUI({Key? key}) : super(key: key);

  @override
  State<NotificationsUI> createState() => _NotificationsUIState();
}

class _NotificationsUIState extends State<NotificationsUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? DarkColors.scaffold : LightColors.scaffold,
        title: Text('Notifications'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent Notifications'),
              height10,
              StreamBuilder<dynamic>(
                stream: FirebaseRefs.requestRef
                    .where('users', arrayContains: FirebaseRefs.myUID)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot ds = snapshot.data.docs[index];
                        return _notificationCard(ds);
                      },
                      separatorBuilder: (context, index) => height10,
                    );
                  } else if (snapshot.hasData &&
                      snapshot.data.docs.length == 0) {
                    return Center(
                      child: Text('No Notifications Yet'),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Something went wrong'),
                    );
                  }
                  return LinearProgressIndicator();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notificationCard(data) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: isDark ? DarkColors.card : LightColors.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(),
              width10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Name',
                      style: TextStyle(
                        fontSize: sdp(context, 12),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text('username'),
                  ],
                ),
              ),
            ],
          ),
          height10,
          Text(
            'Join my book "${data['bookName']}" so that we can share the expense details!',
            style: TextStyle(
              fontSize: sdp(context, 12),
            ),
          ),
          height10,
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseRefs.transactBookRef(data['bookId'])
                        .get()
                        .then((book) async {
                      if (book.exists) {
                        await FirebaseRefs.transactBookRef(data['bookId'])
                            .update({
                          'users': FieldValue.arrayUnion([FirebaseRefs.myUID])
                        }).then((value) => ShowSnackBar(context,
                                content: "Book Joined Successfully!"));
                      } else {
                        ShowSnackBar(
                          context,
                          content: "Book does not exists!",
                          isDanger: true,
                        );
                      }
                    });
                  } catch (e) {
                    ShowSnackBar(context,
                        content: "Something went wrong!", isDanger: true);
                  }
                },
                child: Text('Accept'),
              ),
              width10,
              ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseRefs.requestRef.doc(data['id']).update({
                      'users': FieldValue.arrayRemove([FirebaseRefs.myUID]),
                    }).then((value) => ShowSnackBar(
                          context,
                          content: 'Request Rejected',
                        ));
                  } catch (e) {
                    ShowSnackBar(context,
                        content: "Something went wrong!", isDanger: true);
                  }
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
}
