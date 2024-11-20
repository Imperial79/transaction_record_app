import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/screens/Login_UI.dart';
import 'package:transaction_record_app/screens/Splash%20Screen/splashUI.dart';
import 'package:transaction_record_app/screens/migrateUI.dart';
import 'package:transaction_record_app/screens/rootUI.dart';

final goRouterProvider = Provider<GoRouter>(
  (ref) {
    final authState = ref.watch(authFuture);

    final user = ref.watch(userProvider);

    return GoRouter(
      initialLocation: '/home',
      redirect: (context, state) {
        // Show splash screen until initialization is complete.
        if (authState.isLoading) {
          return '/splash';
        }

        // Redirect based on authentication state after initialization.

        if (user == null && state.fullPath != '/login') return '/login';
        if (user != null && state.fullPath == '/login') return '/home';

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashUI(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginUI(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const RootUI(),
        ),
        GoRoute(
          path: '/about/:id',
          builder: (context, state) =>
              MigrateUI(id: state.pathParameters["id"] ?? "No Params"),
        ),
      ],
    );
  },
);
