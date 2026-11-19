import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';

/// Cancel subscription [I15]: keep-benefits pitch + confirm.
class CancelScreen extends ConsumerWidget {
  const CancelScreen({super.key});

  static const _keepBenefits = [
    'All courses stay unlocked',
    'Your offline downloads stay available',
    'Certificates keep coming',
    'You keep your Pro badge',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    return Scaffold(
      appBar: const CsTopBar(title: 'Cancel subscription'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: cs.sunken,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.crown,
                  size: 44,
                  color: cs.accent,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "We're sorry to see you go",
              textAlign: TextAlign.center,
              style: AppText.h1.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'If you cancel, Pro ends at the close of your current billing '
              'period. Your progress and certificates stay with you.',
              textAlign: TextAlign.center,
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            ),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What you'll keep with Pro",
                    style: AppText.label.copyWith(color: cs.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  for (final benefit in _keepBenefits)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Icon(AppIcons.check, size: 20, color: cs.success),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              benefit,
                              style: AppText.bodySmall.copyWith(
                                color: cs.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            CsButton(
              label: 'Keep my Pro',
              icon: AppIcons.crown,
              onPressed: () => context.pop(),
            ),
            const SizedBox(height: 12),
            CsButton(
              label: 'Cancel subscription',
              variant: CsButtonVariant.destructive,
              onPressed: () {
                ref.read(walletProvider.notifier).setPro(false);
                showCsToast(context, 'Subscription cancelled');
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
