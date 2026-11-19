import 'package:go_router/go_router.dart';

import 'screens/ask_question_screen.dart';
import 'screens/question_detail_screen.dart';

/// Community feature routes (top-level, no tab bar).
/// Tab-nested screens (search / tag / my-questions) are wired by the
/// coordinator inside the community shell branch.
final List<RouteBase> communityRoutes = [
  GoRoute(
    path: '/community/ask',
    builder: (context, state) => const AskQuestionScreen(),
  ),
  GoRoute(
    path: '/community/question/:questionId',
    builder: (context, state) => QuestionDetailScreen(
      questionId: state.pathParameters['questionId']!,
    ),
  ),
];
