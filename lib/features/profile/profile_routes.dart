import 'package:go_router/go_router.dart';

import 'screens/edit_profile_screen.dart';
import 'screens/public_profile_screen.dart';

/// Profile feature routes (top-level, no tab bar).
/// Tab-nested screens (xp / streak / badges / leaderboard / report) are
/// wired by the coordinator inside the profile shell branch.
final List<RouteBase> profileRoutes = [
  GoRoute(
    path: '/profile/edit',
    builder: (context, state) => const EditProfileScreen(),
  ),
  GoRoute(
    path: '/profile/public',
    builder: (context, state) => PublicProfileScreen(
      name: state.uri.queryParameters['name'],
    ),
  ),
];
