import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../i18n/app_strings.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/settings_row.dart';

/// Language [K06]: English / বাংলা. Switching calls
/// [SettingsNotifier.setLocale], which re-renders the whole app — strings
/// switch via `context.tr` and the font switches to Anek Bangla.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  Widget _languageRow(
    BuildContext context,
    WidgetRef ref, {
    required String code,
    required String label,
    required String nativeLabel,
    required bool selected,
  }) {
    final cs = context.cs;
    return InkWell(
      onTap: () => ref.read(settingsProvider.notifier).setLocale(
            Locale(code),
          ),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.sunken,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(AppIcons.translate, size: 20, color: cs.textPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppText.body.copyWith(color: cs.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nativeLabel,
                    style: AppText.caption.copyWith(color: cs.textSecondary),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(AppIcons.checkBold, size: 24, color: cs.primary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final locale = ref.watch(settingsProvider).locale;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: context.tr('language')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'The whole app switches language right away — including tabs, buttons and settings.',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 20),
          CsSettingsSection(
            title: context.tr('language'),
            children: [
              _languageRow(
                context,
                ref,
                code: 'en',
                label: 'English',
                nativeLabel: 'English',
                selected: locale.languageCode == 'en',
              ),
              _languageRow(
                context,
                ref,
                code: 'bn',
                label: 'Bangla',
                nativeLabel: 'বাংলা',
                selected: locale.languageCode == 'bn',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
