import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_stat_item.dart';
import '../../../widgets/cs_top_bar.dart';

/// Streak detail [H04] — tab-nested (coordinator wires the route).
class StreakDetailScreen extends ConsumerWidget {
  const StreakDetailScreen({super.key});

  static const _rows = 7;
  static const _cols = 12;

  /// Deterministic pseudo-activity level 0–4 for a heatmap cell.
  static int _level(int row, int col) => (row * 7 + col) % 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final streakDays = ref.watch(walletProvider).streakDays;

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Streak'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
        children: [
          Center(
            child: Column(
              children: [
                Icon(AppIcons.flashBold, size: 40, color: cs.primary),
                const SizedBox(height: 12),
                Text(
                  '$streakDays',
                  style: AppText.display.copyWith(color: cs.textPrimary),
                ),
                Text(
                  'day streak',
                  style:
                      AppText.h3.copyWith(color: cs.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Study at least one lesson a day to keep it alive.',
                  style:
                      AppText.bodySmall.copyWith(color: cs.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.border),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: CsStatItem(value: '21', label: 'Longest streak'),
                ),
                Expanded(
                  child: CsStatItem(value: '86', label: 'Active days'),
                ),
                Expanded(
                  child: CsStatItem(value: '1', label: 'Freezes left'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Last 12 weeks',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.border),
            ),
            child: Column(
              children: [
                for (var r = 0; r < _rows; r++) ...[
                  if (r > 0) const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var c = 0; c < _cols; c++)
                        _cell(cs, _level(r, c)),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Less',
                      style: AppText.caption
                          .copyWith(color: cs.textTertiary),
                    ),
                    const SizedBox(width: 6),
                    ...[0, 1, 2, 3, 4].map(
                      (l) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: _cell(cs, l, size: 12),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'More',
                      style: AppText.caption
                          .copyWith(color: cs.textTertiary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.infoSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(AppIcons.info, size: 20, color: cs.info),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Streak freeze: you have 1 freeze left. If you miss a '
                    'day, the freeze keeps your streak safe automatically.',
                    style: AppText.bodySmall.copyWith(color: cs.info),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _cell(CsScheme cs, int level, {double size = 20}) {
    final color = level == 0
        ? cs.sunken
        : cs.primary.withValues(alpha: 0.25 + level * 0.19);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
