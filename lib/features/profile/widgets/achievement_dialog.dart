import 'package:material_ui/material_ui.dart';

import '../../../data/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_badge_image.dart';
import '../../../widgets/cs_button.dart';

/// Achievement-unlocked celebration modal [H13].
Future<void> showAchievementDialog(BuildContext context, BadgeInfo badge) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => AchievementDialog(badge: badge),
  );
}

class AchievementDialog extends StatelessWidget {
  const AchievementDialog({super.key, required this.badge});

  final BadgeInfo badge;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Dialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Confetti-ish dot row.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(cs.primary, 8),
                const SizedBox(width: 10),
                _dot(cs.teal, 6),
                const SizedBox(width: 10),
                _dot(cs.primary, 5),
                const SizedBox(width: 10),
                _dot(cs.warning, 7),
                const SizedBox(width: 10),
                _dot(cs.teal, 8),
                const SizedBox(width: 10),
                _dot(cs.primary, 6),
              ],
            ),
            const SizedBox(height: 20),
            CsBadgeImage(badge: badge, size: 120),
            const SizedBox(height: 16),
            Text(
              'Achievement unlocked!',
              style: AppText.h2.copyWith(color: cs.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              badge.name,
              style: AppText.h3.copyWith(color: cs.accent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CsButton(
              label: 'Awesome',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _dot(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
