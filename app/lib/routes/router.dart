import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/components/root_layout.dart';
import 'package:omnigram/entities/book.entity.dart';
import 'package:omnigram/providers/book.provider.dart';

import 'package:omnigram/screens/coming_soon.dart';
import 'package:omnigram/screens/home/book_search_screen.dart';
import 'package:omnigram/screens/profile/profile_mobile_screen.dart';
import 'package:omnigram/screens/profile/tts_settings_screen.dart';
import 'package:omnigram/screens/reader/read_epub_screen.dart';
import 'package:omnigram/screens/reader/reader_mobile_screen.dart';
import 'package:omnigram/screens/splash_screen.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:go_router/go_router.dart';

import '../screens/home/home_small_screen.dart';
import '../screens/login_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: SplashScreen.routePath,
    routes: [
      GoRoute(
        path: SplashScreen.routePath,
        name: SplashScreen.routePath,
        builder: (context, state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: kLoginPage,
        name: kLoginPage,
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: HomeSmallScreen.routePath,
        name: HomeSmallScreen.routePath,
        pageBuilder: (context, state) => const MaterialPage(
          // key: _pageKey,
          child: RootLayout(
            // key: _scaffoldKey,
            currentIndex: 0,
            child: HomeSmallScreen(),
          ),
        ),
        routes: [
          GoRoute(
            path: kSummaryPage,
            name: kSummaryPage,
            pageBuilder: (context, state) {
              final book = state.extra as BookEntity;
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
            path: kReaderSearchPage,
            name: kReaderSearchPage,
            pageBuilder: (context, state) {
              final query = state.extra as BookQuery;
              return MaterialPage(
                // key: _pageKey,
                child: BookSearchScreen(query),
              );
            },
            // routes: [],
          ),
          GoRoute(
            path: kReaderDetailPage,
            name: kReaderDetailPage,
            pageBuilder: (context, GoRouterState state) {
              // final bookPath = state.extra as String;
              final args = state.extra == null ? false : state.extra as bool;

              return MaterialPage(
                child: ReadEpubScreen(playtask: args),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: kDiscoverPage,
        name: kDiscoverPage,
        pageBuilder: (context, state) => const MaterialPage(
          child: RootLayout(
            currentIndex: 1,
            child: PhotoPageBody(),
          ),
        ),
      ),
      GoRoute(
        path: kNotePage,
        name: kNotePage,
        pageBuilder: (context, state) => const MaterialPage(
          child: RootLayout(
            currentIndex: 2,
            child: PhotoPageBody(),
          ),
        ),
        // routes: [
        //   GoRoute(
        //     path: kChatPagePath,
        //     name: kChatPagePath,
        //     pageBuilder: (context, state) {
        //       final Conversation conversation = state.extra is Conversation
        //           ? state.extra as Conversation
        //           : Conversation();

        //       return MaterialPage(
        //         child: ChatPageScreen(conversation: conversation),
        //       );
        //     },
        //   ),
        // ],
      ),
      GoRoute(
        path: kManagerPath,
        name: kManagerPage,
        pageBuilder: (context, state) => const MaterialPage(
          child: PhotoPageBody(),
        ),
      ),
      GoRoute(
        path: kProfilePage,
        name: kProfilePage,
        pageBuilder: (context, state) => const MaterialPage(
          // key: _pageKey,
          child: RootLayout(
            // key: _scaffoldKey,
            currentIndex: 3,
            child: ProfileSmallScreen(),
          ),
        ),
        routes: [
          GoRoute(
            path: kTTSSettingPage,
            name: kTTSSettingPage,
            pageBuilder: (context, state) {
              return const MaterialPage(
                child: TtsSettingsScreen(),
              );
            },
          ),
        ],
      ),
    ],
    // redirect: (context, state) {
    //   // If our async state is loading, don't perform redirects, yet
    //   // if (authState.isLoading || authState.hasError) return null;

    //   // // Here we guarantee that hasData == true, i.e. we have a readable value

    //   // // This has to do with how the FirebaseAuth SDK handles the "log-in" state
    //   // // Returning `null` means "we are not authorized"
    //   // final isAuth = authState.valueOrNull != null;

    //   final isSplash = state.fullPath == kSplashPath;

    //   if (isSplash) {
    //     return isAuth ? kHomePath : kLoginPath;
    //   }

    //   final isLoggingIn = state.fullPath == kLoginPath;
    //   if (isLoggingIn) return isAuth ? kHomePath : null;

    //   // return isAuth ? null : SplashPage.routeLocation;
    //   // return kHomePath;
    //   return isAuth ? null : kLoginPath;
    // },
  );
});
