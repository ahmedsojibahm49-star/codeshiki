import 'package:go_router/go_router.dart';

import 'screens/build_screen.dart';
import 'screens/bundle_screen.dart';
import 'screens/course_detail_screen.dart';
import 'screens/instructor_screen.dart';
import 'screens/requirements_screen.dart';
import 'screens/reviews_screen.dart';

/// Top-level course routes (no tab bar).
///
/// NOTE for the coordinator: `app_router.dart` still holds a placeholder
/// `GoRoute(path: '/course/:id')` — remove it before spreading these in,
/// or the router will throw on duplicate paths.
final List<RouteBase> courseRoutes = [
  GoRoute(
    path: '/course/:courseId',
    builder: (context, state) => CourseDetailScreen(
      courseId: state.pathParameters['courseId']!,
    ),
    routes: [
      GoRoute(
        path: 'instructor',
        builder: (context, state) => InstructorScreen(
          courseId: state.pathParameters['courseId']!,
        ),
      ),
      GoRoute(
        path: 'reviews',
        builder: (context, state) => ReviewsScreen(
          courseId: state.pathParameters['courseId']!,
        ),
      ),
      GoRoute(
        path: 'bundle',
        builder: (context, state) => BundleScreen(
          courseId: state.pathParameters['courseId']!,
        ),
      ),
      GoRoute(
        path: 'build',
        builder: (context, state) => BuildScreen(
          courseId: state.pathParameters['courseId']!,
        ),
      ),
      GoRoute(
        path: 'requirements',
        builder: (context, state) => RequirementsScreen(
          courseId: state.pathParameters['courseId']!,
        ),
      ),
    ],
  ),
];
