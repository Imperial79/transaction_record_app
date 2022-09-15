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
  addUserInfoToDB(String userId, Map<String, dynamic> userInfoMap) async {
    return await _firestore.collection("users").doc(userId).set(userInfoMap);
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
        .collection("users")
        .doc(uid)
        .collection("transact_books")
        .doc(bookId)
        .collection('transacts')
        .doc(transactId)
        .set(transactMap);
  }

  //Set Balance
  setBalance(String username, Map<String, String> balanceMap) {
    _firestore
        .collection("users")
        .doc(username)
        .collection("CurrentBalance")
        .doc('balance')
        .set(balanceMap);
  }

  //get balance
  getBalance(String username) async {
    return await _firestore
        .collection("users")
        .doc(username)
        .collection("CurrentBalance")
        .doc('balance')
        .snapshots();
  }

  //fetching transactions from database
  getTransacts(String username) async {
    return await _firestore
        .collection("users")
        .doc(username)
        .collection("transacts")
        .orderBy("date", descending: true)
        .snapshots();
  }

  //Delete all transacts
  deleteAllTransacts(String username) async {
    return await _firestore
        .collection('users')
        .doc(username)
        .collection('transacts')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  //  UPDATE account details
  Future<String> updateAccountDetails(
      String uid, Map<String, dynamic> accountDetails) async {
    try {
      await _firestore.collection('users').doc(uid).update(accountDetails);
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
    return await _firestore.collection('users').doc(uid).update(currentBalMap);
  }

  //  Reset Book Income/Expense
  resetBookIncomeExpense(String bookId, uid, map) async {
    return await _firestore
        .collection('users')
        .doc(uid)
        .collection('transact_books')
        .doc(bookId)
        .update(map);
  }

  //  Reset Book Income/Expense
  resetGlobalIncomeExpense(String bookId, uid, map) async {
    return await _firestore.collection('users').doc(uid).update(map);
  }

  //Delete all transacts
  Future deleteTransact(String uid, bookId, transactId) async {
    return await _firestore
        .collection('users')
        .doc(uid)
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
}
