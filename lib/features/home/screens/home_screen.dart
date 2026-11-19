import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/hive_boxes.dart';
import '../../../data/models.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_avatar.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_course_card.dart';
import '../../../widgets/cs_chip.dart';
import '../../../widgets/cs_section_header.dart';
import '../sheets/goal_sheet.dart';
import '../sheets/upsell_sheet.dart';

/// Home tab [B01]: greeting, streak, daily goal, continue learning,
/// categories, popular + new courses, learning path, Pro upsell.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _avatarPhoto(UserProfile? user) {
    final photo = user?.avatarPhoto;
    if (photo != null && photo.isNotEmpty) return photo;
    return DemoData.me.avatarPhoto;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final wallet = ref.watch(walletProvider);
    final settings = ref.watch(settingsProvider);
    final enrollment = ref.watch(enrollmentProvider);
    final enrollmentNotifier = ref.read(enrollmentProvider.notifier);
    final unread = ref.watch(unreadCountProvider);
    final user = ref.watch(authProvider).user;
    final firstName = (user?.name ?? DemoData.me.name).split(' ').first;

    // First enrolled course with progress > 0, for Continue learning.
    Course? continueCourse;
    Lesson? nextLesson;
    for (final courseId in enrollment.enrolledCourseIds) {
      final course = DemoData.courseById(courseId);
      if (course == null) continue;
      if (enrollmentNotifier.progressFor(courseId) <= 0) continue;
      continueCourse = course;
      for (final lesson in course.allLessons) {
        if (!enrollmentNotifier.isLessonCompleted(courseId, lesson.id)) {
          nextLesson = lesson;
          break;
        }
      }
      break;
    }

    final popular = DemoData.courses;
    final newest = DemoData.courses.reversed.toList(growable: false);

    return Scaffold(
      backgroundColor: cs.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header: greeting + avatar + bell -------------------------
              Row(
                children: [
                  CsAvatar(
                    photoAsset: _avatarPhoto(user),
                    name: user?.name ?? DemoData.me.name,
                    size: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_greeting(), $firstName',
                          style: AppText.h2.copyWith(color: cs.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ready to learn something new today?',
                          style: AppText.bodySmall.copyWith(
                            color: cs.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _BellButton(unreadCount: unread),
                ],
              ),
              const SizedBox(height: 16),

              // --- Data saver banner ----------------------------------------
              if (settings.dataSaver) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: cs.infoSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(AppIcons.wifi, size: 18, color: cs.info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Data Saver is on — videos play in lower quality.',
                          style: AppText.caption.copyWith(color: cs.info),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // --- Streak pill + Volts --------------------------------------
              Row(
                children: [
                  Expanded(
                    child: _PillButton(
                      icon: AppIcons.flashBold,
                      iconColor: cs.primary,
                      label: '${wallet.streakDays} day streak',
                      onTap: () => context.push('/home/streak'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PillButton(
                      icon: AppIcons.ticketBold,
                      iconColor: cs.teal,
                      label: '${wallet.volts} Volts',
                      // Display-only balance chip (no destination in Home).
                      onTap: null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Daily goal ring card (reactive to Hive goal) -------------
              ValueListenableBuilder(
                valueListenable: HiveBoxes.settings.listenable(
                  keys: ['dailyGoalMin'],
                ),
                builder: (context, _, _) {
                  final goal = readDailyGoalMin();
                  final progress =
                      (minutesStudiedToday / goal).clamp(0.0, 1.0);
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => showGoalSheet(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cs.borderHairline),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 64,
                                    height: 64,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 7,
                                      backgroundColor: cs.sunken,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        cs.primary,
                                      ),
                                      strokeCap: StrokeCap.round,
                                    ),
                                  ),
                                  Icon(
                                    AppIcons.target,
                                    size: 22,
                                    color: cs.accent,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily goal',
                                    style: AppText.label.copyWith(
                                      color: cs.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$minutesStudiedToday / $goal min today',
                                    style: AppText.bodySmall.copyWith(
                                      color: cs.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    progress >= 1
                                        ? 'Goal reached — amazing!'
                                        : 'Tap to set your goal',
                                    style: AppText.caption.copyWith(
                                      color: cs.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              AppIcons.chevronRight,
                              size: 20,
                              color: cs.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // --- Continue learning ----------------------------------------
              if (continueCourse != null) ...[
                const CsSectionHeader(title: 'Continue learning'),
                const SizedBox(height: 12),
                _ContinueCard(
                  course: continueCourse,
                  progress: enrollmentNotifier.progressFor(continueCourse.id),
                  nextLesson: nextLesson,
                ),
                const SizedBox(height: 24),
              ],

              // --- Categories ------------------------------------------------
              const CsSectionHeader(title: 'Categories'),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: DemoData.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final category = DemoData.categories[index];
                    return CsFilterChip(
                      label: category,
                      selected: false,
                      onTap: () => context.push(
                        '/home/category/${Uri.encodeComponent(category)}',
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // --- Popular courses -------------------------------------------
              CsSectionHeader(
                title: 'Popular courses',
                actionLabel: 'See all',
                onAction: () => context.push('/home/search'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 268,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: popular.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) =>
                      _PopularCard(course: popular[index]),
                ),
              ),
              const SizedBox(height: 24),

              // --- Learning path ---------------------------------------------
              const CsSectionHeader(title: 'Your learning path'),
              const SizedBox(height: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/home/path'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cs.borderHairline),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: cs.sunken,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            AppIcons.routing,
                            size: 24,
                            color: cs.accent,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Full-Stack Web Dev Path',
                                style: AppText.label.copyWith(
                                  color: cs.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '6 steps · HTML to Interview Prep',
                                style: AppText.bodySmall.copyWith(
                                  color: cs.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: 2 / 6,
                                  minHeight: 6,
                                  backgroundColor: cs.sunken,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    cs.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          AppIcons.chevronRight,
                          size: 20,
                          color: cs.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- New courses -----------------------------------------------
              const CsSectionHeader(title: 'New courses'),
              const SizedBox(height: 12),
              for (final course in newest) ...[
                CsCourseListCard(
                  course: course,
                  onTap: () => context.push('/course/${course.id}'),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 12),

              // --- Pro upsell (non-Pro only) ---------------------------------
              if (!wallet.isPro)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => showUpsellSheet(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
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
                              AppIcons.crownBold,
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
                                  'CodeShikhi Pro',
                                  style: AppText.h3.copyWith(
                                    color: cs.onPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Unlock every course, offline downloads '
                                  'and certificates.',
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
            ],
          ),
        ),
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () => context.push('/home/notifications'),
          icon: Icon(AppIcons.bell, size: 24, color: cs.textPrimary),
          splashRadius: 22,
          tooltip: 'Notifications',
        ),
        if (unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: cs.danger,
                borderRadius: BorderRadius.circular(999),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: AppText.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  /// Null = display-only chip (no tap affordance).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.borderHairline),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: AppText.label.copyWith(color: cs.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.course,
    required this.progress,
    required this.nextLesson,
  });

  final Course course;
  final double progress;
  final Lesson? nextLesson;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final next = nextLesson;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.borderHairline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  course.coverPhoto,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
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
                    Text(
                      next == null
                          ? 'Course complete — well done!'
                          : 'Up next: ${next.title}',
                      style: AppText.caption.copyWith(
                        color: cs.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: cs.sunken,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                cs.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(progress * 100).round()}%',
                          style: AppText.caption.copyWith(
                            color: cs.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CsButton(
            label: next == null ? 'View course' : 'Continue',
            size: CsButtonSize.m,
            icon: next == null ? AppIcons.check : AppIcons.playBold,
            onPressed: next == null
                ? () => context.push('/course/${course.id}')
                : () => context.push(
                      '/player/${next.id}?courseId=${course.id}',
                    ),
          ),
        ],
      ),
    );
  }
}

class _PopularCard extends StatelessWidget {
  const _PopularCard({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return SizedBox(
      width: 280,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/course/${course.id}'),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.borderHairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.asset(
                    course.coverPhoto,
                    width: 280,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: AppText.label.copyWith(color: cs.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course.instructor,
                        style: AppText.caption.copyWith(
                          color: cs.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            AppIcons.starBold,
                            size: 14,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course.rating.toStringAsFixed(1),
                            style: AppText.caption.copyWith(
                              color: cs.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' (${course.ratingCount})',
                            style: AppText.caption.copyWith(
                              color: cs.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            AppIcons.clock,
                            size: 14,
                            color: cs.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${course.hours}h',
                            style: AppText.caption.copyWith(
                              color: cs.textTertiary,
                            ),
                          ),
                          const Spacer(),
                          _AccessLabel(course: course),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccessLabel extends StatelessWidget {
  const _AccessLabel({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final String label;
    final Color bg;
    final Color fg;
    if (course.isFree) {
      label = 'Free';
      bg = cs.successSoft;
      fg = cs.success;
    } else if (course.isPro) {
      label = 'Pro';
      bg = cs.warningSoft;
      fg = cs.warning;
    } else {
      label = '৳${course.price}';
      bg = cs.sunken;
      fg = cs.textPrimary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppText.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
