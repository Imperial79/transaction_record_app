import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:transaction_record_app/Functions/navigatorFns.dart';
import 'package:transaction_record_app/models/userModel.dart';
import 'package:transaction_record_app/screens/loginUI.dart';
import 'package:transaction_record_app/screens/rootUI.dart';
import 'package:transaction_record_app/services/user.dart';
import 'package:transaction_record_app/services/database.dart';

class AuthMethods {
  DatabaseMethods databaseMethods = new DatabaseMethods();

  static final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentuser() async {
    return await auth.currentUser;
  }

  static Stream<User?> ifAuthStateChange() {
    return auth.authStateChanges();
  }

  Future<String> signInWithgoogle(context) async {
    try {
      // final res = await Hive.boxExists('USERBOX');
      // if (res) {
      //   log("USERBOX exists");
      //   await Hive.deleteBoxFromDisk('USERBOX').then((value) async {
      //     log("USERBOX deleted from disk");
      //   });
      // } else {
      //   log("USERBOX does not exists");
      // }
      // await Hive.openBox('USERBOX').then((value) {
      //   log("Hive Box USERBOX created/Opened");
      // });
      await Hive.close();
      await Hive.openBox('USERBOX');
      final _userBox = Hive.box('USERBOX');

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
              log("User found in DB");
              log("User Data from DB---------------> ");
              log("UID-> ${dbUser.data()!['uid']}");
              log("NAME-> ${dbUser.data()!['name']}");
              log("EMAIL-> ${dbUser.data()!['email']}");
              log("Doing nothing if user exists");
              // ----------------------------------------------------------------------------

              KUser newUser = new KUser(
                username: dbUser.data()!['email']!.split('@').first,
                email: dbUser.data()!['email']!,
                name: dbUser.data()!['name']!,
                uid: dbUser.data()!['uid'],
                imgUrl: gUserData.photoURL!,
              );
              log("User Model Data-> ${newUser}");

              await _userBox.put('userData', newUser.toMap()).whenComplete(() {
                print(
                    'After updating data to Hive----------------------------->');
              });

              //  Saving in local session ------->

              // UserDetails.email = newUser.email;
              // UserDetails.name = newUser.name;
              // UserDetails.username = newUser.username;
              // UserDetails.uid = newUser.uid;
              // UserDetails.imgUrl = newUser.imgUrl;

              globalUser = newUser;

              log("Checking for the User in DB");

              // UserDetails.userDisplayName = value.data()!['name'];
              // userData.copyWith(userDisplayName: UserDetails.userDisplayName);
              // log("After Changing the Display Name-> ${userData.toMap()}");

              // userMap.update('name', (value) => UserDetails.userDisplayName);
              // await newUser.copyWith()
              await _userBox.put('userData', newUser.toMap());

              NavPushReplacement(context, RootUI());
            } else {
              log("User Does not exists in the DB");
              log("User Data to put in DB---------------------->");
              // log("UID-> ${newUser.uid}");
              // log("NAME-> ${newUser.name}");
              // log("EMAIL-> ${newUser.email}");
              log("Google User is not null");
              KUser newUser = new KUser(
                username: gUserData.email!.split('@').first,
                email: gUserData.email!,
                name: gUserData.displayName!,
                uid: gUserData.uid,
                imgUrl: gUserData.photoURL!,
              );
              log("User Model Data-> ${newUser}");

              await _userBox.put('userData', newUser.toMap()).whenComplete(() {
                print(
                    'After updating data to Hive----------------------------->');
              });

              //  Saving in local session ------->

              // UserDetails.email = newUser.email;
              // UserDetails.name = newUser.name;
              // UserDetails.username = newUser.username;
              // UserDetails.uid = newUser.uid;
              // UserDetails.imgUrl = newUser.imgUrl;
              globalUser = newUser;

              log("Checking for the User in DB");
              await databaseMethods
                  .addUserInfoToDB(newUser.uid, newUser.toMap())
                  .then(
                (value) {
                  NavPushReplacement(context, RootUI());
                },
              );
            }
          },
        );
        return 'success';
      }
      return 'fail';
    } catch (e) {
      await Hive.close();
      print(e);
      return 'fail';
    }
  }

  static signOut(BuildContext context) async {
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
