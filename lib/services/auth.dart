import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/loginUI.dart';
import 'package:transaction_record_app/screens/Home%20Screens/homeUi.dart';
import 'package:transaction_record_app/services/user.dart';
import 'package:transaction_record_app/services/database.dart';
import 'package:transaction_record_app/screens/Transact%20Screens/setBalanceUi.dart';

//creating an instance of Firebase Authentication
class AuthMethods {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentuser() async {
    return await auth.currentUser;
  }

  Future<String> signInWithgoogle(context) async {
    try {
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

      final SharedPreferences prefs = await _prefs;

      prefs.setString('USERKEY', userDetails!.uid);
      prefs.setString('USERNAMEKEY', userDetails.email!.split('@').first);
      prefs.setString('USERDISPLAYNAMEKEY', userDetails.displayName!);
      prefs.setString('USEREMAILKEY', userDetails.email!);
      prefs.setString('USERPROFILEKEY', userDetails.photoURL!);

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
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SetBalanceUi()));
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
    print('object');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await auth.signOut();
    NavPushReplacement(context, LoginUI());
  }
}
