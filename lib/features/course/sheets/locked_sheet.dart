import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_sheet.dart';

Future<void> showLockedLessonSheet(BuildContext context, Lesson lesson) =>
    showCsSheet(context, LockedLessonSheet(lesson: lesson));

/// Locked lesson sheet [C09].
class LockedLessonSheet extends StatelessWidget {
  const LockedLessonSheet({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: cs.sunken,
              shape: BoxShape.circle,
            ),
            child: Icon(AppIcons.lock, size: 28, color: cs.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            'This lesson is locked',
            style: AppText.h2.copyWith(color: cs.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '“${lesson.title}” unlocks when you enroll in this course. '
            'Pro members unlock every lesson in every course.',
            style: AppText.body.copyWith(color: cs.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CsButton(
            label: 'Go Pro',
            variant: CsButtonVariant.pro,
            icon: AppIcons.crown,
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/payments/plans');
            },
          ),
          const SizedBox(height: 8),
          CsButton(
            label: 'Maybe later',
            variant: CsButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
