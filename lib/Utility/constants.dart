import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseRefs {
  static final _firestore = FirebaseFirestore.instance;
  static final _myUID = FirebaseAuth.instance.currentUser!.uid;

  static final myRef = _firestore.collection('users').doc(_myUID);
  static final userRef = _firestore.collection('users');

  static DocumentReference<Map<String, dynamic>> transactBookRef(
      String bookId) {
    return myRef.collection('transact_books').doc(bookId);
  }
}

String getUsername({required String email}) {
  return email.split("@").first;
}
