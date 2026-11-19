import 'package:material_ui/material_ui.dart';

import '../../../data/hive_boxes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_chip.dart';
import '../../../widgets/cs_sheet.dart';
import '../../../widgets/cs_toast.dart';

/// Minutes studied today (demo value — the demo has no real study timer).
const int minutesStudiedToday = 25;

/// Reads the daily goal (minutes) from Hive. Default 30.
/// NOTE: there is no `dailyGoalMin` on settingsProvider, so the goal is
/// stored directly in the settings Hive box (see provider gaps in report).
int readDailyGoalMin() {
  final value = HiveBoxes.settings.get('dailyGoalMin');
  return value is int ? value : 30;
}

Future<void> showGoalSheet(BuildContext context) =>
    showCsSheet(context, const GoalSheet());

/// Daily goal sheet [B03]: progress ring, minutes today, goal picker.
class GoalSheet extends StatefulWidget {
  const GoalSheet({super.key});

  @override
  State<GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends State<GoalSheet> {
  static const List<int> _options = [15, 30, 45, 60];

  late int _selected = readDailyGoalMin();

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final progress =
        (minutesStudiedToday / _selected).clamp(0.0, 1.0);
    final done = progress >= 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily goal',
            style: AppText.h2.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            done
                ? 'Goal reached — great work today!'
                : 'A little every day goes a long way.',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 148,
              height: 148,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 148,
                    height: 148,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: cs.sunken,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(cs.primary),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.target,
                        size: 24,
                        color: cs.accent,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$minutesStudiedToday / $_selected',
                        style: AppText.h2.copyWith(color: cs.textPrimary),
                      ),
                      Text(
                        'minutes today',
                        style: AppText.caption.copyWith(
                          color: cs.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Set your daily goal',
            style: AppText.label.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: [
              for (final option in _options)
                CsFilterChip(
                  label: '$option min',
                  selected: _selected == option,
                  onTap: () => setState(() => _selected = option),
                ),
            ],
          ),
          const SizedBox(height: 24),
          CsButton(
            label: 'Save goal',
            onPressed: () {
              HiveBoxes.settings.put('dailyGoalMin', _selected);
              Navigator.of(context).pop();
              showCsToast(context, 'Daily goal set to $_selected minutes');
            },
          ),
        ],
      ),
    );
  }
}
