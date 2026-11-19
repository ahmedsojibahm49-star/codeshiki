import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/models.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_course_card.dart';
import '../../../widgets/cs_empty_state.dart';

/// My Courses tab [D01/D02/D03]: In Progress / Completed / Wishlist tabs,
/// plus Downloads + Certificates cards below.
class MyCoursesScreen extends ConsumerWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final enrollment = ref.watch(enrollmentProvider);
    final enrollmentNotifier = ref.read(enrollmentProvider.notifier);

    final inProgress = <Course>[];
    final completed = <Course>[];
    for (final courseId in enrollment.enrolledCourseIds) {
      final course = DemoData.courseById(courseId);
      if (course == null) continue;
      if (enrollmentNotifier.progressFor(courseId) >= 1) {
        completed.add(course);
      } else {
        inProgress.add(course);
      }
    }
    final wishlist = enrollment.wishlistIds
        .map(DemoData.courseById)
        .whereType<Course>()
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: cs.canvas,
        appBar: AppBar(
          title: Text(
            'My Courses',
            style: AppText.h2.copyWith(color: cs.textPrimary),
          ),
          centerTitle: false,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            labelColor: cs.accent,
            unselectedLabelColor: cs.textSecondary,
            indicatorColor: cs.primary,
            indicatorWeight: 2.5,
            labelStyle: AppText.label,
            tabs: [
              Tab(text: 'In Progress (${inProgress.length})'),
              Tab(text: 'Completed (${completed.length})'),
              Tab(text: 'Wishlist (${wishlist.length})'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _CourseList(
                    courses: inProgress,
                    emptyIcon: AppIcons.book,
                    emptyTitle: 'No courses in progress',
                    emptyBody: 'Enroll in a course and your learning '
                        'journey will show up here.',
                    emptyActionLabel: 'Browse courses',
                    onEmptyAction: () => context.go('/home'),
                    trailingFor: (course) => _ProgressBadge(
                      progress: enrollmentNotifier.progressFor(course.id),
                    ),
                    onTap: (course) => context.push(
                      '/my-courses/progress/${course.id}',
                    ),
                  ),
                  _CourseList(
                    courses: completed,
                    emptyIcon: AppIcons.award,
                    emptyTitle: 'No completed courses yet',
                    emptyBody: 'Finish all the lessons in a course to earn '
                        'your certificate — it will appear here.',
                    emptyActionLabel: 'Browse courses',
                    onEmptyAction: () => context.go('/home'),
                    trailingFor: (_) => Icon(
                      AppIcons.award,
                      size: 22,
                      color: cs.accent,
                    ),
                    onTap: (course) => context.push(
                      '/my-courses/progress/${course.id}',
                    ),
                  ),
                  _CourseList(
                    courses: wishlist,
                    emptyIcon: AppIcons.heart,
                    emptyTitle: 'Your wishlist is empty',
                    emptyBody: 'Tap the heart on any course to save it here '
                        'for later.',
                    emptyActionLabel: 'Browse courses',
                    onEmptyAction: () => context.go('/home'),
                    onTap: (course) =>
                        context.push('/course/${course.id}'),
                  ),
                ],
              ),
            ),
            // --- Downloads + Certificates cards (below the tabs) -----------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                children: [
                  _NavCard(
                    icon: AppIcons.download,
                    title: 'Downloads',
                    subtitle: 'Lessons saved for offline watching',
                    onTap: () => context.push('/my-courses/downloads'),
                  ),
                  const SizedBox(height: 10),
                  _NavCard(
                    icon: AppIcons.award,
                    title: 'Certificates',
                    subtitle: 'View and share what you earned',
                    onTap: () => context.push('/my-courses/certificates'),
                  ),
                ],
              ),
            ),
            // Space for the floating iOS pill tab bar.
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _CourseList extends StatelessWidget {
  const _CourseList({
    required this.courses,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyBody,
    required this.emptyActionLabel,
    required this.onEmptyAction,
    required this.onTap,
    this.trailingFor,
  });

  final List<Course> courses;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyBody;
  final String emptyActionLabel;
  final VoidCallback onEmptyAction;
  final ValueChanged<Course> onTap;
  final Widget Function(Course)? trailingFor;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return CsEmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        body: emptyBody,
        actionLabel: emptyActionLabel,
        onAction: onEmptyAction,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      itemCount: courses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final course = courses[index];
        return CsCourseListCard(
          course: course,
          trailing: trailingFor?.call(course),
          onTap: () => onTap(course),
        );
      },
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              backgroundColor: cs.sunken,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: AppText.caption.copyWith(
              color: cs.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.borderHairline),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.sunken,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: cs.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.label.copyWith(color: cs.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppText.caption.copyWith(
                        color: cs.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                AppIcons.chevronRight,
                size: 18,
                color: cs.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
