import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaction_record_app/helpers/routing/go_router_setup.dart';
import 'package:transaction_record_app/repositories/system_repository.dart';
import 'package:transaction_record_app/firebase_options.dart';
import 'package:transaction_record_app/utility/components.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'utility/newColors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox('hiveBox');
  runApp(
    ProviderScope(
      child: const MyApp(),
      retry: (retryCount, error) {
        return null;
      },
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Transact Record',
          themeMode: themeMode,
          theme: KThemeData.light(dynamicColorScheme: lightDynamic),
          darkTheme: KThemeData.dark(dynamicColorScheme: darkDynamic),
          routerConfig: goRouter,
          themeAnimationDuration: const Duration(milliseconds: 300),
          themeAnimationCurve: Curves.easeInOut,
          builder: (context, child) {
            setSystemUIColors(context);
            return child!;
          },
        );
      },
    );
  }
}
