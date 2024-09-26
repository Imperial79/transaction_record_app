import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/firebase_options.dart';
import 'package:transaction_record_app/screens/Splash%20Screen/splashUI.dart';
import 'package:transaction_record_app/screens/rootUI.dart';
import 'package:transaction_record_app/services/auth.dart';
import 'package:transaction_record_app/screens/loginUI.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:upgrader/upgrader.dart';
import 'Utility/newColors.dart';

ValueNotifier<String> themeMode = ValueNotifier("system");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  ConnectionConfig.listenForConnection();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    setSystemUIColors(context);
    return ValueListenableBuilder(
      valueListenable: themeMode,
      builder: (context, theme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Transact Record',
          color: Colors.white,
          themeMode: theme == "light"
              ? ThemeMode.light
              : theme == "dark"
                  ? ThemeMode.dark
                  : ThemeMode.system,
          theme: KThemeData.light(),
          darkTheme: KThemeData.dark(),
          home: UpgradeAlert(
            child: FutureBuilder(
              future: AuthMethods.getCurrentuser(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return RootUI();
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return SplashUI();
                } else if (snapshot.connectionState == ConnectionState.none) {
                  return SplashUI();
                } else {
                  return LoginUI();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
