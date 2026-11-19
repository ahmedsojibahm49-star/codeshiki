import 'package:material_ui/material_ui.dart';

import '../../../data/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_badge_image.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_sheet.dart';

/// Badge detail bottom sheet [H06]: big Flaticon image, name, description
/// and the unlock state.
Future<void> showBadgeDetailSheet(
  BuildContext context,
  BadgeInfo badge, {
  required bool unlocked,
}) {
  return showCsSheet<void>(
    context,
    BadgeDetailSheet(badge: badge, unlocked: unlocked),
  );
}

class BadgeDetailSheet extends StatelessWidget {
  const BadgeDetailSheet({
    super.key,
    required this.badge,
    required this.unlocked,
  });

  final BadgeInfo badge;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CsBadgeImage(badge: badge, size: 120, locked: !unlocked),
          const SizedBox(height: 16),
          Text(
            badge.name,
            style: AppText.h2.copyWith(color: cs.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: unlocked ? cs.successSoft : cs.sunken,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  unlocked ? AppIcons.check : AppIcons.lock,
                  size: 14,
                  color: unlocked ? cs.success : cs.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  unlocked ? 'Unlocked' : 'Locked',
                  style: AppText.label.copyWith(
                    color: unlocked ? cs.success : cs.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            unlocked ? 'How you earned it' : 'How to unlock',
            style: AppText.label.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          CsButton(
            label: 'Close',
            variant: CsButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
