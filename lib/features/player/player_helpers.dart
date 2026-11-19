import '../../data/demo_data.dart';
import '../../data/models.dart';

/// Shared lookups for the player feature.
///
/// Note: [DemoData.lessonById] needs a courseId, so these helpers search
/// across all courses when only a lessonId is known (e.g. deep links and
/// the downloads list).
({Course? course, Lesson? lesson, Module? module}) resolveLesson(
  String lessonId, [
  String? courseId,
]) {
  if (courseId != null) {
    final course = DemoData.courseById(courseId);
    if (course != null) {
      for (final module in course.modules) {
        for (final lesson in module.lessons) {
          if (lesson.id == lessonId) {
            return (course: course, lesson: lesson, module: module);
          }
        }
      }
      // Course known but lesson not in it — fall through to global search.
    }
  }
  for (final course in DemoData.courses) {
    for (final module in course.modules) {
      for (final lesson in module.lessons) {
        if (lesson.id == lessonId) {
          return (course: course, lesson: lesson, module: module);
        }
      }
    }
  }
  return (course: null, lesson: null, module: null);
}

/// The module of [course] that contains [lessonId], or null.
Module? moduleOf(Course course, String lessonId) {
  for (final module in course.modules) {
    if (module.lessons.any((l) => l.id == lessonId)) return module;
  }
  return null;
}

/// The lesson after [lessonId] in [course] (across modules), or null when
/// [lessonId] is the last lesson of the course.
Lesson? nextLessonAfter(Course course, String lessonId) {
  final lessons = course.allLessons;
  final index = lessons.indexWhere((l) => l.id == lessonId);
  if (index < 0 || index + 1 >= lessons.length) return null;
  return lessons[index + 1];
}

/// Route for opening a lesson: quizzes go straight to the quiz screen,
/// everything else goes through the player (which shows quiz/code/reading
/// cards for non-video lessons).
String lessonRoute(Lesson lesson, String courseId) {
  if (lesson.isQuiz) {
    return '/quiz/${lesson.id}?courseId=$courseId';
  }
  return '/player/${lesson.id}?courseId=$courseId';
}

/// Demo editor project for a course's code lessons. Counter App is the
/// default; Python and DSA courses map to their own demo projects
/// (verified ids in `lib/data/code_samples.dart`).
String editorProjectForCourse(String courseId) {
  switch (courseId) {
    case 'python-one-night':
      return 'hello-python';
    case 'dsa-java':
      return 'two-sum';
    default:
      return 'counter-app';
  }
}

/// Formats a [Duration] as m:ss (or h:mm:ss past one hour).
String formatDuration(Duration duration) {
  final totalSeconds = duration.inSeconds.clamp(0, 1 << 31);
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// Demo download size label — every lesson video is labelled ~24 MB.
String demoSizeLabel([int count = 1]) => '~${24 * count} MB';
