import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_stat_item.dart';
import '../../../widgets/cs_top_bar.dart';

/// Weekly learning report [H12] — tab-nested (coordinator wires it).
class LearningReportScreen extends StatelessWidget {
  const LearningReportScreen({super.key});

  // Hours per day, Sat–Fri. Sums to 6.5 hours.
  static const _days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  static const _hours = [0.5, 1.0, 0.8, 1.2, 0.5, 1.5, 1.0];

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    const maxHours = 1.5;
    const maxBarHeight = 120.0;

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Learning report'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
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
                  child: CsStatItem(value: '12', label: 'Lessons'),
                ),
                Expanded(
                  child: CsStatItem(value: '6.5h', label: 'Study time'),
                ),
                Expanded(
                  child: CsStatItem(value: '340', label: 'XP earned'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Hours per day',
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < _days.length; i++)
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${_hours[i]}h',
                          style: AppText.caption.copyWith(
                            color: cs.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: (_hours[i] / maxHours) * maxBarHeight,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: _hours[i] == maxHours
                                ? cs.primary
                                : cs.primary.withValues(alpha: 0.45),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _days[i],
                          style: AppText.caption.copyWith(
                            color: cs.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(AppIcons.star, size: 20, color: cs.accent),
                    const SizedBox(width: 8),
                    Text(
                      'Best day: Thursday',
                      style: AppText.label.copyWith(color: cs.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'You studied 1.5 hours on Thursday — your longest session '
                  'this week. You are most consistent in the evenings.',
                  style:
                      AppText.bodySmall.copyWith(color: cs.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.sunken,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(AppIcons.lamp, size: 20, color: cs.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Insight: 20 minutes a day beats a 3-hour weekend binge. '
                    'Your 12-day streak proves it — keep going!',
                    style: AppText.bodySmall.copyWith(color: cs.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
