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
import 'package:transaction_record_app/services/user.dart';
import 'package:transaction_record_app/services/database.dart';

class AuthMethods {
  static DatabaseMethods _databaseMethods = new DatabaseMethods();

  static final FirebaseAuth auth = FirebaseAuth.instance;

  static Future<User?> getCurrentuser() async {
    return await auth.currentUser;
  }

  static Stream<User?> ifAuthStateChange() {
    return auth.authStateChanges();
  }

  static Future<void> switchAccount(BuildContext context) async {
    // await Hive
    final userBox = await Hive.openBox('USERBOX');
    userBox.delete('userData');

    await Hive.deleteBoxFromDisk('USERBOX').then((value) {
      log("Box USER deleted from disk");
    });
    await Hive.close();
    await signInWithgoogle(context);
  }

  static Future<String> signInWithgoogle(BuildContext context) async {
    try {
      await Hive.openBox('USERBOX');
      final _userBox = Hive.box('USERBOX');

      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      final GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication!.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      UserCredential _creds =
          await _firebaseAuth.signInWithCredential(credential);

      User? gUserData = _creds.user;

      log("-----------------GOOGLE SIGNIN--------------------");
      if (gUserData != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(gUserData.uid)
            .get()
            .then(
          (dbUser) async {
            if (dbUser.exists) {
              KUser oldUser = new KUser(
                username: dbUser.data()!['username'],
                email: dbUser.data()!['email']!,
                name: dbUser.data()!['name']!,
                uid: dbUser.data()!['uid'],
                imgUrl: gUserData.photoURL!,
              );

              await _userBox.put('userData', oldUser.toMap());

              globalUser = oldUser;
            } else {
              KUser newUser = new KUser(
                username: Constants.getUsername(email: gUserData.email!),
                email: gUserData.email!,
                name: gUserData.displayName!,
                uid: gUserData.uid,
                imgUrl: gUserData.photoURL!,
              );

              await _userBox.put('userData', newUser.toMap());

              globalUser = newUser;
              await _databaseMethods.addUserInfoToDB(
                  newUser.uid, newUser.toMap());
            }

            NavPushReplacement(context, RootUI());
          },
        );
        return 'success';
      }
      return 'fail';
    } catch (e) {
      await Hive.close();
      log("Error while google sigin-> $e");
      return 'fail';
    }
  }

  static Future<void> signOut(BuildContext context) async {
    log("<-------------------------SIGNOUT FUNCTION---------------------------------->");
    final userBox = await Hive.openBox('USERBOX');
    userBox.delete('userData');

    await Hive.deleteBoxFromDisk('USERBOX').then((value) {
      log("Box USER deleted from disk");
    });
    await Hive.close();
    await GoogleSignIn().signOut().then((value) {
      log("Logged Out from GoggleSignIn");
    });

    await auth.signOut().then((value) {
      log("Logged Out from Auth");
    });
    NavPushReplacement(context, LoginUI());
  }
}
