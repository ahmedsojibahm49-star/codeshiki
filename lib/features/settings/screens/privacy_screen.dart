import 'package:material_ui/material_ui.dart';

import '../../../i18n/app_strings.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/settings_prefs.dart';
import '../widgets/settings_row.dart';

/// Privacy [K13]: profile visibility (Hive `pref_profileVisibility`),
/// leaderboard XP + analytics toggles (Hive prefs).
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  late String _visibility;
  late bool _showXp;
  late bool _analytics;

  @override
  void initState() {
    super.initState();
    _visibility = SettingsPrefs.stringPref(
      'pref_profileVisibility',
      defaultValue: 'Public',
    );
    _showXp =
        SettingsPrefs.boolPref('pref_showXpLeaderboard', defaultValue: true);
    _analytics = SettingsPrefs.boolPref('pref_analytics', defaultValue: true);
  }

  void _save() {
    SettingsPrefs.setStringPref('pref_profileVisibility', _visibility);
    SettingsPrefs.setBoolPref('pref_showXpLeaderboard', _showXp);
    SettingsPrefs.setBoolPref('pref_analytics', _analytics);
    showCsToast(context, 'Privacy settings saved');
    Navigator.of(context).pop();
  }

  Widget _visibilityOption(String value, String title, String subtitle) {
    final cs = context.cs;
    final selected = _visibility == value;
    return InkWell(
      onTap: () => setState(() => _visibility = value),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              value == 'Public' ? AppIcons.globe : AppIcons.users,
              size: 20,
              color: cs.textPrimary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.body.copyWith(color: cs.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppText.caption.copyWith(color: cs.textSecondary),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(AppIcons.checkBold, size: 22, color: cs.primary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: 'Privacy'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Control who can see you and how your data is used.',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 20),
          CsSettingsSection(
            title: 'Profile visibility',
            children: [
              _visibilityOption(
                'Public',
                'Public',
                'Anyone can see your profile and progress',
              ),
              _visibilityOption(
                'Friends',
                'Friends only',
                'Only people you follow can see your profile',
              ),
            ],
          ),
          const SizedBox(height: 24),
          CsSettingsSection(
            title: 'Leaderboard & data',
            children: [
              CsSettingsToggleRow(
                icon: AppIcons.trophy,
                title: 'Show my XP on leaderboard',
                subtitle: 'Your XP and rank are visible to others',
                value: _showXp,
                onChanged: (value) => setState(() => _showXp = value),
              ),
              CsSettingsToggleRow(
                icon: AppIcons.chart,
                title: 'Analytics',
                subtitle: 'Help improve CodeShikhi with anonymous usage data',
                value: _analytics,
                onChanged: (value) => setState(() => _analytics = value),
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
