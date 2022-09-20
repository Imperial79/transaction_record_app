import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:transaction_record_app/colors.dart';
import 'package:transaction_record_app/screens/Home%20Screens/homeUi.dart';
import 'package:transaction_record_app/services/auth.dart';
import 'package:transaction_record_app/loginUI.dart';
import 'package:transaction_record_app/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top]);

    setSystemUIColors();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transact Record',
      color: Colors.white,
      theme: ThemeData(
        fontFamily: 'Product',
        useMaterial3: true,
        scaffoldBackgroundColor: bgColor,
        colorSchemeSeed: primaryColor,
      ),
      home: FutureBuilder(
        future: AuthMethods().getCurrentuser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomeUi();
          } else {
            return LoginUI();
          }
        },
      ),
    );
  }
}
