import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

const String kAppVersion = "2.6.2";

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

bool kCompare(String searchKey, String text) {
  return text.toLowerCase().trim().contains(searchKey.toLowerCase().trim());
}

String kMoneyFormat(dynamic amount) {
  double amt = double.parse("$amount");
  final oCcy = NumberFormat("#,##0.00", "en_US");
  return oCcy.format(amt);
}
