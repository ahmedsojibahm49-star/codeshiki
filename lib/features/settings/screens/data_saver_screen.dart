import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../i18n/app_strings.dart';
import '../../../providers/app_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/settings_prefs.dart';
import '../widgets/settings_row.dart';

/// Data Saver & downloads [K10]: Data Saver toggle (provider), video
/// quality (Hive `videoQuality`), storage info from [downloadsProvider],
/// Wi-Fi-only downloads (Hive `pref_wifiOnlyDownloads`).
class DataSaverScreen extends ConsumerStatefulWidget {
  const DataSaverScreen({super.key});

  @override
  ConsumerState<DataSaverScreen> createState() => _DataSaverScreenState();
}

class _DataSaverScreenState extends ConsumerState<DataSaverScreen> {
  static const List<String> _qualities = ['Auto', '480p', '720p'];

  late String _quality;
  late bool _wifiOnly;

  @override
  void initState() {
    super.initState();
    _quality =
        SettingsPrefs.stringPref('videoQuality', defaultValue: 'Auto');
    _wifiOnly =
        SettingsPrefs.boolPref('pref_wifiOnlyDownloads', defaultValue: true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final dataSaver = ref.watch(settingsProvider).dataSaver;
    final downloadedCount =
        ref.watch(downloadsProvider).downloadedPaths.length;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: 'Data Saver & downloads'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            'Save mobile data while you learn on the go.',
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 20),
          CsSettingsSection(
            title: context.tr('dataSaver'),
            children: [
              CsSettingsToggleRow(
                icon: AppIcons.flash,
                title: context.tr('dataSaver'),
                subtitle: 'Lower video quality on mobile data',
                value: dataSaver,
                onChanged: (_) =>
                    ref.read(settingsProvider.notifier).toggleDataSaver(),
              ),
              CsSettingsToggleRow(
                icon: AppIcons.wifi,
                title: 'Download on Wi-Fi only',
                subtitle: 'Lesson downloads wait for Wi-Fi',
                value: _wifiOnly,
                onChanged: (value) {
                  setState(() => _wifiOnly = value);
                  SettingsPrefs.setBoolPref('pref_wifiOnlyDownloads', value);
                  showCsToast(
                    context,
                    value
                        ? 'Downloads will wait for Wi-Fi'
                        : 'Downloads allowed on mobile data',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          CsSettingsSection(
            title: 'Video quality',
            children: [
              for (final quality in _qualities)
                InkWell(
                  onTap: () {
                    setState(() => _quality = quality);
                    SettingsPrefs.setStringPref('videoQuality', quality);
                    showCsToast(context, 'Video quality: $quality');
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.video,
                          size: 20,
                          color: cs.textPrimary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            quality == 'Auto'
                                ? 'Auto (recommended)'
                                : quality,
                            style: AppText.body.copyWith(
                              color: cs.textPrimary,
                            ),
                          ),
                        ),
                        if (_quality == quality)
                          Icon(
                            AppIcons.checkBold,
                            size: 22,
                            color: cs.primary,
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          CsSettingsSection(
            title: context.tr('storage'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cs.sunken,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        AppIcons.download,
                        size: 20,
                        color: cs.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$downloadedCount lesson${downloadedCount == 1 ? '' : 's'} downloaded',
                            style: AppText.body.copyWith(
                              color: cs.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Available offline in My Courses',
                            style: AppText.caption.copyWith(
                              color: cs.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              CsSettingsRow(
                icon: AppIcons.folder,
                title: 'Manage storage',
                onTap: () =>
                    context.push('/my-courses/downloads/storage'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
