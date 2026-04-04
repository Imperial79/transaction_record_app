import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart'; // Required for StateProvider in Riverpod 3.x
import 'package:transaction_record_app/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:transaction_record_app/utility/constants.dart';
import 'package:transaction_record_app/services/database.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);
final homePageProvider = StateProvider<int>((ref) => 0);

final pageControllerProvider = Provider(
  (ref) => PageController(initialPage: 0, keepPage: true),
);

final authrepositories = Provider((ref) => AuthRepo());
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return firebaseAuth.authStateChanges();
});

final authFuture = FutureProvider((ref) async {
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
  }
});

const List<String> scopes = <String>['email', 'profile', 'openid'];

class AuthRepo {
  static final DatabaseMethods _databaseMethods = DatabaseMethods();
  static final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  AuthRepo() {
    _initialize();
  }

  void _initialize() {
    unawaited(
      _googleSignIn.initialize(
        serverClientId:
            "621632578553-am88nb3bho0nsm4vtu2ugp4fjibq1dgr.apps.googleusercontent.com",
      ),
    );
  }

  Future<User?> getCurrentuser() async {
    return auth.currentUser;
  }

  Stream<User?> ifAuthStateChange() {
    return auth.authStateChanges();
  }

  Future<User?> _handleGoogleSignIn() async {
    StreamSubscription<GoogleSignInAuthenticationEvent>? subscription;
    try {
      // Initiate authentication (replaces signIn in 7.0.0+)
      // Note: authenticate() does not return the user. We must listen for the event.
      final completer = Completer<GoogleSignInAuthenticationEvent?>();
      subscription = _googleSignIn.authenticationEvents.listen((event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          if (!completer.isCompleted) completer.complete(event);
        }
      });

      await _googleSignIn.authenticate();

      final event = await completer.future.timeout(
        const Duration(minutes: 1),
        onTimeout: () => null,
      );

      if (event == null || event is! GoogleSignInAuthenticationEventSignIn) {
        log("Google Sign-In Error: No sign-in event received or timeout");
        return null;
      }

      final GoogleSignInAccount googleAccount = event.user;
      final GoogleSignInAuthentication googleSignInAuthentication =
          googleAccount.authentication;

      final String? idToken = googleSignInAuthentication.idToken;

      // Get accessToken via authorizationClient
      final authorization = await googleAccount.authorizationClient
          .authorizationForScopes(scopes);
      final String? accessToken = authorization?.accessToken;

      if (idToken == null) {
        log("Error: idToken is null");
        return null;
      }

      final AuthCredential authCred = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      UserCredential creds = await auth.signInWithCredential(authCred);

      return creds.user;
    } catch (e) {
      log("Google Sign-In Error: $e");
      return null;
    } finally {
      await subscription?.cancel();
    }
  }

  Future<UserModel?> signIn() async {
    try {
      User? gUserData = await _handleGoogleSignIn();
      UserModel? finalUser;
      if (gUserData != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(gUserData.uid)
            .get();

        final dbUser = userDoc.data();

        if (dbUser != null) {
          // User already exists
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
            uid: finalUser.uid,
            userMap: finalUser.toMap(),
          );
        }
        log("$finalUser");
      }
      return finalUser;
    } catch (e) {
      log("SignIn Error: $e");
      rethrow;
    }
  }

  Future<bool> signOut() async {
    try {
      final userBox = await Hive.openBox('USERBOX');
      await userBox.delete('userData');

      await Hive.deleteBoxFromDisk('USERBOX');
      await Hive.close();

      await _googleSignIn.disconnect();
      await auth.signOut();
      return true;
    } catch (e) {
      log("SignOut Error: $e");
      rethrow;
    }
  }
}
