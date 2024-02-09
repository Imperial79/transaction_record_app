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

      if (userDetails != null) {
        KUser userMap = new KUser(
          userName: userDetails.email!.split('@').first,
          userEmail: userDetails.email!,
          userDisplayName: userDetails.displayName!,
          uid: userDetails.uid,
          userProfilePic: userDetails.photoURL!,
        );

        await _UserBox.put('userMap', userMap.toMap()).whenComplete(() {
          print('Data Saved locally!-> ${userMap.toMap()}');
        });

        //  Svaing in local session ------->

        UserDetails.userEmail = userDetails.email!;
        UserDetails.userDisplayName = userDetails.displayName!;
        UserDetails.userName = userDetails.email!.split('@').first;
        UserDetails.uid = userDetails.uid;
        UserDetails.userProfilePic = userDetails.photoURL!;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDetails.uid)
            .get()
            .then(
          (value) async {
            if (value.exists) {
              UserDetails.userDisplayName = value.data()!['name'];
              userMap.copyWith(userDisplayName: UserDetails.userDisplayName);
              // userMap.update('name', (value) => UserDetails.userDisplayName);
              await _UserBox.put('userMap', userMap.toMap());

              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => RootUI()));
            } else {
              databaseMethods
                  .addUserInfoToDB(userDetails.uid, userMap.toMap())
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
      print(e);
      return 'fail';
    }
  }

  static signOut(BuildContext context) async {
    await Hive.openBox('userData');
    Hive.box('userData').delete('userMap');
    await GoogleSignIn().signOut();

    await auth.signOut();
    NavPushReplacement(context, LoginUI());
  }
}
