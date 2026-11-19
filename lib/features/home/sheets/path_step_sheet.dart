import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_sheet.dart';
import '../../../widgets/cs_toast.dart';

enum PathStepState { done, current, locked }

/// One step of the Full-Stack Web Dev learning path [B10/B11].
class PathStep {
  const PathStep({
    required this.title,
    required this.description,
    required this.lessons,
    required this.durationLabel,
    required this.state,
  });

  final String title;
  final String description;
  final int lessons;
  final String durationLabel;
  final PathStepState state;
}

Future<void> showPathStepSheet(BuildContext context, PathStep step) =>
    showCsSheet(context, PathStepSheet(step: step));

/// Learning-path step detail sheet [B11].
class PathStepSheet extends StatelessWidget {
  const PathStepSheet({super.key, required this.step});

  final PathStep step;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final isLocked = step.state == PathStepState.locked;
    final isDone = step.state == PathStepState.done;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isLocked ? cs.sunken : cs.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDone
                      ? AppIcons.checkBold
                      : isLocked
                          ? AppIcons.lock
                          : AppIcons.playBold,
                  size: 22,
                  color: isLocked ? cs.textTertiary : cs.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.title,
                  style: AppText.h2.copyWith(color: cs.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            step.description,
            style: AppText.body.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _MetaChip(icon: AppIcons.book, label: '${step.lessons} lessons'),
              const SizedBox(width: 10),
              _MetaChip(icon: AppIcons.clock, label: step.durationLabel),
              const SizedBox(width: 10),
              _MetaChip(
                icon: isDone
                    ? AppIcons.check
                    : isLocked
                        ? AppIcons.lock
                        : AppIcons.flash,
                label: isDone
                    ? 'Completed'
                    : isLocked
                        ? 'Locked'
                        : 'In progress',
              ),
            ],
          ),
          const SizedBox(height: 24),
          CsButton(
            label: isLocked
                ? 'Complete the previous step first'
                : isDone
                    ? 'Review this step'
                    : 'Start step',
            variant: isLocked
                ? CsButtonVariant.secondary
                : CsButtonVariant.primary,
            icon: isLocked ? AppIcons.lock : AppIcons.play,
            onPressed: () {
              if (isLocked) {
                showCsToast(
                  context,
                  'Finish the previous step to unlock this one',
                );
                return;
              }
              Navigator.of(context).pop();
              context.push('/course/react-js-zero');
            },
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.sunken,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.accent),
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
