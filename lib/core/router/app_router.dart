import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextflix/core/models/media.dart';
import 'package:nextflix/features/home/home_screen.dart';
import 'package:nextflix/features/library/library_screen.dart';
import 'package:nextflix/features/downloads/downloads_screen.dart';
import 'package:nextflix/features/details/details_screen.dart';
import 'package:nextflix/features/search/search_screen.dart';
import 'package:nextflix/features/shell/main_shell.dart';
import 'package:nextflix/features/player/test_player_screen.dart';
import 'package:nextflix/features/player/extractor_player_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorBrowseKey = GlobalKey<NavigatorState>(debugLabel: 'browse');
final _shellNavigatorLibraryKey = GlobalKey<NavigatorState>(debugLabel: 'library');
final _shellNavigatorDownloadsKey = GlobalKey<NavigatorState>(debugLabel: 'downloads');

final appRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorBrowseKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorLibraryKey,
          routes: [
            GoRoute(
              path: '/library',
              builder: (context, state) => const LibraryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorDownloadsKey,
          routes: [
            GoRoute(
              path: '/downloads',
              builder: (context, state) => const DownloadsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/details',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        if (extra == null) {
          return const Scaffold(body: Center(child: Text('Invalid Media Data')));
        }
        final media = extra['media'] as Media;
        final heroContext = extra['heroContext'] as String? ?? 'default';
        return DetailsScreen(media: media, heroContext: heroContext);
      },
    ),
    GoRoute(
      path: '/search',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/player',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final url = extra?['url'] as String?;
        return TestPlayerScreen(initialUrl: url);
      },
    ),
    GoRoute(
      path: '/extractor',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final url = extra?['url'] as String?;
        return ExtractorPlayerScreen(initialUrl: url);
      },
    ),
  ],
);
