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

/// Accessibility [K14]. These are stored preferences (Hive keys
/// `pref_reduceMotion`, `pref_highContrast`, `pref_largeTouchTargets`);
/// the demo does not re-render the whole app for them — the caption below
/// says so honestly.
class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  late bool _reduceMotion;
  late bool _highContrast;
  late bool _largeTouchTargets;

  @override
  void initState() {
    super.initState();
    _reduceMotion =
        SettingsPrefs.boolPref('pref_reduceMotion', defaultValue: false);
    _highContrast =
        SettingsPrefs.boolPref('pref_highContrast', defaultValue: false);
    _largeTouchTargets = SettingsPrefs.boolPref(
      'pref_largeTouchTargets',
      defaultValue: false,
    );
  }

  void _save() {
    SettingsPrefs.setBoolPref('pref_reduceMotion', _reduceMotion);
    SettingsPrefs.setBoolPref('pref_highContrast', _highContrast);
    SettingsPrefs.setBoolPref('pref_largeTouchTargets', _largeTouchTargets);
    showCsToast(context, 'Accessibility preferences saved');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: context.tr('accessibility')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Make CodeShikhi easier to see and use.',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 20),
          CsSettingsSection(
            title: 'Display',
            children: [
              CsSettingsToggleRow(
                icon: AppIcons.flash,
                title: 'Reduce motion',
                subtitle: 'Minimize animations and transitions',
                value: _reduceMotion,
                onChanged: (value) => setState(() => _reduceMotion = value),
              ),
              CsSettingsToggleRow(
                icon: AppIcons.eye,
                title: 'High contrast',
                subtitle: 'Stronger contrast for text and controls',
                value: _highContrast,
                onChanged: (value) => setState(() => _highContrast = value),
              ),
              CsSettingsToggleRow(
                icon: AppIcons.grid,
                title: 'Larger touch targets',
                subtitle: 'Bigger buttons and tappable areas',
                value: _largeTouchTargets,
                onChanged: (value) =>
                    setState(() => _largeTouchTargets = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Demo: preferences are saved and will apply in the full app.',
            style: AppText.caption.copyWith(color: cs.textTertiary),
          ),
          const SizedBox(height: 28),
          CsButton(label: context.tr('save'), onPressed: _save),
        ],
      ),
    );
  }
}
