import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore get firestore => FirebaseFirestore.instance;

class DatabaseMethods {
  // final firestore = FirebaseFirestore.instance;

  //  upload new transact book
  Future<void> createNewTransactBook(String bookId, newBookMap) async {
    return await firestore
        .collection('transactBooks')
        .doc(bookId)
        .set(newBookMap);
  }

  //Adding user to database QUERY
  Future<void> addUserInfoToDB({
    required String uid,
    required Map<String, dynamic> userMap,
  }) async {
    return await firestore.collection("users").doc(uid).set(userMap);
  }

  //  UPDATE TRANSACTS
  updateTransacts(
      String bookId, transactId, Map<String, dynamic> transactMap) async {
    await firestore
        .collection('transactBooks')
        .doc(bookId)
        .collection('transacts')
        .doc(transactId)
        .update(transactMap);
  }

  //Uploading transactions to database QUERY
  uploadTransacts(transactMap, bookId, transactId) async {
    await firestore
        .collection("transactBooks")
        .doc(bookId)
        .collection('transacts')
        .doc(transactId)
        .set(transactMap);
  }

  //  UPDATE account details
  Future<String> updateAccountDetails(
      String uid, Map<String, dynamic> accountDetails) async {
    try {
      await firestore.collection('users').doc(uid).update(accountDetails);
      return 'Profile updated successfully';
    } catch (e) {
      return e.toString();
    }
  }

  //  Update BOOK transactions
  updateBookTransactions(String bookId, Map<String, dynamic> newMap) async {
    return await firestore
        .collection('transactBooks')
        .doc(bookId)
        .update(newMap);
  }

  //  Update global CURRENT BALANCE
  updateGlobalCurrentBal(String uid, Map<String, dynamic> currentBalMap) async {
    return await firestore.collection('users').doc(uid).update(currentBalMap);
  }

  //  Reset Book Income/Expense
  resetBookIncomeExpense(String bookId, uid, map) async {
    return await firestore.collection('transactBooks').doc(bookId).update(map);
  }

  //  Reset Book Income/Expense
  resetGlobalIncomeExpense(
      String bookId, String uid, Map<Object, Object> map) async {
    return await firestore.collection('users').doc(uid).update(map);
  }

  //Delete one book
  _deleteBook(bookId) async {
    await firestore
        .collection('transactBooks')
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
      await firestore
          .collection('transactBooks')
          .doc(bookId)
          .collection('transacts')
          .limit(1)
          .get()
          .then((value) async {
        if (value.docs.isEmpty) {
          _deleteBook(bookId);
        } else {
          await firestore
              .collection('transactBooks')
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
      return 'fail';
    }
  }

  //Delete one transact
  deleteTransact(bookId, transactId) async {
    await firestore
        .collection('transactBooks')
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
    await firestore
        .collection('transactBooks')
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
