import 'package:go_router/go_router.dart';

import 'screens/course_complete_screen.dart';
import 'screens/course_downloads_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/lesson_complete_screen.dart';
import 'screens/module_complete_screen.dart';
import 'screens/player_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/storage_screen.dart';

/// Player feature routes (wired into app_router.dart by the coordinator).
final List<RouteBase> playerRoutes = [
  GoRoute(
    path: '/player/:lessonId',
    builder: (context, state) => PlayerScreen(
      lessonId: state.pathParameters['lessonId']!,
      courseId: state.uri.queryParameters['courseId'],
    ),
  ),
  GoRoute(
    path: '/quiz/:lessonId',
    builder: (context, state) => QuizScreen(
      lessonId: state.pathParameters['lessonId']!,
      courseId: state.uri.queryParameters['courseId'],
    ),
  ),
  GoRoute(
    path: '/lesson-complete',
    builder: (context, state) {
      final query = state.uri.queryParameters;
      return LessonCompleteScreen(
        lessonId: query['lessonId'] ?? '',
        courseId: query['courseId'] ?? '',
        score: int.tryParse(query['score'] ?? ''),
        total: int.tryParse(query['total'] ?? ''),
      );
    },
  ),
  GoRoute(
    path: '/module-complete',
    builder: (context, state) {
      final query = state.uri.queryParameters;
      return ModuleCompleteScreen(
        courseId: query['courseId'] ?? '',
        moduleId: query['moduleId'] ?? '',
      );
    },
  ),
  GoRoute(
    path: '/course-complete',
    builder: (context, state) => CourseCompleteScreen(
      courseId: state.uri.queryParameters['courseId'] ?? '',
    ),
  ),
  GoRoute(
    path: '/my-courses/downloads',
    builder: (context, state) => const DownloadsScreen(),
    routes: [
      GoRoute(
        path: 'storage',
        builder: (context, state) => const StorageScreen(),
      ),
    ],
  ),
  GoRoute(
    path: '/course/:courseId/downloads',
    builder: (context, state) => CourseDownloadsScreen(
      courseId: state.pathParameters['courseId']!,
    ),
  ),
];
