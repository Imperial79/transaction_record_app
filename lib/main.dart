import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Repository/system_repository.dart';
import 'package:transaction_record_app/firebase_options.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:upgrader/upgrader.dart';
import 'Helper/Route_Helper/go_router_setup.dart';
import 'Utility/newColors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox('hiveBox');
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final Map _themeMap = {
    "Light": ThemeMode.light,
    "Dark": ThemeMode.dark,
    "System": ThemeMode.system,
  };
  @override
  void initState() {
    super.initState();
    _getThemeDataFromHive();
  }

  Future<void> _getThemeDataFromHive() async {
    ref.read(hiveThemeFuture);
  }

  @override
  Widget build(BuildContext context) {
    setSystemUIColors(context);

    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return UpgradeAlert(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Transact Record',
        color: Colors.white,
        themeMode: _themeMap[themeMode],
        theme: KThemeData.light(),
        darkTheme: KThemeData.dark(),
        routerConfig: goRouter,
      ),
    );
  }
}
