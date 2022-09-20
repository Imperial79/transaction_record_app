import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transaction_record_app/services/user.dart';

class DatabaseMethods {
  final userRef =
      FirebaseFirestore.instance.collection('users').doc(UserDetails.uid);
  //  upload new transact book
  createNewTransactBook(String bookId, newBookMap) async {
    return await userRef
        .collection('transact_books')
        .doc(bookId)
        .set(newBookMap);
  }

  //Adding user to database QUERY
  addUserInfoToDB(String uid, Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set(userInfoMap);
  }

  //  UPDATE TRANSACTS
  updateTransacts(String bookId, transactId, transactMap) async {
    await userRef
        .collection('transact_books')
        .doc(bookId)
        .collection('transacts')
        .doc(transactId)
        .update(transactMap);
  }

  //Uploading transactions to database QUERY
  uploadTransacts(uid, transactMap, bookId, transactId) async {
    await userRef
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
      await userRef.update(accountDetails);
      return 'Profile updated successfully';
    } catch (e) {
      return e.toString();
    }
  }

  //  Update BOOK transactions
  updateBookTransactions(String bookId, Map<String, dynamic> newMap) async {
    return await userRef
        .collection('transact_books')
        .doc(bookId)
        .update(newMap);
  }

  //  Update global CURRENT BALANCE
  updateGlobalCurrentBal(String uid, Map<String, dynamic> currentBalMap) async {
    return await userRef.update(currentBalMap);
  }

  //  Reset Book Income/Expense
  resetBookIncomeExpense(String bookId, uid, map) async {
    return await userRef.collection('transact_books').doc(bookId).update(map);
  }

  //  Reset Book Income/Expense
  resetGlobalIncomeExpense(String bookId, uid, map) async {
    return await userRef.update(map);
  }

  //Delete all transacts
  Future deleteTransact(String uid, bookId, transactId) async {
    return await userRef
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
