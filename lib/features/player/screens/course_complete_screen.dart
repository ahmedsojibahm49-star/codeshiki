import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_top_bar.dart';

/// Course complete celebration [E20] with confetti-ish decoration
/// (orange circles + stars, no package).
class CourseCompleteScreen extends ConsumerWidget {
  const CourseCompleteScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = DemoData.courseById(courseId);
    if (course == null) {
      return Scaffold(
        appBar: const CsTopBar(title: 'Course complete'),
        body: CsEmptyState(
          icon: AppIcons.trophy,
          title: 'Course not found',
          body: 'This course does not exist in the demo catalog.',
          actionLabel: 'Back to Home',
          onAction: () => context.go('/home'),
        ),
      );
    }
    final cs = context.cs;
    return Scaffold(
      appBar: const CsTopBar(title: '', showBack: false),
      body: Stack(
        children: [
          // Confetti-ish decoration: orange circles + stars.
          const _ConfettiDecoration(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.trophyBold,
                      size: 56,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Course complete!',
                  style: AppText.h1.copyWith(color: cs.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You finished “${course.title}”. '
                  'Your certificate is ready.',
                  style: AppText.body.copyWith(color: cs.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CsButton(
                  label: 'View certificate',
                  icon: AppIcons.awardBold,
                  onPressed: () => context.push(
                    '/my-courses/certificate/${course.id}',
                  ),
                ),
                const SizedBox(height: 12),
                CsButton(
                  label: 'Rate this course',
                  variant: CsButtonVariant.secondary,
                  icon: AppIcons.starBold,
                  onPressed: () =>
                      context.push('/course/${course.id}/reviews'),
                ),
                const SizedBox(height: 12),
                CsButton(
                  label: 'Done',
                  variant: CsButtonVariant.ghost,
                  onPressed: () => context.go('/my-courses'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Scattered orange circles and stars near the top of the screen.
class _ConfettiDecoration extends StatelessWidget {
  const _ConfettiDecoration();

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: 24,
              left: 28,
              child: Icon(
                AppIcons.starBold,
                size: 22,
                color: cs.primary,
              ),
            ),
            Positioned(
              top: 56,
              left: 64,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 36,
              right: 40,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: cs.teal.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 88,
              right: 72,
              child: Icon(
                AppIcons.starBold,
                size: 16,
                color: cs.accent,
              ),
            ),
            Positioned(
              top: 110,
              left: 36,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: cs.accent.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 110,
              child: Icon(
                AppIcons.flashBold,
                size: 18,
                color: cs.primary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
