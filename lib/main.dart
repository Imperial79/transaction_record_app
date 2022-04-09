import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:transaction_record_app/colors.dart';
import 'package:transaction_record_app/homeUi.dart';
import 'package:transaction_record_app/services/auth.dart';
import 'package:transaction_record_app/signInUi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      statusBarBrightness: Brightness.dark,
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transact Record',
      color: primaryColor,
      theme: ThemeData(
        fontFamily: 'San',
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.teal,
      ),
      home: FutureBuilder(
        future: AuthMethods().getCurrentuser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomeUi();
          } else {
            return SignInUi();
          }
        },
      ),
    );
  }
}
