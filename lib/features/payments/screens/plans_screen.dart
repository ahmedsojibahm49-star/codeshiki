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

/// Plans [I01]: Free vs Pro cards + a link to the comparison table.
class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  static const _freeFeatures = [
    'Free courses',
    'Community access',
    'Daily practice',
    'Track your streak',
  ];

  static const _proFeatures = [
    'All courses unlocked',
    'Offline downloads',
    'AI hints in the code editor',
    'Certificates on completion',
    'Ad-free learning',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final isPro = ref.watch(walletProvider).isPro;
    return Scaffold(
      appBar: const CsTopBar(title: 'Plans'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose your plan',
              style: AppText.h1.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Start free, upgrade when you are ready. Cancel anytime.',
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            ),
            const SizedBox(height: 24),
            _PlanCard(
              title: 'Free',
              priceLabel: '৳0',
              priceSuffix: 'forever',
              features: _freeFeatures,
              isProCard: false,
              buttonLabel: isPro ? 'Switch to Free' : 'Current plan',
              buttonEnabled: isPro,
              onButtonPressed:
                  isPro ? () => context.push('/payments/cancel') : null,
            ),
            const SizedBox(height: 16),
            _PlanCard(
              title: 'Shikhi Pro',
              priceLabel: formatTaka(proMonthlyPrice),
              priceSuffix: '/month',
              features: _proFeatures,
              isProCard: true,
              badgeLabel: 'Most popular',
              buttonLabel: isPro ? 'Current plan' : 'Go Pro',
              buttonEnabled: !isPro,
              onButtonPressed: isPro
                  ? null
                  : () => context.push('/payments/checkout?plan=pro'),
            ),
            const SizedBox(height: 24),
            Center(
              child: CsButton(
                label: 'Compare plans',
                variant: CsButtonVariant.ghost,
                size: CsButtonSize.m,
                fullWidth: false,
                icon: AppIcons.chart,
                onPressed: () => context.push('/payments/compare'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.priceLabel,
    required this.priceSuffix,
    required this.features,
    required this.isProCard,
    required this.buttonLabel,
    required this.buttonEnabled,
    required this.onButtonPressed,
    this.badgeLabel,
  });

  final String title;
  final String priceLabel;
  final String priceSuffix;
  final List<String> features;
  final bool isProCard;
  final String? badgeLabel;
  final String buttonLabel;
  final bool buttonEnabled;
  final VoidCallback? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final inner = Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: isProCard
            ? null
            : Border.all(color: cs.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isProCard ? AppIcons.crownBold : AppIcons.book,
                size: 22,
                color: isProCard ? cs.accent : cs.textPrimary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppText.h2.copyWith(color: cs.textPrimary),
                ),
              ),
              if (badgeLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeLabel!,
                    style: AppText.caption.copyWith(color: cs.onPrimary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                priceLabel,
                style: AppText.display.copyWith(color: cs.textPrimary),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  priceSuffix,
                  style: AppText.bodySmall.copyWith(color: cs.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final feature in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(AppIcons.check, size: 20, color: cs.success),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppText.bodySmall.copyWith(
                        color: cs.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          CsButton(
            label: buttonLabel,
            variant: isProCard
                ? CsButtonVariant.pro
                : CsButtonVariant.secondary,
            onPressed: buttonEnabled ? onButtonPressed : null,
          ),
        ],
      ),
    );
    if (!isProCard) return inner;
    // Pro card: orange gradient border (the app's only gradient).
    return Container(
      decoration: BoxDecoration(
        gradient: CsScheme.proGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(2),
      child: inner,
    );
  }
}
