import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Utility/constants.dart';

import '../../Utility/colors.dart';
import '../../Utility/components.dart';
import '../../Utility/newColors.dart';
import '../../Utility/sdp.dart';

class NotificationCard extends StatelessWidget {
  final data;
  const NotificationCard({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    setSystemUIColors(context);
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
                  // FirebaseRefs.requestRef.doc(data['id']).update({
                  //   'users': FieldValue.arrayRemove([FirebaseRefs.myUID]),
                  // });
                  try {} catch (e) {
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
