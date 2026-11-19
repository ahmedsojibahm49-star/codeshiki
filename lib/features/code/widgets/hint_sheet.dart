import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_sheet.dart';

/// Hint sheet [F18] (Pro feature): Pro members see the hint text, everyone
/// else sees a Pro upsell.
Future<void> showHintSheet(
  BuildContext context, {
  required String problemTitle,
  required String hint,
}) {
  return showCsSheet<void>(
    context,
    HintSheet(problemTitle: problemTitle, hint: hint),
  );
}

class HintSheet extends ConsumerWidget {
  const HintSheet({
    super.key,
    required this.problemTitle,
    required this.hint,
  });

  final String problemTitle;
  final String hint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final isPro = ref.watch(walletProvider).isPro;

    if (!isPro) {
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
              child: Icon(AppIcons.crown, size: 30, color: cs.accent),
            ),
            const SizedBox(height: 16),
            Text(
              'Hints are a Pro feature',
              style: AppText.h3.copyWith(color: cs.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Go Pro to unlock hints for every practice problem, plus '
              'unlimited runs and all Pro courses.',
              style: AppText.bodySmall.copyWith(
                color: cs.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.lamp, size: 22, color: cs.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Hint — $problemTitle',
                  style: AppText.h3.copyWith(color: cs.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hint,
            style: AppText.body.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 20),
          CsButton(
            label: 'Got it',
            size: CsButtonSize.m,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
