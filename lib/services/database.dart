import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  //Adding user to database QUERY
  addUserInfoToDB(String userId, Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set(userInfoMap);
  }

  //Uploading transactions to database QUERY
  uploadTransacts(uid, transactMap) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("transacts")
        .add(transactMap);
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
