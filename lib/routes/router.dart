import 'package:flutter/material.dart';
import 'package:omnigram/components/root_layout.dart';
import 'package:omnigram/providers/service/chat/conversation_model.dart';
import 'package:omnigram/providers/service/reader/book_model.dart';
import 'package:omnigram/screens/chat/chat_screen.dart';

import 'package:omnigram/screens/photo.dart';
import 'package:omnigram/screens/reader/reader_mobile_screen.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:go_router/go_router.dart';

import '../screens/chat/chat.dart';
import '../screens/home/home_small_screen.dart';
import '../screens/login.dart';

// part 'router.g.dart';

// const _pageKey = ValueKey('_pageKey');

// const _scaffoldKey = ValueKey('_scaffoldKey');

// @riverpod
GoRouter appRouter() {
  return GoRouter(
    // navigatorKey: _key,
    debugLogDiagnostics: true,
    initialLocation: kHomePath,
    routes: [
      GoRoute(
        path: kHomePath,
        name: kHomePage,
        pageBuilder: (context, state) => const MaterialPage(
          // key: _pageKey,
          child: RootLayout(
            // key: _scaffoldKey,
            currentIndex: 0,
            child: ReaderSmallScreen(),
          ),
        ),
      ),
      GoRoute(
        path: kReaderPath,
        name: kReaderPage,
        pageBuilder: (context, state) {
          final Book book = state.extra as Book;

          return MaterialPage(
            // key: _pageKey,
            child: ReaderMobileScreen(
              book: book,
            ),
          );
        },
        routes: [
          GoRoute(
              path: kReaderDetailPath,
              name: kReaderDetailPage,
              pageBuilder: (context, GoRouterState state) {
                final bookPath = state.extra as String;
                // ? state.extra as Conversation
                // : Conversation();

                return MaterialPage(
                  child: RootLayout(
                    // key: _scaffoldKey,
                    currentIndex: 0,
                    child: ChatPageBody(),
                  ),
                );
              }),
        ],
      ),
      GoRoute(
        path: kChatPath,
        name: kChatPage,
        pageBuilder: (context, state) => const MaterialPage(
          // key: _pageKey,
          child: RootLayout(
            // key: _scaffoldKey,
            currentIndex: 1,
            child: ChatPageBody(),
          ),
        ),
        routes: [
          GoRoute(
            path: "feed",
            name: "chat_feed",
            pageBuilder: (context, state) {
              final Conversation conversation = state.extra is Conversation
                  ? state.extra as Conversation
                  : Conversation();

              return MaterialPage(
                child: ChatScreen(conversation: conversation),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: kMusicPath,
        name: kMusicPage,
        pageBuilder: (context, state) => const MaterialPage(
          // key: _pageKey,
          child: RootLayout(
            // key: _scaffoldKey,
            currentIndex: 2,
            child: PhotoPageBody(),
          ),
        ),
      ),
      GoRoute(
        path: kLoginPath,
        name: kLoginPage,
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
      // return kHomePath;
      return null;
    },
  );
}
