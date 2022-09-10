import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transaction_record_app/services/user.dart';

class DatabaseMethods {
  //  upload new transact book
  createNewTransactBook(String bookId, newBookMap) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(UserDetails.uid)
        .collection('transact_books')
        .doc(bookId)
        .set(newBookMap);
  }

  //Adding user to database QUERY
  addUserInfoToDB(String userId, Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set(userInfoMap);
  }

  //  UPDATE TRANSACTS
  updateTransacts(String bookId, transactId, transactMap) async {
    await FirebaseFirestore.instance
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
    await FirebaseFirestore.instance
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
    FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .collection("CurrentBalance")
        .doc('balance')
        .set(balanceMap);
  }

  //get balance
  getBalance(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .collection("CurrentBalance")
        .doc('balance')
        .snapshots();
  }

  //fetching transactions from database
  getTransacts(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .collection("transacts")
        .orderBy("date", descending: true)
        .snapshots();
  }

  //Delete all transacts
  deleteAllTransacts(String username) async {
    return await FirebaseFirestore.instance
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

  //  Update BOOK transactions
  updateBookTransactions(String bookId, Map<String, dynamic> newMap) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(UserDetails.uid)
        .collection('transact_books')
        .doc(bookId)
        .update(newMap);
  }

  //  Update global CURRENT BALANCE
  updateGlobalCurrentBal(String uid, Map<String, dynamic> currentBalMap) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(currentBalMap);
  }

  //  Reset Book Income/Expense
  resetBookIncomeExpense(String bookId, uid, map) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transact_books')
        .doc(bookId)
        .update(map);
  }

  //  Reset Book Income/Expense
  resetGlobalIncomeExpense(String bookId, uid, map) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(map);
  }

  //Delete all transacts
  deleteTransact(String username, String date) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .collection('transacts')
        .where('date', isEqualTo: date)
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
