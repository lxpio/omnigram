import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/components/root_layout.dart';
import 'package:omnigram/providers/user/user_model.dart';
import 'package:omnigram/screens/discover/discover_small_screen.dart';
import 'package:omnigram/screens/manager/manger_small_screen.dart';

import 'package:omnigram/screens/chat/chat_page_screen.dart';
import 'package:omnigram/screens/chat/models/conversation.dart';

import 'package:omnigram/screens/coming_soon.dart';
import 'package:omnigram/screens/reader/models/book_model.dart';
import 'package:omnigram/screens/reader/read_epub_screen.dart';
import 'package:omnigram/screens/reader/reader_mobile_screen.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:go_router/go_router.dart';

import '../screens/chat/chat_home_screen.dart';
import '../screens/home/home_small_screen.dart';
import '../screens/login_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final isAuth = ref.watch(userProvider).logined;

  return GoRouter(
    // navigatorKey: _key,
    debugLogDiagnostics: true,
    initialLocation: kHomePath,
    // initialLocation: '$kChatPath/$kChatPagePath',
    routes: [
      GoRoute(
        path: kLoginPath,
        name: kLoginPage,
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: kHomePath,
        name: kHomePage,
        pageBuilder: (context, state) => const MaterialPage(
          // key: _pageKey,
          child: RootLayout(
            // key: _scaffoldKey,
            currentIndex: 0,
            child: HomeSmallScreen(),
          ),
        ),
      ),
      GoRoute(
        path: kSummaryPath,
        name: kSummaryPage,
        pageBuilder: (context, state) {
          final book = state.extra as BookModel;
          return MaterialPage(
            // key: _pageKey,
            child: ReaderMobileScreen(
              book: book,
            ),
          );
        },
        // routes: [],
      ),
      GoRoute(
        path: kReaderDetailPath,
        name: kReaderDetailPage,
        pageBuilder: (context, GoRouterState state) {
          // final bookPath = state.extra as String;

          final args = state.extra == null ? false : state.extra as bool;

          return MaterialPage(
            child: ReadEpubScreen(playtask: args),
          );
        },
      ),
      GoRoute(
        path: kDiscoverPath,
        name: kDiscoverPage,
        pageBuilder: (context, state) => const MaterialPage(
          // key: _pageKey,
          child: RootLayout(
            // key: _scaffoldKey,
            currentIndex: 1,
            child: DiscoverSmallScreen(),
          ),
        ),
      ),
      GoRoute(
        path: kChatPath,
        name: kChatPage,
        pageBuilder: (context, state) => const MaterialPage(
          // key: _pageKey,
          child: RootLayout(
            // key: _scaffoldKey,
            currentIndex: 2,
            child: ChatHomeScreen(),
          ),
        ),
        routes: [
          GoRoute(
            path: kChatPagePath,
            name: kChatPagePath,
            pageBuilder: (context, state) {
              final Conversation conversation = state.extra is Conversation
                  ? state.extra as Conversation
                  : Conversation();

              return MaterialPage(
                child: ChatPageScreen(conversation: conversation),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: kManagerPath,
        name: kManagerPage,
        pageBuilder: (context, state) => const MaterialPage(
          // key: _pageKey,
          child: RootLayout(
            // key: _scaffoldKey,
            currentIndex: 3,
            child: ManagerSmallScreen(),
          ),
        ),
      ),
      GoRoute(
        path: kProfilePath,
        name: kProfilePage,
        pageBuilder: (context, state) => const MaterialPage(
          // key: _pageKey,
          child: RootLayout(
            // key: _scaffoldKey,
            currentIndex: 3,
            child: PhotoPageBody(),
          ),
        ),
      ),
    ],
    redirect: (context, state) {
      // If our async state is loading, don't perform redirects, yet
      // if (authState.isLoading || authState.hasError) return null;

      // // Here we guarantee that hasData == true, i.e. we have a readable value

      // // This has to do with how the FirebaseAuth SDK handles the "log-in" state
      // // Returning `null` means "we are not authorized"
      // final isAuth = authState.valueOrNull != null;

      final isSplash = state.fullPath == kSplashPath;

      if (isSplash) {
        return isAuth ? kHomePath : kLoginPath;
      }

      final isLoggingIn = state.fullPath == kLoginPath;
      if (isLoggingIn) return isAuth ? kHomePath : null;

      // return isAuth ? null : SplashPage.routeLocation;
      // return kHomePath;
      return isAuth ? null : kLoginPath;
    },
  );
});
