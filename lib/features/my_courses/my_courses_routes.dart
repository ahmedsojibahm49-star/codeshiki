import 'package:go_router/go_router.dart';

import 'screens/certificate_view_screen.dart';
import 'screens/certificates_screen.dart';
import 'screens/progress_screen.dart';

/// My Courses sub-routes (top-level pushes, no tab bar).
///
/// NOTE: `/my-courses/downloads` is owned by the downloads feature — this
/// file intentionally does not define it. The `/my-courses` tab root
/// itself is wired by the coordinator into the shell.
final List<RouteBase> myCoursesRoutes = [
  GoRoute(
    path: '/my-courses/progress/:courseId',
    builder: (context, state) => CourseProgressScreen(
      courseId: state.pathParameters['courseId']!,
    ),
  ),
  GoRoute(
    path: '/my-courses/certificates',
    builder: (context, state) => const CertificatesScreen(),
  ),
  GoRoute(
    path: '/my-courses/certificate/:id',
    builder: (context, state) => CertificateViewScreen(
      certificateId: state.pathParameters['id']!,
    ),
  ),
];
