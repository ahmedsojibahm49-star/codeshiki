import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../i18n/app_strings.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/settings_prefs.dart';
import '../widgets/settings_row.dart';

/// Notification preferences [K09]: push via [settingsProvider], the rest
/// via Hive prefs (`pref_lessonReminders`, `pref_communityReplies`,
/// `pref_streakAlerts`, `pref_promotions`).
class NotifPrefsScreen extends ConsumerStatefulWidget {
  const NotifPrefsScreen({super.key});

  @override
  ConsumerState<NotifPrefsScreen> createState() => _NotifPrefsScreenState();
}

class _NotifPrefsScreenState extends ConsumerState<NotifPrefsScreen> {
  late bool _lessonReminders;
  late bool _communityReplies;
  late bool _streakAlerts;
  late bool _promotions;

  @override
  void initState() {
    super.initState();
    _lessonReminders =
        SettingsPrefs.boolPref('pref_lessonReminders', defaultValue: true);
    _communityReplies =
        SettingsPrefs.boolPref('pref_communityReplies', defaultValue: true);
    _streakAlerts =
        SettingsPrefs.boolPref('pref_streakAlerts', defaultValue: true);
    _promotions =
        SettingsPrefs.boolPref('pref_promotions', defaultValue: false);
  }

  void _save() {
    SettingsPrefs.setBoolPref('pref_lessonReminders', _lessonReminders);
    SettingsPrefs.setBoolPref('pref_communityReplies', _communityReplies);
    SettingsPrefs.setBoolPref('pref_streakAlerts', _streakAlerts);
    SettingsPrefs.setBoolPref('pref_promotions', _promotions);
    showCsToast(context, 'Notification preferences saved');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final pushEnabled = ref.watch(settingsProvider).pushEnabled;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: 'Notification preferences'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Choose what CodeShikhi notifies you about.',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 20),
          CsSettingsSection(
            title: 'General',
            children: [
              CsSettingsToggleRow(
                icon: AppIcons.bellRing,
                title: 'Push notifications',
                subtitle: 'Master switch for all notifications',
                value: pushEnabled,
                onChanged: (_) =>
                    ref.read(settingsProvider.notifier).togglePush(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CsSettingsSection(
            title: 'Notify me about',
            children: [
              CsSettingsToggleRow(
                icon: AppIcons.video,
                title: 'Lesson reminders',
                subtitle: 'New lessons and study nudges',
                value: _lessonReminders,
                onChanged: (value) =>
                    setState(() => _lessonReminders = value),
              ),
              CsSettingsToggleRow(
                icon: AppIcons.messages,
                title: 'Community replies',
                subtitle: 'When someone answers your question',
                value: _communityReplies,
                onChanged: (value) =>
                    setState(() => _communityReplies = value),
              ),
              CsSettingsToggleRow(
                icon: AppIcons.flash,
                title: 'Streak alerts',
                subtitle: 'When your streak is at risk',
                value: _streakAlerts,
                onChanged: (value) => setState(() => _streakAlerts = value),
              ),
              CsSettingsToggleRow(
                icon: AppIcons.discount,
                title: 'Promotions',
                subtitle: 'Offers, discounts and new courses',
                value: _promotions,
                onChanged: (value) => setState(() => _promotions = value),
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
