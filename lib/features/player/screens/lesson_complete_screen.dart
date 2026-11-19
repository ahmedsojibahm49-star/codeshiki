import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/hive_boxes.dart';
import '../../../data/models.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_top_bar.dart';
import '../player_helpers.dart';

/// Lesson complete celebration [E18].
///
/// Awards +20 XP exactly once per lesson (guarded by the
/// `xpAwardedLessons` list in the settings box). "Next lesson" routes
/// to the next lesson, the module-complete screen when a module ends,
/// or the course-complete screen when the course ends.
class LessonCompleteScreen extends ConsumerStatefulWidget {
  const LessonCompleteScreen({
    super.key,
    required this.lessonId,
    required this.courseId,
    this.score,
    this.total,
  });

  final String lessonId;
  final String courseId;
  final int? score;
  final int? total;

  @override
  ConsumerState<LessonCompleteScreen> createState() =>
      _LessonCompleteScreenState();
}

class _LessonCompleteScreenState
    extends ConsumerState<LessonCompleteScreen> {
  Course? _course;
  Lesson? _lesson;
  Module? _module;

  @override
  void initState() {
    super.initState();
    final resolved = resolveLesson(widget.lessonId, widget.courseId);
    _course = resolved.course;
    _lesson = resolved.lesson;
    _module = resolved.module;
    _awardXpOnce();
  }

  void _awardXpOnce() {
    final awarded =
        HiveBoxes.settings.stringsAt('xpAwardedLessons').toSet();
    if (awarded.contains(widget.lessonId)) return;
    awarded.add(widget.lessonId);
    HiveBoxes.settings.put('xpAwardedLessons', awarded.toList());
    ref.read(walletProvider.notifier).addXp(20);
  }

  void _goNext() {
    final course = _course;
    final lesson = _lesson;
    final module = _module;
    if (course == null || lesson == null) return;
    final next = nextLessonAfter(course, lesson.id);
    if (next == null) {
      context.push('/course-complete?courseId=${course.id}');
      return;
    }
    final nextModule = moduleOf(course, next.id);
    if (module != null &&
        nextModule != null &&
        nextModule.id != module.id) {
      context.push(
        '/module-complete?courseId=${course.id}&moduleId=${module.id}',
      );
      return;
    }
    context.push(lessonRoute(next, course.id));
  }

  @override
  Widget build(BuildContext context) {
    final course = _course;
    final lesson = _lesson;
    if (course == null || lesson == null) {
      return Scaffold(
        appBar: const CsTopBar(title: 'Lesson complete'),
        body: CsEmptyState(
          icon: AppIcons.trophy,
          title: 'Lesson not found',
          body: 'This lesson does not exist in the demo catalog.',
          actionLabel: 'Back to Home',
          onAction: () => context.go('/home'),
        ),
      );
    }
    final cs = context.cs;
    final wallet = ref.watch(walletProvider);
    final hasScore = widget.score != null && widget.total != null;
    return Scaffold(
      appBar: const CsTopBar(title: '', showBack: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: cs.sunken,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.trophyBold,
                  size: 48,
                  color: cs.accent,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Lesson complete!',
              style: AppText.h1.copyWith(color: cs.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '“${lesson.title}”',
              style: AppText.body.copyWith(color: cs.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (hasScore) ...[
              const SizedBox(height: 12),
              Text(
                'Quiz score: ${widget.score}/${widget.total}',
                style: AppText.label.copyWith(color: cs.accent),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.raised,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.borderHairline),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _RewardStat(
                    icon: AppIcons.flash,
                    value: '+20 XP',
                    label: 'Earned',
                  ),
                  _RewardStat(
                    icon: AppIcons.chart,
                    value: '${wallet.level}',
                    label: 'Level',
                  ),
                  _RewardStat(
                    icon: AppIcons.target,
                    value: '${wallet.streakDays} days',
                    label: 'Streak kept',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Streak kept: ${wallet.streakDays} days — come back '
              'tomorrow to keep it alive.',
              style: AppText.caption.copyWith(color: cs.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CsButton(
              label: 'Next lesson',
              icon: AppIcons.arrowRightBold,
              onPressed: _goNext,
            ),
            const SizedBox(height: 12),
            CsButton(
              label: 'Back to course',
              variant: CsButtonVariant.secondary,
              onPressed: () => context.push('/course/${course.id}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardStat extends StatelessWidget {
  const _RewardStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Column(
      children: [
        Icon(icon, size: 22, color: cs.accent),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppText.h3.copyWith(color: cs.textPrimary),
        ),
        Text(
          label,
          style: AppText.caption.copyWith(color: cs.textSecondary),
        ),
      ],
    );
  }
}
