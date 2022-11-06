import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/loginUI.dart';
import 'package:transaction_record_app/screens/Home%20Screens/homeUi.dart';
import 'package:transaction_record_app/services/user.dart';
import 'package:transaction_record_app/services/database.dart';

//creating an instance of Firebase Authentication
class AuthMethods {
  DatabaseMethods databaseMethods = new DatabaseMethods();

  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentuser() async {
    return await auth.currentUser;
  }

  Future<String> signInWithgoogle(context) async {
    try {
      await Hive.openBox('User');
      final _UserBox = Hive.box('User');
      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      final GoogleSignIn _googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      final GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication!.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      UserCredential result =
          await _firebaseAuth.signInWithCredential(credential);

      User? userDetails = result.user;

      // final SharedPreferences prefs = await _prefs;

      Map<String, dynamic> userMap = {
        'uid': userDetails!.uid,
        "email": userDetails.email,
        "username": userDetails.email!.split('@').first,
        "name": userDetails.displayName,
        "imgUrl": userDetails.photoURL,
      };

      await _UserBox.put('userMap', userMap).whenComplete(() {
        print('Data Saved locally!');
      });

      //  Svaing in local session ------->

      UserDetails.userEmail = userDetails.email!;
      UserDetails.userDisplayName = userDetails.displayName!;
      UserDetails.userName = userDetails.email!.split('@').first;
      UserDetails.uid = userDetails.uid;
      UserDetails.userProfilePic = userDetails.photoURL!;

      FirebaseFirestore.instance
          .collection('users')
          .doc(userDetails.uid)
          .get()
          .then(
        (value) {
          if (value.exists) {
            UserDetails.userDisplayName = value.data()!['name'];
            userMap.update('name', (value) => UserDetails.userDisplayName);
            _UserBox.put('userMap', userMap);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeUi()));
          } else {
            Map<String, dynamic> userInfoMap = {
              'uid': userDetails.uid,
              "email": userDetails.email,
              "username": userDetails.email!.split('@').first,
              "name": userDetails.displayName,
              "imgUrl": userDetails.photoURL,
              'income': 0,
              'expense': 0,
              'currentBalance': 0,
            };
            databaseMethods.addUserInfoToDB(userDetails.uid, userInfoMap).then(
              (value) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => HomeUi()));
              },
            );
          }
        },
      );
      return 'success';
    } catch (e) {
      print(e);
      return 'fail';
    }
  }

  signOut(BuildContext context) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();

    await Hive.openBox('userData');
    Hive.box('userData').delete('userMap');
    await auth.signOut();
    NavPushReplacement(context, LoginUI());
    // Navigator.popUntil(context, (route) => false);
  }
}
