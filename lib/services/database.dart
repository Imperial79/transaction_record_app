import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transaction_record_app/services/user.dart';

class DatabaseMethods {
  final _firestore = FirebaseFirestore.instance;
  //  upload new transact book
  createNewTransactBook(String bookId, newBookMap) async {
    return await _firestore
        .collection('users')
        .doc(UserDetails.uid)
        .collection('transact_books')
        .doc(bookId)
        .set(newBookMap);
  }

  //Adding user to database QUERY
  addUserInfoToDB(String uid, Map<String, dynamic> userInfoMap) async {
    return await _firestore.collection("users").doc(uid).set(userInfoMap);
  }

  //  UPDATE TRANSACTS
  updateTransacts(String bookId, transactId, transactMap) async {
    await _firestore
        .collection('users')
        .doc(UserDetails.uid)
        .collection('transact_books')
        .doc(bookId)
        .collection('transacts')
        .doc(transactId)
        .update(transactMap);
  }

  //Uploading transactions to database QUERY
  uploadTransacts(uid, transactMap, bookId, transactId) async {
    await _firestore
        .collection('users')
        .doc(UserDetails.uid)
        .collection("transact_books")
        .doc(bookId)
        .collection('transacts')
        .doc(transactId)
        .set(transactMap);
  }

  //  UPDATE account details
  Future<String> updateAccountDetails(
      String uid, Map<String, dynamic> accountDetails) async {
    try {
      await _firestore
          .collection('users')
          .doc(UserDetails.uid)
          .update(accountDetails);
      return 'Profile updated successfully';
    } catch (e) {
      return e.toString();
    }
  }

  //  Update BOOK transactions
  updateBookTransactions(String bookId, Map<String, dynamic> newMap) async {
    return await _firestore
        .collection('users')
        .doc(UserDetails.uid)
        .collection('transact_books')
        .doc(bookId)
        .update(newMap);
  }

  //  Update global CURRENT BALANCE
  updateGlobalCurrentBal(String uid, Map<String, dynamic> currentBalMap) async {
    return await _firestore
        .collection('users')
        .doc(UserDetails.uid)
        .update(currentBalMap);
  }

  //  Reset Book Income/Expense
  resetBookIncomeExpense(String bookId, uid, map) async {
    return await _firestore
        .collection('users')
        .doc(UserDetails.uid)
        .collection('transact_books')
        .doc(bookId)
        .update(map);
  }

  //  Reset Book Income/Expense
  resetGlobalIncomeExpense(String bookId, uid, map) async {
    return await _firestore
        .collection('users')
        .doc(UserDetails.uid)
        .update(map);
  }

  //Delete one book
  _deleteBook(bookId) async {
    await _firestore
        .collection('users')
        .doc(UserDetails.uid)
        .collection('transact_books')
        .where('bookId', isEqualTo: bookId)
        .limit(1)
        .get()
        .then(
      (snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      },
    );
  }

  Future<String> deleteBookWithCollections(String bookId) async {
    try {
      await _firestore
          .collection('users')
          .doc(UserDetails.uid)
          .collection('transact_books')
          .doc(bookId)
          .collection('transacts')
          .limit(1)
          .get()
          .then((value) async {
        if (value.docs.isEmpty) {
          print('No collection ahead');
          _deleteBook(bookId);
        } else {
          print('Collection ahead');
          await _firestore
              .collection('users')
              .doc(UserDetails.uid)
              .collection('transact_books')
              .doc(bookId)
              .collection('transacts')
              .get()
              .then((snapshot) {
            for (DocumentSnapshot ds in snapshot.docs) {
              ds.reference.delete();
              _deleteBook(bookId);
            }
          });
        }
      });
      return 'success';
    } catch (e) {
      print(e);
      return 'fail';
    }
  }

  //Delete one transact
  deleteTransact(bookId, transactId) async {
    await _firestore
        .collection('users')
        .doc(UserDetails.uid)
        .collection('transact_books')
        .doc(bookId)
        .collection('transacts')
        .where('transactId', isEqualTo: transactId)
        .limit(1)
        .get()
        .then(
      (snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      },
    );
  }

  //  clear all transacts
  deleteAllTransacts(String bookId) async {
    await _firestore
        .collection('users')
        .doc(UserDetails.uid)
        .collection('transact_books')
        .doc(bookId)
        .collection('transacts')
        .get()
        .then(
      (snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      },
    );
  }
}
