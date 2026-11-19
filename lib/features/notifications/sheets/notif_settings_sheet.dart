import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_sheet.dart';
import '../../settings/widgets/settings_prefs.dart';
import '../../settings/widgets/settings_row.dart';

/// Opens the quick notification-settings sheet [J04].
/// Returns true when the user tapped "All notification settings" — the
/// caller should then push `/settings/notifications`.
Future<bool> showNotifSettingsSheet(BuildContext context) async {
  final result = await showCsSheet<bool>(
    context,
    const NotifSettingsSheet(),
  );
  return result ?? false;
}

/// Quick toggles [J04]: push (provider), sound + vibration (Hive prefs).
class NotifSettingsSheet extends ConsumerStatefulWidget {
  const NotifSettingsSheet({super.key});

  @override
  ConsumerState<NotifSettingsSheet> createState() =>
      _NotifSettingsSheetState();
}

class _NotifSettingsSheetState extends ConsumerState<NotifSettingsSheet> {
  late bool _sound;
  late bool _vibration;

  @override
  void initState() {
    super.initState();
    _sound = SettingsPrefs.boolPref('pref_notifSound', defaultValue: true);
    _vibration =
        SettingsPrefs.boolPref('pref_notifVibration', defaultValue: true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final pushEnabled = ref.watch(settingsProvider).pushEnabled;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification settings',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 16),
          CsSettingsSection(
            title: 'Quick settings',
            children: [
              CsSettingsToggleRow(
                icon: AppIcons.bellRing,
                title: 'Push notifications',
                subtitle: 'Get notified about lessons and replies',
                value: pushEnabled,
                onChanged: (_) =>
                    ref.read(settingsProvider.notifier).togglePush(),
              ),
              CsSettingsToggleRow(
                icon: AppIcons.volume,
                title: 'Sound',
                value: _sound,
                onChanged: (value) {
                  setState(() => _sound = value);
                  SettingsPrefs.setBoolPref('pref_notifSound', value);
                },
              ),
              CsSettingsToggleRow(
                icon: AppIcons.flash,
                title: 'Vibration',
                value: _vibration,
                onChanged: (value) {
                  setState(() => _vibration = value);
                  SettingsPrefs.setBoolPref('pref_notifVibration', value);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          CsSettingsRow(
            icon: AppIcons.settings,
            title: 'All notification settings',
            onTap: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
