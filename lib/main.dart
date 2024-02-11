import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/colors.dart';
import 'package:transaction_record_app/firebase_options.dart';
import 'package:transaction_record_app/screens/rootUI.dart';
import 'package:transaction_record_app/services/auth.dart';
import 'package:transaction_record_app/screens/loginUI.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:hive_flutter/hive_flutter.dart';

ValueNotifier<String> themeMode = ValueNotifier("system");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

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
          home: StreamBuilder(
            stream: AuthMethods.ifAuthStateChange(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return RootUI();
              } else {
                return LoginUI();
              }
            },
          ),
        );
      },
    );
  }
}
