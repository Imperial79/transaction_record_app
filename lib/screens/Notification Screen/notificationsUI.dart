import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/colors.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/Utility/sdp.dart';
import 'package:transaction_record_app/screens/Notification%20Screen/notificationCard.dart';

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
                  log("${snapshot.data}");
                  if (snapshot.hasData) {
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot ds = snapshot.data.docs[index];
                        return NotificationCard(data: ds);
                      },
                      separatorBuilder: (context, index) => height10,
                    );
                  } else if (snapshot.data.docs.length == 0) {
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
}
