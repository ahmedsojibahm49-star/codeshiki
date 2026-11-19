import 'package:go_router/go_router.dart';

import 'screens/editor_screen.dart';
import 'screens/problem_detail_screen.dart';
import 'screens/project_page_screen.dart';

/// Code feature routes (top-level, no tab bar). Wired into [appRouter]
/// in `lib/navigation/app_router.dart`.
///
/// Tab-nested screens ([CodeHomeScreen] at `/code`, [SnippetsScreen] at
/// `/code/snippets`, [ProblemsScreen] at `/code/problems`) are wired
/// inside the Code shell branch; they are not exported here.
final List<RouteBase> codeRoutes = [
  GoRoute(
    path: '/editor/:projectId',
    builder: (context, state) => EditorScreen(
      projectId: state.pathParameters['projectId']!,
    ),
  ),
  GoRoute(
    path: '/code/problems/:problemId',
    builder: (context, state) => ProblemDetailScreen(
      problemId: state.pathParameters['problemId']!,
    ),
  ),
  GoRoute(
    path: '/code/project/:projectId',
    builder: (context, state) => ProjectPageScreen(
      projectId: state.pathParameters['projectId']!,
    ),
  ),
];
