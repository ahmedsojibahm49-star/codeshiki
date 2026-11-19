import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../i18n/app_strings.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_chip.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/settings_prefs.dart';
import '../widgets/settings_row.dart';

/// Study reminders [K08]: master toggle (provider), time picker + weekday
/// chips (Hive keys `reminderTime` / `reminderDays`).
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  static const List<String> _days = [
    'Sat',
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
  ];

  late int _timeMinutes;
  late Set<String> _selectedDays;

  @override
  void initState() {
    super.initState();
    _timeMinutes =
        SettingsPrefs.intPref('reminderTime', defaultValue: 540); // 9:00 AM
    _selectedDays = SettingsPrefs.stringListPref(
      'reminderDays',
      defaultValue: const ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'],
    ).toSet();
  }

  TimeOfDay get _timeOfDay =>
      TimeOfDay(hour: _timeMinutes ~/ 60, minute: _timeMinutes % 60);

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDay,
    );
    if (picked != null && mounted) {
      setState(() => _timeMinutes = picked.hour * 60 + picked.minute);
    }
  }

  void _save() {
    SettingsPrefs.setIntPref('reminderTime', _timeMinutes);
    SettingsPrefs.setStringListPref('reminderDays', _selectedDays.toList());
    showCsToast(context, 'Reminders saved');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final remindersOn = ref.watch(settingsProvider).studyReminders;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: context.tr('reminders')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'A gentle nudge at your chosen time helps keep your streak alive.',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 20),
          CsSettingsSection(
            title: context.tr('reminders'),
            children: [
              CsSettingsToggleRow(
                icon: AppIcons.bellRing,
                title: 'Study reminders',
                subtitle: remindersOn ? 'On' : 'Off',
                value: remindersOn,
                onChanged: (_) =>
                    ref.read(settingsProvider.notifier).toggleReminders(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CsSettingsSection(
            title: 'Schedule',
            children: [
              CsSettingsRow(
                icon: AppIcons.clock,
                title: 'Reminder time',
                value: _timeOfDay.format(context),
                onTap: _pickTime,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'REMIND ME ON',
            style: AppText.caption.copyWith(
              color: cs.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final day in _days)
                CsFilterChip(
                  label: day,
                  selected: _selectedDays.contains(day),
                  onTap: () {
                    setState(() {
                      if (!_selectedDays.remove(day)) {
                        _selectedDays.add(day);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 28),
          CsButton(label: context.tr('save'), onPressed: _save),
        ],
      ),
    );
  }
}
