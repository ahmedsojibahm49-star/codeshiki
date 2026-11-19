import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/models.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_avatar.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_section_header.dart';
import '../../../widgets/cs_toast.dart';
import '../sheets/locked_sheet.dart';
import '../sheets/share_sheet.dart';

/// Course detail [C01]: hero, instructor, rating, price, wishlist, share,
/// modules accordion, learn/requirements/bundle/build rows, sticky CTA.
class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<CourseDetailScreen> createState() =>
      _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  /// One module open at a time; first module starts open.
  int _openModuleIndex = 0;

  Course? get _course => DemoData.courseById(widget.courseId);

  bool _isLocked(Lesson lesson, bool enrolled) =>
      lesson.locked && !enrolled;

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

  void _openLesson(Course course, Lesson lesson, bool enrolled) {
    if (_isLocked(lesson, enrolled)) {
      showLockedLessonSheet(context, lesson);
      return;
    }
    switch (lesson.type) {
      case 'quiz':
        context.push('/quiz/${lesson.id}?courseId=${course.id}');
      case 'code':
        // Code lessons open the Counter App project in the editor.
        context.push('/editor/counter-app');
      default:
        context.push('/player/${lesson.id}?courseId=${course.id}');
    }
  }

  Future<void> _onCtaPressed(Course course) async {
    final enrollment = ref.read(enrollmentProvider.notifier);
    final wallet = ref.read(walletProvider);
    final enrolled = enrollment.isEnrolled(course.id);

    if (enrolled) {
      Lesson? next;
      for (final lesson in course.allLessons) {
        if (!enrollment.isLessonCompleted(course.id, lesson.id)) {
          next = lesson;
          break;
        }
      }
      if (next == null) {
        context.push('/my-courses/progress/${course.id}');
      } else {
        context.push('/player/${next.id}?courseId=${course.id}');
      }
      return;
    }

    if (course.isFree) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            'Enroll for free?',
            style: AppText.h3.copyWith(
              color: dialogContext.cs.textPrimary,
            ),
          ),
          content: Text(
            'You will get instant access to all ${course.lessonsCount} '
            'lessons of "${course.title}".',
            style: AppText.body.copyWith(
              color: dialogContext.cs.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Enroll'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      enrollment.enroll(course.id);
      showCsToast(context, 'Enrolled!');
      return;
    }

    if (course.isPro) {
      if (wallet.isPro) {
        enrollment.enroll(course.id);
        showCsToast(context, 'Enrolled with Pro!');
      } else {
        context.push('/payments/plans');
      }
      return;
    }

    context.push('/payments/checkout?courseId=${course.id}');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final course = _course;
    if (course == null) {
      return Scaffold(
        backgroundColor: cs.canvas,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(AppIcons.chevronLeft, color: cs.textPrimary),
          ),
        ),
        body: Center(
          child: Text(
            'Course not found',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
        ),
      );
    }

    final enrollment = ref.watch(enrollmentProvider);
    final enrollmentNotifier = ref.read(enrollmentProvider.notifier);
    final wallet = ref.watch(walletProvider);
    final enrolled = enrollmentNotifier.isEnrolled(course.id);
    final wishlisted = enrollment.wishlistIds.contains(course.id);
    final progress = enrollmentNotifier.progressFor(course.id);

    final String ctaLabel;
    if (enrolled) {
      ctaLabel = progress >= 1 ? 'View my progress' : 'Continue learning';
    } else if (course.isFree) {
      ctaLabel = 'Enroll for free';
    } else if (course.isPro) {
      ctaLabel = wallet.isPro ? 'Enroll with Pro' : 'Unlock with Pro';
    } else {
      ctaLabel = 'Enroll — ৳${course.price}';
    }

    return Scaffold(
      backgroundColor: cs.canvas,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Hero cover (200 tall, rounded bottom) -------------------
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                  child: Image.asset(
                    course.coverPhoto,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        _HeroIconButton(
                          icon: AppIcons.chevronLeft,
                          onPressed: () => context.pop(),
                        ),
                        const Spacer(),
                        _HeroIconButton(
                          icon: wishlisted
                              ? AppIcons.heartBold
                              : AppIcons.heart,
                          iconColor: wishlisted ? cs.danger : null,
                          onPressed: () {
                            enrollmentNotifier.toggleWishlist(course.id);
                            showCsToast(
                              context,
                              wishlisted
                                  ? 'Removed from wishlist'
                                  : 'Saved to wishlist',
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _HeroIconButton(
                          icon: AppIcons.share,
                          onPressed: () => showShareSheet(context, course),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Title + meta --------------------------------------
                  Text(
                    course.title,
                    style: AppText.h1.copyWith(color: cs.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: AppText.body.copyWith(color: cs.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        icon: AppIcons.book,
                        label: '${course.lessonsCount} lessons',
                      ),
                      _MetaChip(
                        icon: AppIcons.clock,
                        label: '${course.hours} hours',
                      ),
                      _MetaChip(
                        icon: AppIcons.users,
                        label: '${course.students} students',
                      ),
                      _MetaChip(
                        icon: AppIcons.category,
                        label: course.category,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Rating row (-> reviews) ----------------------------
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.push(
                        '/course/${course.id}/reviews',
                      ),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cs.borderHairline),
                        ),
                        child: Row(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var i = 0; i < 5; i++)
                                  Icon(
                                    i < course.rating.round()
                                        ? AppIcons.starBold
                                        : AppIcons.star,
                                    size: 16,
                                    color: cs.primary,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              course.rating.toStringAsFixed(1),
                              style: AppText.label.copyWith(
                                color: cs.textPrimary,
                              ),
                            ),
                            Text(
                              ' (${course.ratingCount} reviews)',
                              style: AppText.bodySmall.copyWith(
                                color: cs.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              AppIcons.chevronRight,
                              size: 18,
                              color: cs.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Price block ----------------------------------------
                  if (!course.isFree)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cs.borderHairline),
                      ),
                      child: Row(
                        children: [
                          Text(
                            course.isPro
                                ? 'Pro course'
                                : '৳${course.price}',
                            style: AppText.h2.copyWith(color: cs.textPrimary),
                          ),
                          if (course.oldPrice > course.price) ...[
                            const SizedBox(width: 8),
                            Text(
                              '৳${course.oldPrice}',
                              style: AppText.bodySmall.copyWith(
                                color: cs.textTertiary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: cs.successSoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${((1 - course.price / course.oldPrice) * 100).round()}% OFF',
                                style: AppText.caption.copyWith(
                                  color: cs.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Icon(
                            course.isPro ? AppIcons.crown : AppIcons.ticket,
                            size: 20,
                            color: cs.accent,
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.successSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            AppIcons.gift,
                            size: 20,
                            color: cs.success,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Free forever — no card needed',
                            style: AppText.label.copyWith(color: cs.success),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // --- Instructor row --------------------------------------
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.push(
                        '/course/${course.id}/instructor',
                      ),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cs.borderHairline),
                        ),
                        child: Row(
                          children: [
                            CsAvatar(
                              photoAsset: course.instructorPhoto,
                              name: course.instructor,
                              size: 48,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.instructor,
                                    style: AppText.label.copyWith(
                                      color: cs.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Instructor · View profile',
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
                  ),
                  const SizedBox(height: 24),

                  // --- What you'll learn -----------------------------------
                  const CsSectionHeader(title: "What you'll learn"),
                  const SizedBox(height: 12),
                  for (final item in _learnItems(course)) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            AppIcons.checkBold,
                            size: 20,
                            color: cs.success,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item,
                              style: AppText.body.copyWith(
                                color: cs.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // --- Curriculum accordion --------------------------------
                  CsSectionHeader(
                    title: 'Curriculum',
                    actionLabel: enrolled
                        ? '${(progress * 100).round()}% done'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  for (var m = 0; m < course.modules.length; m++) ...[
                    _ModuleCard(
                      module: course.modules[m],
                      index: m,
                      isOpen: _openModuleIndex == m,
                      enrolled: enrolled,
                      onToggle: () => setState(() {
                        _openModuleIndex =
                            _openModuleIndex == m ? -1 : m;
                      }),
                      lessonIcon: _lessonIcon,
                      isLessonLocked: (lesson) =>
                          _isLocked(lesson, enrolled),
                      isLessonCompleted: (lesson) =>
                          enrollmentNotifier.isLessonCompleted(
                        course.id,
                        lesson.id,
                      ),
                      onLessonTap: (lesson) =>
                          _openLesson(course, lesson, enrolled),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 24),

                  // --- Link rows -------------------------------------------
                  _LinkRow(
                    icon: AppIcons.documentText,
                    title: 'Requirements',
                    subtitle: 'What you need before you start',
                    onTap: () => context.push(
                      '/course/${course.id}/requirements',
                    ),
                  ),
                  const SizedBox(height: 10),
                  _LinkRow(
                    icon: AppIcons.routing,
                    title: "What you'll build",
                    subtitle: 'Real projects from this course',
                    onTap: () => context.push(
                      '/course/${course.id}/build',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- Bundle card ------------------------------------------
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          context.push('/course/${course.id}/bundle'),
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
                                AppIcons.gift,
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
                                    'Save with the bundle',
                                    style: AppText.label.copyWith(
                                      color: cs.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '3 courses for ৳2,999 (was ৳4,500)',
                                    style: AppText.bodySmall.copyWith(
                                      color: cs.onPrimary.withValues(
                                        alpha: 0.85,
                                      ),
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
            ],
          ),
        ),
      // --- Sticky enroll / continue CTA ------------------------------------
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: CsButton(
            label: ctaLabel,
            icon: enrolled ? AppIcons.play : AppIcons.book,
            onPressed: () => _onCtaPressed(course),
          ),
        ),
      ),
    );
  }

  List<String> _learnItems(Course course) => [
        'Master ${course.category} fundamentals, step by step in Bangla',
        'Build real, hands-on projects you can show in your portfolio',
        'Practice with quizzes and coding exercises after every module',
        'Earn a certificate when you finish all ${course.lessonsCount} lessons',
      ];
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.92),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 22, color: iconColor ?? cs.textPrimary),
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.borderHairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: cs.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppText.caption.copyWith(
              color: cs.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.index,
    required this.isOpen,
    required this.enrolled,
    required this.onToggle,
    required this.lessonIcon,
    required this.isLessonLocked,
    required this.isLessonCompleted,
    required this.onLessonTap,
  });

  final Module module;
  final int index;
  final bool isOpen;
  final bool enrolled;
  final VoidCallback onToggle;
  final IconData Function(Lesson) lessonIcon;
  final bool Function(Lesson) isLessonLocked;
  final bool Function(Lesson) isLessonCompleted;
  final ValueChanged<Lesson> onLessonTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final totalMin =
        module.lessons.fold<int>(0, (sum, l) => sum + l.durationMin);
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.borderHairline),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cs.sunken,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppText.label.copyWith(
                            color: cs.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.title,
                            style: AppText.label.copyWith(
                              color: cs.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${module.lessons.length} lessons · $totalMin min',
                            style: AppText.caption.copyWith(
                              color: cs.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isOpen
                          ? AppIcons.chevronUp
                          : AppIcons.chevronDown,
                      size: 20,
                      color: cs.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isOpen)
            for (final lesson in module.lessons)
              _LessonRow(
                lesson: lesson,
                icon: lessonIcon(lesson),
                locked: isLessonLocked(lesson),
                completed: isLessonCompleted(lesson),
                onTap: () => onLessonTap(lesson),
              ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.lesson,
    required this.icon,
    required this.locked,
    required this.completed,
    required this.onTap,
  });

  final Lesson lesson;
  final IconData icon;
  final bool locked;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: cs.borderHairline)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
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
                  size: 17,
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
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${lesson.durationMin} min · ${_typeLabel(lesson.type)}',
                      style: AppText.caption.copyWith(
                        color: cs.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (completed)
                Text(
                  'Done',
                  style: AppText.caption.copyWith(
                    color: cs.success,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else if (locked)
                Text(
                  'Locked',
                  style: AppText.caption.copyWith(
                    color: cs.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                Icon(
                  AppIcons.playCircle,
                  size: 20,
                  color: cs.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'video':
        return 'Video';
      case 'reading':
        return 'Reading';
      case 'quiz':
        return 'Quiz';
      case 'code':
        return 'Coding';
      default:
        return 'Lesson';
    }
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
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
