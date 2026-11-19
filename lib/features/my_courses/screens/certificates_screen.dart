import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/models.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_top_bar.dart';

/// Certificates list [D06].
/// Demo rule: "Python in One Night" is earned (matches the demo
/// notification "Certificate ready"); other enrolled courses show locked
/// with their current progress.
class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  static const String _earnedCourseId = 'python-one-night';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final enrollment = ref.watch(enrollmentProvider);
    final enrollmentNotifier = ref.read(enrollmentProvider.notifier);

    final earned = <Course>[];
    final locked = <Course>[];
    for (final courseId in enrollment.enrolledCourseIds) {
      final course = DemoData.courseById(courseId);
      if (course == null) continue;
      if (courseId == _earnedCourseId ||
          enrollmentNotifier.progressFor(courseId) >= 1) {
        earned.add(course);
      } else {
        locked.add(course);
      }
    }

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Certificates'),
      body: earned.isEmpty && locked.isEmpty
          ? CsEmptyState(
              icon: AppIcons.award,
              title: 'No certificates yet',
              body: 'Complete a course to earn your first certificate.',
              actionLabel: 'Browse courses',
              onAction: () => context.go('/home'),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                if (earned.isNotEmpty) ...[
                  Text(
                    'Earned (${earned.length})',
                    style: AppText.h3.copyWith(color: cs.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  for (final course in earned) ...[
                    _CertificateCard(
                      course: course,
                      earned: true,
                      onTap: () => context.push(
                        '/my-courses/certificate/${course.id}',
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 12),
                ],
                if (locked.isNotEmpty) ...[
                  Text(
                    'In progress (${locked.length})',
                    style: AppText.h3.copyWith(color: cs.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  for (final course in locked) ...[
                    _CertificateCard(
                      course: course,
                      earned: false,
                      progress: enrollmentNotifier.progressFor(course.id),
                      onTap: () => context.push(
                        '/my-courses/progress/${course.id}',
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({
    required this.course,
    required this.earned,
    required this.onTap,
    this.progress = 0,
  });

  final Course course;
  final bool earned;
  final VoidCallback onTap;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: earned ? cs.primary : cs.borderHairline,
              width: earned ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: earned ? cs.warningSoft : cs.sunken,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  earned ? AppIcons.awardBold : AppIcons.lock,
                  size: 26,
                  color: earned ? cs.accent : cs.textTertiary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: AppText.label.copyWith(color: cs.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (earned)
                      Text(
                        'Certificate of Completion',
                        style: AppText.caption.copyWith(
                          color: cs.success,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else ...[
                      Text(
                        '${(progress * 100).round()}% complete — finish the '
                        'course to unlock',
                        style: AppText.caption.copyWith(
                          color: cs.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor: cs.sunken,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
