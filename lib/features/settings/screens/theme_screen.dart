import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../i18n/app_strings.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_top_bar.dart';

/// Theme [K07]: Light / Dark / System cards with mini previews.
/// Selecting calls [SettingsNotifier.setThemeMode] — the whole app
/// re-themes immediately.
class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  Widget _preview(CsScheme scheme) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: scheme.canvas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.borderHairline),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 10,
            width: 72,
            decoration: BoxDecoration(
              color: scheme.textPrimary,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: scheme.borderHairline),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 8,
                    width: 96,
                    decoration: BoxDecoration(
                      color: scheme.textSecondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 18,
                    width: 56,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Split light/dark preview for the System card.
  Widget _systemPreview() {
    final light = CsScheme.light();
    final dark = CsScheme.dark();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 88,
        child: Row(
          children: [
            Expanded(child: _preview(light)),
            Expanded(child: _preview(dark)),
          ],
        ),
      ),
    );
  }

  Widget _themeCard(
    BuildContext context,
    WidgetRef ref, {
    required ThemeMode mode,
    required String label,
    required String subtitle,
    required Widget preview,
    required bool selected,
  }) {
    final cs = context.cs;
    return InkWell(
      onTap: () => ref.read(settingsProvider.notifier).setThemeMode(mode),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? cs.primary : cs.borderHairline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            preview,
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppText.body.copyWith(
                          color: cs.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppText.caption.copyWith(
                          color: cs.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(AppIcons.checkBold, size: 24, color: cs.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.cs;
    final mode = ref.watch(settingsProvider).themeMode;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: context.tr('theme')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Pick how CodeShikhi looks. System follows your device setting.',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 20),
          _themeCard(
            context,
            ref,
            mode: ThemeMode.light,
            label: context.tr('light'),
            subtitle: 'Bright and clean',
            preview: _preview(CsScheme.light()),
            selected: mode == ThemeMode.light,
          ),
          const SizedBox(height: 12),
          _themeCard(
            context,
            ref,
            mode: ThemeMode.dark,
            label: context.tr('dark'),
            subtitle: 'Easy on the eyes at night',
            preview: _preview(CsScheme.dark()),
            selected: mode == ThemeMode.dark,
          ),
          const SizedBox(height: 12),
          _themeCard(
            context,
            ref,
            mode: ThemeMode.system,
            label: context.tr('system'),
            subtitle: 'Matches your device',
            preview: _systemPreview(),
            selected: mode == ThemeMode.system,
          ),
        ],
      ),
    );
  }
}
