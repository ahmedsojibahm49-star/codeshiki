import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_chip.dart';
import '../../../widgets/cs_sheet.dart';
import '../code_storage.dart';

/// Editor settings sheet [F14]: font size, editor theme, tab size,
/// autosave. Changes are saved to Hive immediately and reported via
/// [onChanged] so the editor applies font size + theme live.
Future<void> showEditorSettingsSheet(
  BuildContext context, {
  required ValueChanged<EditorSettings> onChanged,
}) {
  return showCsSheet<void>(
    context,
    EditorSettingsSheet(onChanged: onChanged),
  );
}

class EditorSettingsSheet extends StatefulWidget {
  const EditorSettingsSheet({super.key, required this.onChanged});

  final ValueChanged<EditorSettings> onChanged;

  @override
  State<EditorSettingsSheet> createState() => _EditorSettingsSheetState();
}

class _EditorSettingsSheetState extends State<EditorSettingsSheet> {
  late EditorSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = CodeStorage.loadEditorSettings();
  }

  void _update(EditorSettings next) {
    setState(() => _settings = next);
    CodeStorage.saveEditorSettings(next);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Editor settings',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Font size',
                style: AppText.label.copyWith(color: cs.textPrimary),
              ),
              Text(
                '${_settings.fontSize.round()} pt',
                style: AppText.bodySmall.copyWith(
                  color: cs.textSecondary,
                ),
              ),
            ],
          ),
          Slider(
            value: _settings.fontSize,
            min: 12,
            max: 20,
            divisions: 8,
            activeColor: cs.primary,
            label: '${_settings.fontSize.round()} pt',
            onChanged: (value) =>
                _update(_settings.copyWith(fontSize: value)),
          ),
          const SizedBox(height: 12),
          Text(
            'Editor theme',
            style: AppText.label.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              CsFilterChip(
                label: 'Follow app',
                selected: _settings.theme == 'follow',
                onTap: () =>
                    _update(_settings.copyWith(theme: 'follow')),
              ),
              CsFilterChip(
                label: 'Light',
                selected: _settings.theme == 'light',
                onTap: () =>
                    _update(_settings.copyWith(theme: 'light')),
              ),
              CsFilterChip(
                label: 'Dark',
                selected: _settings.theme == 'dark',
                onTap: () =>
                    _update(_settings.copyWith(theme: 'dark')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tab size',
            style: AppText.label.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              CsFilterChip(
                label: '2 spaces',
                selected: _settings.tabSize == 2,
                onTap: () => _update(_settings.copyWith(tabSize: 2)),
              ),
              CsFilterChip(
                label: '4 spaces',
                selected: _settings.tabSize == 4,
                onTap: () => _update(_settings.copyWith(tabSize: 4)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Autosave',
                      style:
                          AppText.label.copyWith(color: cs.textPrimary),
                    ),
                    Text(
                      'Save edits automatically while typing.',
                      style: AppText.bodySmall.copyWith(
                        color: cs.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _settings.autosave,
                activeThumbColor: cs.primary,
                onChanged: (value) =>
                    _update(_settings.copyWith(autosave: value)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
