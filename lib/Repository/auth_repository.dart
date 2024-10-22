import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaction_record_app/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/services/database.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authRepository = Provider(
  (ref) => AuthRepo(),
);

final auth = FutureProvider(
  (ref) async {
    final res = FirebaseAuth.instance.currentUser;
    if (res != null) {
      final user = await FirebaseFirestore.instance
          .collection("users")
          .doc(res.uid)
          .get();
      if (user.data() != null) {
        UserModel userdata = UserModel.fromMap(user.data()!);
        ref.read(userProvider.notifier).state = userdata;
      }

      log("Found User ${res.email} - ${res.uid}");
    } else {
      log("No User data found");
    }
  },
);

class AuthRepo {
  static final DatabaseMethods _databaseMethods = DatabaseMethods();

  static final FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?> getCurrentuser() async {
    return auth.currentUser;
  }

  Stream<User?> ifAuthStateChange() {
    return auth.authStateChanges();
  }

  static Future<User?> _googleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      await auth.signOut();

      await googleSignIn.signOut();

      final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleAccount!.authentication;

      final AuthCredential authCred = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      UserCredential creds = await auth.signInWithCredential(authCred);

      User? gUserData = creds.user;
      return gUserData;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> signIn() async {
    try {
      // await Hive.openBox('USERBOX');
      // final userBox = Hive.box('USERBOX');

      User? gUserData = await _googleSignIn();
      UserModel? finalUser;
      if (gUserData != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(gUserData.uid)
            .get()
            .then(
          (user) async {
            final dbUser = user.data();

            if (dbUser != null) {
              // User already exist

              finalUser = UserModel(
                username: dbUser['username'],
                email: dbUser['email'],
                name: dbUser['name'],
                uid: dbUser['uid'],
                imgUrl: gUserData.photoURL ?? dbUser['imgUrl'],
              );
            } else {
              // New User

              finalUser = UserModel(
                username: Constants.getUsername(email: gUserData.email!),
                email: gUserData.email!,
                name: gUserData.displayName!,
                uid: gUserData.uid,
                imgUrl: gUserData.photoURL!,
              );

              await _databaseMethods.addUserInfoToDB(
                uid: finalUser!.uid,
                userMap: finalUser!.toMap(),
              );
            }

            // await userBox.put('userData', finalUser.toMap());
            log("$finalUser");
          },
        );
      }
      return finalUser;
    } catch (e) {
      // await Hive.close();
      rethrow;
      // return null;
    }
  }

  Future<bool> signOut() async {
    try {
      final userBox = await Hive.openBox('USERBOX');
      userBox.delete('userData');

      await Hive.deleteBoxFromDisk('USERBOX');
      await Hive.close();
      await GoogleSignIn().signOut();

      await auth.signOut();
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
