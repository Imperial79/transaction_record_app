import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transaction_record_app/services/user.dart';

getUserDetailsFromPreference(StateSetter setState) async {
  if (UserDetails.userName == '') {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserDetails.userName = prefs.getString('USERNAMEKEY')!;
    UserDetails.userEmail = prefs.getString('USEREMAILKEY')!;
    UserDetails.uid = prefs.getString('USERKEY')!;
    UserDetails.userDisplayName = prefs.getString('USERDISPLAYNAMEKEY')!;
    UserDetails.userProfilePic = prefs.getString('USERPROFILEKEY')!;
    setState(() {});
  }
}
