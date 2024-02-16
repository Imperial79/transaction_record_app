import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/services/user.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../models/userModel.dart';
import '../screens/Home Screens/homeUi.dart';

class FirebaseRefs {
  static final _firestore = FirebaseFirestore.instance;
  // static final myUID = globalUser.uid;

  static DocumentReference<Map<String, dynamic>> myRef =
      _firestore.collection('users').doc(globalUser.uid);
  static CollectionReference<Map<String, dynamic>> userRef =
      _firestore.collection('users');

  static DocumentReference<Map<String, dynamic>> transactBookRef(
      String bookId) {
    return _firestore.collection('transactBooks').doc(bookId);
  }

  static CollectionReference<Map<String, dynamic>> requestRef =
      _firestore.collection('requests');

  static CollectionReference<Map<String, dynamic>> transactsRef(
          String bookId) =>
      transactBookRef(bookId).collection('transacts');
}

class Constants {
  static String getUsername({required String email}) {
    return email.split("@").first;
  }

  static String getDisplayDate(int milliseconds) {
    return DateFormat.yMMMMd()
        .format(DateTime.fromMillisecondsSinceEpoch(milliseconds));
  }

  static String getDisplayTime(int milliseconds) {
    return DateFormat()
        .add_jm()
        .format(DateTime.fromMillisecondsSinceEpoch(milliseconds));
  }

  static String getSearchString(String text) {
    return text.trim().toLowerCase();
  }

  static Future<void> getUserDetailsFromPreference() async {
    try {
      if (globalUser.uid == '') {
        final _userBox = await Hive.openBox('USERBOX');
        final userMap = await _userBox.get('userData');

        displayNameGlobal.value = userMap['name'];
        globalUser = KUser.fromMap(userMap);

        await Hive.close();
      }
    } catch (e) {
      log("Error while fetching data from Hive $e");
    }
  }
}

// ValueNotifier<bool> hasInternet = ValueNotifier(true);

class ConnectionConfig {
  static InternetConnection _connection = new InternetConnection();
  static ValueNotifier<bool> hasInternet = ValueNotifier(true);

  static void listenForConnection() {
    _connection.onStatusChange.listen((status) {
      switch (status) {
        case InternetStatus.connected:
          hasInternet.value = true;
          break;
        case InternetStatus.disconnected:
          hasInternet.value = false;
          break;
      }
    });
  }
}
