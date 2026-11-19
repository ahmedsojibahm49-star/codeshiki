import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_top_bar.dart';

/// XP & level detail [H03] — tab-nested (coordinator wires the route).
class XpLevelScreen extends ConsumerWidget {
  const XpLevelScreen({super.key});

  static const _history = [
    ('Completed lesson — React Hooks', '+20 XP', 'Today'),
    ('Quiz: React Basics — 9/10', '+30 XP', 'Today'),
    ('Completed lesson — useState Deep Dive', '+20 XP', 'Yesterday'),
    ('7-day streak bonus', '+50 XP', '2 days ago'),
    ('Answered in the community', '+10 XP', '3 days ago'),
    ('Completed lesson — Python Loops', '+20 XP', '4 days ago'),
    ('Daily goal reached', '+15 XP', '5 days ago'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final wallet = ref.watch(walletProvider);
    final xp = wallet.xp;
    final level = 1 + xp ~/ 200;
    final levelStart = (level - 1) * 200;
    final nextAt = level * 200;
    final progress = ((xp - levelStart) / 200).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'XP & Level'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
        children: [
          // Level ring.
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: cs.border,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(cs.primary),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Level $level',
                        style: AppText.h2.copyWith(color: cs.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$xp XP',
                        style: AppText.bodySmall
                            .copyWith(color: cs.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$xp / $nextAt XP to Level ${level + 1}',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${nextAt - xp} XP to go — one lesson is usually 20 XP.',
            style: AppText.caption.copyWith(color: cs.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Text(
            'XP history',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 12),
          ..._history.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cs.sunken,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        AppIcons.flash,
                        size: 18,
                        color: cs.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.$1,
                            style: AppText.label
                                .copyWith(color: cs.textPrimary),
                          ),
                          Text(
                            entry.$3,
                            style: AppText.caption
                                .copyWith(color: cs.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      entry.$2,
                      style: AppText.label.copyWith(color: cs.accent),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
