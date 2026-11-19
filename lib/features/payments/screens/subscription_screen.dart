import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_top_bar.dart';
import '../payments_utils.dart';

/// Subscription [I14]: current plan, renewal date, cancel / upgrade.
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  static const _proPerks = [
    'All courses unlocked',
    'Offline downloads',
    'AI hints in the code editor',
    'Certificates on completion',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final isPro = ref.watch(walletProvider).isPro;
    return Scaffold(
      appBar: const CsTopBar(title: 'Subscription'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: isPro ? CsScheme.proGradient : null,
                color: isPro ? null : cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: isPro ? null : Border.all(color: cs.border),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPro ? AppIcons.crownBold : AppIcons.book,
                        size: 24,
                        color: isPro ? cs.onPrimary : cs.textPrimary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isPro ? 'Shikhi Pro' : 'Free plan',
                        style: AppText.h2.copyWith(
                          color: isPro ? cs.onPrimary : cs.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isPro
                        ? '${formatTaka(proMonthlyPrice)}/month'
                        : '৳0 — forever free',
                    style: AppText.display.copyWith(
                      color: isPro ? cs.onPrimary : cs.textPrimary,
                    ),
                  ),
                  if (isPro) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Renews on $demoRenewDate',
                      style: AppText.bodySmall.copyWith(
                        color: cs.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isPro ? "What you're enjoying" : 'What Pro adds',
              style: AppText.h3.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 12),
            for (final perk in _proPerks)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      isPro ? AppIcons.checkBold : AppIcons.check,
                      size: 20,
                      color: isPro ? cs.success : cs.textTertiary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        perk,
                        style: AppText.bodySmall.copyWith(
                          color: cs.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            if (isPro)
              CsButton(
                label: 'Cancel subscription',
                variant: CsButtonVariant.destructive,
                onPressed: () => context.push('/payments/cancel'),
              )
            else
              CsButton(
                label: 'Go Pro — ${formatTaka(proMonthlyPrice)}/month',
                variant: CsButtonVariant.pro,
                icon: AppIcons.crown,
                onPressed: () =>
                    context.push('/payments/checkout?plan=pro'),
              ),
            const SizedBox(height: 12),
            CsButton(
              label: 'Compare plans',
              variant: CsButtonVariant.ghost,
              onPressed: () => context.push('/payments/compare'),
            ),
          ],
        ),
      ),
    );
  }
}
