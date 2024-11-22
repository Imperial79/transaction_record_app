import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/screens/Book%20Screens/Regular_Book_UI.dart';
import 'package:transaction_record_app/screens/Login_UI.dart';
import 'package:transaction_record_app/screens/Splash%20Screen/splashUI.dart';
import 'package:transaction_record_app/screens/migrateUI.dart';
import 'package:transaction_record_app/screens/rootUI.dart';

final goRouterProvider = Provider<GoRouter>(
  (ref) {
    final authState = ref.watch(authFuture); // Authentication state
    final user = ref.watch(userProvider); // User data

    return GoRouter(
      initialLocation: '/root', // Set the initial route to root
      redirect: (context, state) {
        // Show splash screen while auth is loading
        if (authState.isLoading) {
          return '/splash';
        }
        // Redirect logic based on authentication state
        if (user == null && state.fullPath != '/login') return '/login';
        if (user != null && state.fullPath == '/login') return '/home';

        log("${state.fullPath}");
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
          path: '/root',
          builder: (context, state) => const RootUI(),
        ),
        // Book page route with deep link handling
        GoRoute(
          path: '/book/:type/:bookId',
          builder: (context, state) {
            final type = state.pathParameters["type"];
            final bookId = state.pathParameters["bookId"]!;
            switch (type) {
              case "regular":
                return Regular_Book_UI(bookId: bookId, bookType: type!);

              default:
                return Scaffold(
                  body: Center(
                    child: Text("No Page Found!"),
                  ),
                );
            }
          },
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
