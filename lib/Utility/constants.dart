import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

const String kAppVersion = "2.5.5";

class FirebaseRefs {
  static final _firestore = FirebaseFirestore.instance;

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
}

class ConnectionConfig {
  static final InternetConnection _connection = InternetConnection();
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

bool kCompare(String searchKey, String text) {
  return text.toLowerCase().trim().contains(searchKey.toLowerCase().trim());
}

String kMoneyFormat(dynamic amount) {
  double amt = double.parse("$amount");
  final oCcy = NumberFormat("#,##0.00", "en_US");
  return oCcy.format(amt);
}
