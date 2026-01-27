import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  runApp(ProviderScope(
    child: const MyApp(),
    retry: (retryCount, error) {
      return null;
    },
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    setSystemUIColors(context);

    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return UpgradeAlert(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Transact Record',
        color: Colors.white,
        themeMode: themeMode,
        theme: KThemeData.light(),
        darkTheme: KThemeData.dark(),
        routerConfig: goRouter,
        themeAnimationDuration: const Duration(milliseconds: 500),
        themeAnimationCurve: Curves.easeInOut,
      ),
    );
  }
}
