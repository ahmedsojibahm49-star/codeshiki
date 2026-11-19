import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../i18n/app_strings.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_avatar.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/logout_dialog.dart';
import '../widgets/settings_row.dart';

/// Settings home [K01] — tab-nested under Profile (coordinator wires it).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _themeLabel(ThemeMode mode, BuildContext context) {
    switch (mode) {
      case ThemeMode.light:
        return context.tr('light');
      case ThemeMode.dark:
        return context.tr('dark');
      case ThemeMode.system:
        return context.tr('system');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final settings = ref.watch(settingsProvider);
    final user = ref.watch(authProvider).user ?? DemoData.me;
    final languageValue =
        settings.locale.languageCode == 'bn' ? 'বাংলা' : 'English';

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(
        title: context.tr('settings'),
        showBack: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          // Profile row -> Account.
          InkWell(
            onTap: () => context.push('/settings/account'),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.borderHairline),
              ),
              child: Row(
                children: [
                  CsAvatar(
                    photoAsset: user.avatarPhoto,
                    name: user.name,
                    size: 56,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: AppText.h3.copyWith(color: cs.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: AppText.bodySmall.copyWith(
                            color: cs.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    AppIcons.chevronRight,
                    size: 20,
                    color: cs.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          CsSettingsSection(
            title: 'Account',
            children: [
              CsSettingsRow(
                icon: AppIcons.profile,
                title: 'Account',
                subtitle: 'Name, bio, linked accounts',
                onTap: () => context.push('/settings/account'),
              ),
              CsSettingsRow(
                icon: AppIcons.lock,
                title: 'Change password',
                onTap: () => context.push('/settings/password'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CsSettingsSection(
            title: 'Preferences',
            children: [
              CsSettingsRow(
                icon: AppIcons.translate,
                title: context.tr('language'),
                value: languageValue,
                onTap: () => context.push('/settings/language'),
              ),
              CsSettingsRow(
                icon: AppIcons.moon,
                title: context.tr('theme'),
                value: _themeLabel(settings.themeMode, context),
                onTap: () => context.push('/settings/theme'),
              ),
              CsSettingsRow(
                icon: AppIcons.clock,
                title: context.tr('reminders'),
                value: settings.studyReminders ? 'On' : 'Off',
                onTap: () => context.push('/settings/reminders'),
              ),
              CsSettingsRow(
                icon: AppIcons.bell,
                title: 'Notification preferences',
                value: settings.pushEnabled ? 'On' : 'Off',
                onTap: () => context.push('/settings/notifications'),
              ),
              CsSettingsRow(
                icon: AppIcons.download,
                title: 'Data Saver & downloads',
                value: settings.dataSaver ? 'On' : 'Off',
                onTap: () => context.push('/settings/data-saver'),
              ),
              CsSettingsRow(
                icon: AppIcons.shield,
                title: 'Privacy',
                onTap: () => context.push('/settings/privacy'),
              ),
              CsSettingsRow(
                icon: AppIcons.eye,
                title: context.tr('accessibility'),
                onTap: () => context.push('/settings/accessibility'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CsSettingsSection(
            title: 'Support',
            children: [
              CsSettingsRow(
                icon: AppIcons.info,
                title: 'Help center',
                onTap: () => context.push('/settings/help'),
              ),
              CsSettingsRow(
                icon: AppIcons.message,
                title: context.tr('contactSupport'),
                onTap: () => context.push('/settings/support'),
              ),
              CsSettingsRow(
                icon: AppIcons.warning,
                title: context.tr('reportProblem'),
                onTap: () => context.push('/settings/support'),
              ),
              CsSettingsRow(
                icon: AppIcons.gift,
                title: context.tr('invite'),
                subtitle: 'Earn 100 Volts per friend',
                onTap: () => context.push('/settings/invite'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CsSettingsSection(
            title: context.tr('about'),
            children: [
              CsSettingsRow(
                icon: AppIcons.book,
                title: 'About Shikhi',
                onTap: () => context.push('/settings/about'),
              ),
              CsSettingsRow(
                icon: AppIcons.documentText,
                title: 'Terms and privacy',
                onTap: () => context.push('/settings/terms'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CsSettingsSection(
            title: 'Danger zone',
            children: [
              CsSettingsRow(
                icon: AppIcons.logout,
                title: context.tr('logout'),
                showCaret: false,
                onTap: () => showLogoutDialog(context),
              ),
              CsSettingsRow(
                icon: AppIcons.trash,
                title: context.tr('deleteAccount'),
                destructive: true,
                onTap: () => context.push('/settings/delete-1'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '${context.tr('version')} 0.1.0 (Demo)',
              style: AppText.caption.copyWith(color: cs.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}
