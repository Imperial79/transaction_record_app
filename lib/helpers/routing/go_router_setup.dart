import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_record_app/repositories/auth_repository.dart';
import 'package:transaction_record_app/models/bookModel.dart';
import 'package:transaction_record_app/screens/book/regular_book_screen.dart';
import 'package:transaction_record_app/screens/login_screen.dart';
import 'package:transaction_record_app/screens/splash/splash_screen.dart';
import 'package:transaction_record_app/screens/migrate_screen.dart';
import 'package:transaction_record_app/screens/root_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authFuture);
  final user = ref.watch(userProvider);

  return GoRouter(
    initialLocation: '/root',
    redirect: (context, state) {
      if (authState.isLoading) return '/splash';
      if (user == null && state.fullPath != '/login') return '/login';
      if (user != null && state.fullPath == '/login') return '/root';

      log("NAVIGATING TO: ${state.fullPath}");
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/root', builder: (context, state) => const RootScreen()),
      GoRoute(
        path: '/book/:type/:bookId',
        builder: (context, state) {
          final bookData = state.extra as BookModel;
          return RegularBookScreen(bookData: bookData);
        },
      ),
      GoRoute(
        path: '/migrate/:id',
        builder: (context, state) =>
            MigrateScreen(id: state.pathParameters["id"] ?? ""),
      ),
    ],
  );
});
