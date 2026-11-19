import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/models.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_section_header.dart';
import '../../../widgets/cs_top_bar.dart';
import '../../course/sheets/locked_sheet.dart';

/// Per-course progress [D05]: progress ring, module checklist, certificate.
class CourseProgressScreen extends ConsumerWidget {
  const CourseProgressScreen({super.key, required this.courseId});

  final String courseId;

  IconData _lessonIcon(Lesson lesson) {
    switch (lesson.type) {
      case 'video':
        return AppIcons.playCircle;
      case 'reading':
        return AppIcons.documentText;
      case 'quiz':
        return AppIcons.checkSquare;
      case 'code':
        return AppIcons.code;
      default:
        return AppIcons.playCircle;
    }
  }

  void _openLesson(
    BuildContext context,
    Course course,
    Lesson lesson,
    bool enrolled,
  ) {
    if (lesson.locked && !enrolled) {
      showLockedLessonSheet(context, lesson);
      return;
    }
    switch (lesson.type) {
      case 'quiz':
        context.push('/quiz/${lesson.id}?courseId=${course.id}');
      case 'code':
        context.push('/editor/counter-app');
      default:
        context.push('/player/${lesson.id}?courseId=${course.id}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final course = DemoData.courseById(courseId);
    if (course == null) {
      return Scaffold(
        backgroundColor: cs.canvas,
        appBar: const CsTopBar(title: 'Progress'),
        body: Center(
          child: Text(
            'Course not found',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
        ),
      );
    }

    final enrollmentNotifier = ref.read(enrollmentProvider.notifier);
    ref.watch(enrollmentProvider); // rebuild on completion changes
    final enrolled = enrollmentNotifier.isEnrolled(course.id);
    final progress = enrollmentNotifier.progressFor(course.id);
    final doneCount = course.allLessons
        .where((l) => enrollmentNotifier.isLessonCompleted(course.id, l.id))
        .length;

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'My progress'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header: cover + ring --------------------------------------
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    course.coverPhoto,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: AppText.h3.copyWith(color: cs.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course.instructor,
                        style: AppText.bodySmall.copyWith(
                          color: cs.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$doneCount of ${course.allLessons.length} lessons done',
                        style: AppText.caption.copyWith(
                          color: cs.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: cs.sunken,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            cs.primary,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: AppText.label.copyWith(
                          color: cs.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Certificate card (complete courses only) ------------------
            if (progress >= 1) ...[
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      context.push('/my-courses/certificate/${course.id}'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: CsScheme.proGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: cs.onPrimary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            AppIcons.awardBold,
                            size: 24,
                            color: cs.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Course complete!',
                                style: AppText.label.copyWith(
                                  color: cs.onPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Your certificate is ready to view and share.',
                                style: AppText.bodySmall.copyWith(
                                  color: cs.onPrimary.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          AppIcons.chevronRight,
                          size: 20,
                          color: cs.onPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // --- Module checklist -------------------------------------------
            const CsSectionHeader(title: 'Lessons'),
            const SizedBox(height: 12),
            for (final module in course.modules) ...[
              Text(
                module.title,
                style: AppText.label.copyWith(color: cs.textPrimary),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.borderHairline),
                ),
                child: Column(
                  children: [
                    for (final lesson in module.lessons)
                      _ChecklistRow(
                        lesson: lesson,
                        icon: _lessonIcon(lesson),
                        completed: enrollmentNotifier.isLessonCompleted(
                          course.id,
                          lesson.id,
                        ),
                        locked: lesson.locked && !enrolled,
                        onTap: () =>
                            _openLesson(context, course, lesson, enrolled),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 8),
            CsButton(
              label: 'View course details',
              variant: CsButtonVariant.secondary,
              icon: AppIcons.book,
              onPressed: () => context.push('/course/${course.id}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.lesson,
    required this.icon,
    required this.completed,
    required this.locked,
    required this.onTap,
  });

  final Lesson lesson;
  final IconData icon;
  final bool completed;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: completed ? cs.successSoft : cs.sunken,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  completed
                      ? AppIcons.checkBold
                      : locked
                          ? AppIcons.lock
                          : icon,
                  size: 16,
                  color: completed
                      ? cs.success
                      : locked
                          ? cs.textTertiary
                          : cs.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: AppText.body.copyWith(
                        color: locked ? cs.textTertiary : cs.textPrimary,
                        decoration: completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${lesson.durationMin} min',
                      style: AppText.caption.copyWith(
                        color: cs.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                completed
                    ? AppIcons.check
                    : AppIcons.chevronRight,
                size: 18,
                color: completed ? cs.success : cs.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
