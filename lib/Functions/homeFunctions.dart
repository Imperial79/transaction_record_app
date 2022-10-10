import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:transaction_record_app/services/user.dart';

getUserDetailsFromPreference(StateSetter setState) async {
  if (UserDetails.userName == '') {
    await Hive.openBox('User');
    Map<dynamic, dynamic> userMap = await Hive.box('User').get('userMap');

    UserDetails.uid = userMap['uid'];
    UserDetails.userDisplayName = userMap['name'];
    UserDetails.userEmail = userMap['email'];
    UserDetails.userProfilePic = userMap['imgUrl'];
    UserDetails.uid = userMap['uid'];
    UserDetails.userName = userMap['username'];
    setState(() {});
  }
}
