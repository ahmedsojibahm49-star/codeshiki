import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_top_bar.dart';

/// Volts wallet [I16]: balance, how to earn, transaction history.
///
/// Tab-nested under Profile — the coordinator wires the route.
class VoltsWalletScreen extends ConsumerWidget {
  const VoltsWalletScreen({super.key});

  static const _howToEarn = [
    ('Complete a lesson', '+10 Volts'),
    ('Finish a quiz', '+20 Volts'),
    ('Keep a 7-day streak', '+50 Volts'),
    ('Help someone in the forum', '+15 Volts'),
  ];

  static const _history = [
    ('Quiz: React Basics', '+20 Volts', true, 'Today'),
    ('Lesson completed', '+10 Volts', true, 'Today'),
    ('AI hint pack redeemed', '-100 Volts', false, 'Yesterday'),
    ('7-day streak bonus', '+50 Volts', true, '2 days ago'),
    ('Forum answer accepted', '+15 Volts', true, '3 days ago'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final volts = ref.watch(walletProvider).volts;
    return Scaffold(
      appBar: const CsTopBar(title: 'Volts wallet'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.border),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: cs.sunken,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.flashBold,
                      size: 32,
                      color: cs.accent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$volts',
                    style: AppText.display.copyWith(color: cs.textPrimary),
                  ),
                  Text(
                    'Volts balance',
                    style: AppText.bodySmall.copyWith(
                      color: cs.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CsButton(
                    label: 'Redeem Volts',
                    icon: AppIcons.gift,
                    onPressed: () => context.push('/payments/redeem'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'How to earn Volts',
              style: AppText.h3.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (var i = 0; i < _howToEarn.length; i++) ...[
                    Row(
                      children: [
                        Icon(
                          AppIcons.flash,
                          size: 20,
                          color: cs.accent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _howToEarn[i].$1,
                            style: AppText.bodySmall.copyWith(
                              color: cs.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          _howToEarn[i].$2,
                          style: AppText.label.copyWith(color: cs.success),
                        ),
                      ],
                    ),
                    if (i < _howToEarn.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Recent activity',
              style: AppText.h3.copyWith(color: cs.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (var i = 0; i < _history.length; i++) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _history[i].$1,
                                style: AppText.bodySmall.copyWith(
                                  color: cs.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _history[i].$4,
                                style: AppText.caption.copyWith(
                                  color: cs.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _history[i].$2,
                          style: AppText.label.copyWith(
                            color: _history[i].$3 ? cs.success : cs.danger,
                          ),
                        ),
                      ],
                    ),
                    if (i < _history.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
