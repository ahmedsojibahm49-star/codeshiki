import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_sheet.dart';

Future<void> showUpsellSheet(BuildContext context) =>
    showCsSheet(context, const UpsellSheet());

/// Pro upsell sheet [B13]: benefits + Go Pro / Maybe later.
class UpsellSheet extends StatelessWidget {
  const UpsellSheet({super.key});

  static const List<(IconData, String, String)> _benefits = [
    (
      AppIcons.crown,
      'All Pro courses unlocked',
      'Including the Full-Stack MERN Project Camp.',
    ),
    (
      AppIcons.download,
      'Download lessons offline',
      'Watch anywhere — no internet needed.',
    ),
    (
      AppIcons.award,
      'Certificates for every course',
      'Shareable proof of what you learned.',
    ),
    (
      AppIcons.flash,
      '2x XP on every lesson',
      'Climb the leaderboard twice as fast.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: CsScheme.proGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(AppIcons.crownBold, size: 32, color: cs.onPrimary),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Go Pro, learn without limits',
              style: AppText.h2.copyWith(color: cs.textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'One membership unlocks everything CodeShikhi has to offer.',
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          for (final (icon, title, body) in _benefits) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.sunken,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: cs.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppText.label.copyWith(
                          color: cs.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        body,
                        style: AppText.bodySmall.copyWith(
                          color: cs.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 8),
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
