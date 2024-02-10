import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FirebaseRefs {
  static final _firestore = FirebaseFirestore.instance;
  static final myUID = FirebaseAuth.instance.currentUser!.uid;

  static DocumentReference<Map<String, dynamic>> myRef =
      _firestore.collection('users').doc(myUID);
  static CollectionReference<Map<String, dynamic>> userRef =
      _firestore.collection('users');

  static DocumentReference<Map<String, dynamic>> transactBookRef(
      String bookId) {
    return myRef.collection('transact_books').doc(bookId);
  }

  static CollectionReference<Map<String, dynamic>> requestRef =
      _firestore.collection('requests');
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
}
