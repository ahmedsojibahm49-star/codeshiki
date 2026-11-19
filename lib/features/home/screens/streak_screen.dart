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
import '../../../widgets/cs_stat_item.dart';
import '../../../widgets/cs_top_bar.dart';

/// Streak [B04]: big count, week dots, month calendar, stats.
class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  static const List<String> _weekLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];

  /// Demo pattern: studied every day this week except the last two.
  static const List<bool> _weekDone = [true, true, true, true, true, false, false];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final wallet = ref.watch(walletProvider);
    final enrollmentNotifier = ref.read(enrollmentProvider.notifier);
    final enrolled = ref.watch(enrollmentProvider).enrolledCourseIds;

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = DateTime(now.year, now.month).weekday % 7;

    // First enrolled course with an incomplete lesson, for the CTA.
    Course? continueCourse;
    Lesson? nextLesson;
    for (final courseId in enrolled) {
      final course = DemoData.courseById(courseId);
      if (course == null) continue;
      for (final lesson in course.allLessons) {
        if (!enrollmentNotifier.isLessonCompleted(courseId, lesson.id)) {
          continueCourse = course;
          nextLesson = lesson;
          break;
        }
      }
      if (nextLesson != null) break;
    }

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Streak'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Hero count --------------------------------------------------
            Center(
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: CsScheme.proGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.flashBold,
                      size: 44,
                      color: cs.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${wallet.streakDays}',
                    style: AppText.display.copyWith(color: cs.textPrimary),
                  ),
                  Text(
                    'day streak — keep the fire burning!',
                    style: AppText.body.copyWith(color: cs.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- This week ---------------------------------------------------
            Text(
              'This week',
              style: AppText.h3.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.borderHairline),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 7; i++)
                    Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _weekDone[i] ? cs.primary : cs.sunken,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _weekDone[i] ? AppIcons.checkBold : AppIcons.flash,
                            size: 16,
                            color: _weekDone[i]
                                ? cs.onPrimary
                                : cs.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _weekLabels[i],
                          style: AppText.caption.copyWith(
                            color: cs.textSecondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Month calendar ----------------------------------------------
            Text(
              '${_monthNames[now.month - 1]} ${now.year}',
              style: AppText.h3.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.borderHairline),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (final label in _weekLabels)
                        SizedBox(
                          width: 32,
                          child: Text(
                            label,
                            style: AppText.caption.copyWith(
                              color: cs.textTertiary,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 4,
                      childAspectRatio: 1,
                    ),
                    itemCount: firstWeekday + daysInMonth,
                    itemBuilder: (context, index) {
                      if (index < firstWeekday) return const SizedBox();
                      final day = index - firstWeekday + 1;
                      final isToday = day == now.day;
                      final isFuture = day > now.day;
                      // Demo pattern: studied most days, missed every 5th.
                      final studied = !isFuture && day % 5 != 0;
                      return Container(
                        decoration: BoxDecoration(
                          color: isToday
                              ? cs.primary
                              : studied
                                  ? cs.warningSoft
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isToday
                              ? null
                              : Border.all(
                                  color: studied
                                      ? cs.primary
                                      : cs.borderHairline,
                                ),
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: AppText.caption.copyWith(
                              color: isToday
                                  ? cs.onPrimary
                                  : isFuture
                                      ? cs.textTertiary
                                      : cs.textPrimary,
                              fontWeight:
                                  isToday ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Stats --------------------------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.borderHairline),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: CsStatItem(value: '21', label: 'Longest streak'),
                  ),
                  Container(width: 1, height: 40, color: cs.borderHairline),
                  Expanded(
                    child: CsStatItem(
                      value: '${wallet.xp}',
                      label: 'Total XP',
                    ),
                  ),
                  Container(width: 1, height: 40, color: cs.borderHairline),
                  const Expanded(
                    child: CsStatItem(value: '5', label: 'Days this week'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'One lesson a day keeps the streak alive. You are 9 days away '
              'from your longest streak ever — you can do this!',
              style: AppText.body.copyWith(color: cs.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CsButton(
              label: nextLesson == null
                  ? 'Browse courses'
                  : 'Continue today\u2019s lesson',
              icon: AppIcons.play,
              onPressed: nextLesson == null || continueCourse == null
                  ? () => context.go('/home')
                  : () => context.push(
                        '/player/${nextLesson!.id}'
                        '?courseId=${continueCourse!.id}',
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
