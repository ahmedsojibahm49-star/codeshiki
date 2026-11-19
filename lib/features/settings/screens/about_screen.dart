import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/settings_row.dart';

/// About Shikhi [K19]. Includes the required Flaticon credit line
/// ("Badge icons by Flaticon — flaticon.com", tappable).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launch(BuildContext context, String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      showCsToast(context, 'Could not open the link', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: 'About Shikhi'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: CsScheme.proGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  '</>',
                  style: AppText.display.copyWith(
                    color: cs.onPrimary,
                    fontSize: 32,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'CodeShikhi',
              style: AppText.display.copyWith(color: cs.textPrimary),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Version 0.1.0 (Demo)',
              style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'CodeShikhi helps students across Bangladesh learn programming '
            'in Bangla — web development, Python, Java and data structures — '
            'with short video lessons, a real code editor, quizzes, streaks '
            'and certificates. Learn a little every day, and build real '
            'projects along the way.',
            style: AppText.body.copyWith(
              color: cs.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          CsSettingsSection(
            title: 'Links',
            children: [
              CsSettingsRow(
                icon: AppIcons.globe,
                title: 'Website',
                value: 'codeshikhi.app',
                onTap: () => _launch(context, 'https://codeshikhi.app'),
              ),
              CsSettingsRow(
                icon: AppIcons.message,
                title: 'Contact email',
                value: 'hello@codeshikhi.app',
                onTap: () =>
                    _launch(context, 'mailto:hello@codeshikhi.app'),
              ),
              CsSettingsRow(
                icon: AppIcons.star,
                title: 'Rate the app',
                onTap: () => showCsToast(
                  context,
                  'Thanks! Rating opens in the Play Store in the full app.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Required attribution for the Flaticon badge PNGs.
          Center(
            child: InkWell(
              onTap: () => _launch(context, 'https://www.flaticon.com/'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Text(
                  'Badge icons by Flaticon — flaticon.com',
                  style: AppText.bodySmall.copyWith(
                    color: cs.accent,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Made with Flutter in Bangladesh',
              style: AppText.caption.copyWith(color: cs.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}
