import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'demo_data.dart';
import 'hive_boxes.dart';
import 'models.dart';

/// Data-access seam. The demo reads from [DemoData] + Hive; a Supabase
/// implementation can slot in later by implementing this interface — no
/// provider or screen code changes.
abstract class DemoRepository {
  List<Course> getCourses();
  Course? getCourse(String id);
  List<Lesson> getLessons(String courseId);
  List<ForumQuestion> getQuestions();
  List<BadgeInfo> getBadges();
  List<LeaderboardEntry> getLeaderboard();
  List<AppNotification> getNotifications();
  List<Order> getOrders();
  List<CodeProject> getCodeProjects();
  List<Course> searchCourses(String query);
}

/// Local demo implementation: static content from [DemoData], user-mutated
/// lists (forum, notifications, orders) from Hive when present.
class LocalDemoRepository implements DemoRepository {
  @override
  List<Course> getCourses() => DemoData.courses;

  @override
  Course? getCourse(String id) => DemoData.courseById(id);

  @override
  List<Lesson> getLessons(String courseId) =>
      DemoData.courseById(courseId)?.allLessons ?? [];

  @override
  List<ForumQuestion> getQuestions() {
    final stored = HiveBoxes.forum.mapsAt('questions');
    if (stored.isEmpty) return DemoData.questions;
    return stored.map(ForumQuestion.fromJson).toList();
  }

  @override
  List<BadgeInfo> getBadges() => DemoData.badges;

  @override
  List<LeaderboardEntry> getLeaderboard() => DemoData.leaderboard;

  @override
  List<AppNotification> getNotifications() {
    final stored = HiveBoxes.notifications.mapsAt('items');
    if (stored.isEmpty) return DemoData.notifications;
    return stored.map(AppNotification.fromJson).toList();
  }

  @override
  List<Order> getOrders() {
    final stored = HiveBoxes.orders.mapsAt('items');
    if (stored.isEmpty) return DemoData.orders;
    return stored.map(Order.fromJson).toList();
  }

  @override
  List<CodeProject> getCodeProjects() => DemoData.codeProjects;

  @override
  List<Course> searchCourses(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return DemoData.courses;
    return DemoData.courses
        .where((c) =>
            c.title.toLowerCase().contains(q) ||
            c.instructor.toLowerCase().contains(q) ||
            c.category.toLowerCase().contains(q))
        .toList();
  }
}

/// The repository instance. Feature code should read through this provider
/// (or [DemoData] directly for static content).
final demoRepositoryProvider = Provider<DemoRepository>(
  (ref) => LocalDemoRepository(),
);
