import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/core/pages/book_detail/detail_view.dart';
import "package:riverpod_annotation/riverpod_annotation.dart";
import 'package:go_router/go_router.dart';

import '../screens/chat.dart';
import '../screens/home.dart';
import '../screens/login.dart';

part 'router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    // navigatorKey: _key,
    debugLogDiagnostics: true,
    initialLocation: DetailView.routeLocation,
    routes: [
      GoRoute(
        path: DetailView.routeLocation,
        name: DetailView.routeName,
        builder: (context, state) {
          return const DetailView();
        },
      ),
      GoRoute(
        path: HomePage.routeLocation,
        name: HomePage.routeName,
        builder: (context, state) {
          return const HomePage();
        },
      ),
      GoRoute(
        path: LoginPage.routeLocation,
        name: LoginPage.routeName,
        builder: (context, state) {
          return const LoginPage();
        },
      ),
    ],
    redirect: (context, state) {
      // If our async state is loading, don't perform redirects, yet
      // if (authState.isLoading || authState.hasError) return null;

      // // Here we guarantee that hasData == true, i.e. we have a readable value

      // // This has to do with how the FirebaseAuth SDK handles the "log-in" state
      // // Returning `null` means "we are not authorized"
      // final isAuth = authState.valueOrNull != null;

      // final isSplash = state.location == SplashPage.routeLocation;
      // if (isSplash) {
      //   return isAuth ? HomePage.routeLocation : LoginPage.routeLocation;
      // }

      // final isLoggingIn = state.location == LoginPage.routeLocation;
      // if (isLoggingIn) return isAuth ? HomePage.routeLocation : null;

      // return isAuth ? null : SplashPage.routeLocation;
      return HomePage.routeLocation;
    },
  );
}
