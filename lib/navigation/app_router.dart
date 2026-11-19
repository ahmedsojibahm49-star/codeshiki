import 'package:go_router/go_router.dart';

import '../data/hive_boxes.dart';
import '../features/auth/auth_routes.dart';
import '../features/code/code_routes.dart';
import '../features/code/screens/code_home_screen.dart';
import '../features/code/screens/problems_screen.dart';
import '../features/code/screens/snippets_screen.dart';
import '../features/community/community_routes.dart';
import '../features/community/screens/community_feed_screen.dart';
import '../features/community/screens/community_search_screen.dart';
import '../features/community/screens/my_questions_screen.dart';
import '../features/community/screens/tag_page_screen.dart';
import '../features/course/course_routes.dart';
import '../features/home/screens/category_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/learning_path_screen.dart';
import '../features/home/screens/search_screen.dart';
import '../features/home/screens/streak_screen.dart';
import '../features/my_courses/my_courses_routes.dart';
import '../features/my_courses/screens/my_courses_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/payments/payments_routes.dart';
import '../features/payments/screens/orders_screen.dart';
import '../features/payments/screens/volts_wallet_screen.dart';
import '../features/player/player_routes.dart';
import '../features/profile/profile_routes.dart';
import '../features/profile/screens/badges_screen.dart';
import '../features/profile/screens/leaderboard_screen.dart';
import '../features/profile/screens/learning_report_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/streak_detail_screen.dart';
import '../features/profile/screens/xp_level_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/settings_routes.dart';
import 'app_shell.dart';

/// Routes that don't require a session (auth + onboarding).
const _authLocations = {
  '/splash',
  '/intro',
  '/welcome',
  '/login',
  '/signup',
  '/verify',
  '/forgot',
  '/forgot-sent',
  '/reset-password',
};

/// The app router. 5 tab branches (StatefulShellRoute.indexedStack) +
/// top-level pushed routes (no tab bar).
///
/// The auth guard reads the Hive session directly (the same key
/// AuthNotifier uses as its source of truth), so no Riverpod container is
/// needed here. Login/logout/delete navigate explicitly with go(), so no
/// refreshListenable is required.
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final location = state.matchedLocation;
    final loggedIn = HiveBoxes.auth.get('session') != null;
    final isAuthRoute =
        _authLocations.contains(location) || location.startsWith('/onboarding/');
    if (!loggedIn && !isAuthRoute) return '/splash';
    if (loggedIn &&
        (location == '/splash' ||
            location == '/intro' ||
            location == '/welcome' ||
            location == '/login' ||
            location == '/signup')) {
      return '/home';
    }
    return null;
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        // Home tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'search',
                  builder: (context, state) => const SearchScreen(),
                ),
                GoRoute(
                  path: 'category/:id',
                  builder: (context, state) => CategoryScreen(
                    category: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'path',
                  builder: (context, state) => const LearningPathScreen(),
                ),
                GoRoute(
                  path: 'streak',
                  builder: (context, state) => const StreakScreen(),
                ),
                GoRoute(
                  path: 'notifications',
                  builder: (context, state) => const NotificationsScreen(),
                ),
              ],
            ),
          ],
        ),
        // My Courses tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my-courses',
              builder: (context, state) => const MyCoursesScreen(),
            ),
          ],
        ),
        // Code tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/code',
              builder: (context, state) => const CodeHomeScreen(),
              routes: [
                GoRoute(
                  path: 'snippets',
                  builder: (context, state) => const SnippetsScreen(),
                ),
                GoRoute(
                  path: 'problems',
                  builder: (context, state) => const ProblemsScreen(),
                ),
              ],
            ),
          ],
        ),
        // Community tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/community',
              builder: (context, state) => const CommunityFeedScreen(),
              routes: [
                GoRoute(
                  path: 'search',
                  builder: (context, state) => const CommunitySearchScreen(),
                ),
                GoRoute(
                  path: 'tag/:tag',
                  builder: (context, state) => TagPageScreen(
                    tag: state.pathParameters['tag']!,
                  ),
                ),
                GoRoute(
                  path: 'my-questions',
                  builder: (context, state) => const MyQuestionsScreen(),
                ),
              ],
            ),
          ],
        ),
        // Profile tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'xp',
                  builder: (context, state) => const XpLevelScreen(),
                ),
                GoRoute(
                  path: 'streak',
                  builder: (context, state) => const StreakDetailScreen(),
                ),
                GoRoute(
                  path: 'badges',
                  builder: (context, state) => const BadgesScreen(),
                ),
                GoRoute(
                  path: 'leaderboard',
                  builder: (context, state) => const LeaderboardScreen(),
                ),
                GoRoute(
                  path: 'report',
                  builder: (context, state) => const LearningReportScreen(),
                ),
                GoRoute(
                  path: 'orders',
                  builder: (context, state) => const OrdersScreen(),
                ),
                GoRoute(
                  path: 'volts',
                  builder: (context, state) => const VoltsWalletScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // --- Top-level pushed routes (no tab bar), owned by each feature. ---
    ...authRoutes,
    ...courseRoutes,
    ...myCoursesRoutes,
    ...playerRoutes,
    ...codeRoutes,
    ...communityRoutes,
    ...profileRoutes,
    ...paymentsRoutes,
    ...settingsRoutes,
  ],
);
