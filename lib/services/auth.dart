import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/models/userModel.dart';
import 'package:transaction_record_app/screens/loginUI.dart';
import 'package:transaction_record_app/screens/rootUI.dart';
import 'package:transaction_record_app/services/database.dart';
import 'package:transaction_record_app/services/user.dart';

class AuthMethods {
  static DatabaseMethods _databaseMethods = new DatabaseMethods();

  static final FirebaseAuth auth = FirebaseAuth.instance;

  static Future<User?> getCurrentuser() async {
    return auth.currentUser;
  }

  static Stream<User?> ifAuthStateChange() {
    return auth.authStateChanges();
  }

  static Future<User?> _googleSignIn() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn();

      await auth.signOut();

      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();

      final GoogleSignInAuthentication? googleSignInAuthentication =
          await googleAccount!.authentication;

      final AuthCredential authCred = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication!.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      UserCredential _creds = await auth.signInWithCredential(authCred);

      User? gUserData = _creds.user;
      return gUserData;
    } catch (e) {
      log("Google Sign In Error -> $e");
      return null;
    }
  }

  static Future<String> signIn(BuildContext context) async {
    try {
      await Hive.openBox('USERBOX');
      final _userBox = Hive.box('USERBOX');

      // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      // final GoogleSignIn _googleSignIn = GoogleSignIn();

      // await _googleSignIn.signOut();

      // final GoogleSignInAccount? googleSignInAccount =
      //     await _googleSignIn.signIn();

      // final GoogleSignInAuthentication? googleSignInAuthentication =
      //     await googleSignInAccount!.authentication;

      // final AuthCredential credential = GoogleAuthProvider.credential(
      //   idToken: googleSignInAuthentication!.idToken,
      //   accessToken: googleSignInAuthentication.accessToken,
      // );

      // UserCredential _creds =
      //     await _firebaseAuth.signInWithCredential(credential);

      User? gUserData = await _googleSignIn();

      if (gUserData != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(gUserData.uid)
            .get()
            .then(
          (user) async {
            final dbUser = user.data();
            late KUser _user;

            if (dbUser != null) {
              _user = new KUser(
                username: dbUser['username'],
                email: dbUser['email'],
                name: dbUser['name'],
                uid: dbUser['uid'],
                imgUrl: gUserData.photoURL ?? dbUser['imgUrl'],
              );

              // await _userBox.put('userData', oldUser.toMap());
            } else {
              _user = new KUser(
                username: Constants.getUsername(email: gUserData.email!),
                email: gUserData.email!,
                name: gUserData.displayName!,
                uid: gUserData.uid,
                imgUrl: gUserData.photoURL!,
              );

              // await _userBox.put('userData', newUser.toMap());

              await _databaseMethods.addUserInfoToDB(
                uid: _user.uid,
                userMap: _user.toMap(),
              );
            }
            await _userBox.put('userData', _user.toMap());

            NavPushReplacement(context, RootUI());
          },
        );
        return 'success';
      }
      return 'fail';
    } catch (e) {
      await Hive.close();
      log("Error handling user data-> $e");
      return 'fail';
    }
  }

  static Future<void> signOut(BuildContext context) async {
    final userBox = await Hive.openBox('USERBOX');
    userBox.delete('userData');

    await Hive.deleteBoxFromDisk('USERBOX');
    await Hive.close();
    await GoogleSignIn().signOut();

    await auth.signOut().then((value) {
      globalUser =
          KUser(username: '', email: '', name: '', uid: '', imgUrl: '');
    });
    NavPushReplacement(context, LoginUI());
  }
}
